require 'spec_helper'
require 'tempfile'

describe "Crypto tests" do

  before(:each) do
    GitBlur::Conf.ciphers = [ 'aes-256-cbc', 'des-ede3-cbc' ]
    kg = GitBlur::KeyGen::PasswordKeyGen.new
    kg.generate_keys( "gitveilpass" )
    GitBlur::Conf.store_keys_from_gen( kg )
  end

  after(:each) do
    GitBlur::Conf.config = {}
  end
  
  it 'should raise an exception if not properly initialized' do
    GitBlur::Conf.config = {}
    expect { cm = GitBlur::Crypto::CipherMgr.new }.to raise_error "Repo does not seem to be initialized. Please execute git veil init" 
  end

  it 'should generate sensible crypters and encrypters' do
    cm = GitBlur::Crypto::CipherMgr.new
    cm.get_encrypters( "gitveil" ).collect do |c|
      c.name
    end.should == [ "AES-256-CBC", "DES-EDE3-CBC" ]
    cm.get_decrypters( "gitveil" ).collect do |c|
      c.name
    end.should == [ "DES-EDE3-CBC", "AES-256-CBC" ]
    iv = cm.generate_iv( "veil", "git", 32 )
    Base64.strict_encode64( iv ).should == "2mvrjpOwz969DLBJsSvzofqePeVv2i8iIdSvuYxffrA="
  end


  it 'should encrypt and decrypt nicely' do
    cm = GitBlur::Crypto::CipherMgr.new
    (cm.bsize-2...(cm.bsize+2)).each do |msize|
      clear_data = String.new
      File.open( "/dev/urandom", "r" ) do |rf|
        while clear_data.length < msize
          clear_data += rf.read( msize - clear_data.length )
        end
      end

      start_stream = StringIO.new( clear_data, "r" )
      end_stream = StringIO.new( "", "w" )
      mid_out_stream = StringIO.new( "", "w" )
      cm.encrypt_stream( start_stream, mid_out_stream )
      mid_in_stream = StringIO.new( mid_out_stream.string )
      cm.decrypt_stream( mid_in_stream, end_stream )
      end_stream.string.force_encoding( "ASCII-8BIT" ).should == clear_data.force_encoding( "ASCII-8BIT" )
    end
  end


  it 'should harmlessly decrypt unencrypted files' do
    cm = GitBlur::Crypto::CipherMgr.new
    clear_data = String.new
    File.open( "/dev/urandom", "r" ) do |rf|
      clear_data = rf.read( 16384 )
    end
    start_stream = StringIO.new( clear_data, "r" )
    end_stream = StringIO.new( "", "w" )
    cm.decrypt_stream( start_stream, end_stream )
    clear_data.force_encoding( "ASCII-8BIT" ).should == end_stream.string.force_encoding( "ASCII-8BIT" )
  end

end
