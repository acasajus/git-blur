require 'spec_helper'
require 'base64'

describe "Keygen tests" do

  before(:each) do
    GitBlur::Conf.ciphers = [ 'aes-256-cbc', 'des-ede3-cbc' ]
  end

  after(:each) do
    GitBlur::Conf.config = {}
  end


  it 'Should have expected generators' do
    GitBlur::KeyGen.get_key_generators.should == { "password" => GitBlur::KeyGen::PasswordKeyGen,
                                                   "random" => GitBlur::KeyGen::RandomKeyGen }
  end

  it 'Should pick up ciphers from config' do
    GitBlur::Conf.config = {}
    expect { GitBlur::KeyGen::KeyGenerator.new }.to raise_error( 'No ciphers defined' )
    GitBlur::Conf.ciphers = [ 'aes-256-cbc', 'des-ede3-cbc' ]
    GitBlur::KeyGen::KeyGenerator.new.hex_keys.should == {}
  end


  it 'Password keygen should be consistent' do
    begin 
      pg = GitBlur::KeyGen::PasswordKeyGen.new()
      pout, pin = IO.pipe
      $stdin = pout
      $stdout = File.new('/dev/null', 'w')
      pin.write( "mypass\notherpass\n" )
      expect { pg.generate_keys }.to raise_error( "Passwords do not match" )
      pin.write( "\n\n" )
      expect { pg.generate_keys }.to raise_error( "Password is empty. Why do you want to crypt then?" )
      pin.write( "mypass\nmypass\n" )
      pg.generate_keys
      pg.hex_keys.should == { "aes-256-cbc"=>"dUl8PcxCEKc2mhsBfUlLPLIt2aybeA/7e/oEDAUrvKA=", 
                              "des-ede3-cbc"=>"8xXmiWLwxXX0SYThd8Ocpdp5dr6iguLV"}  
    ensure
      $stdin = STDIN
      $stdout = STDOUT
    end
  end


  it 'Random keygen should be consistent' do
    kg = GitBlur::KeyGen::RandomKeyGen.new
    kg.generate_keys.keys.sort.should == GitBlur::Conf.ciphers.sort
  end

end
