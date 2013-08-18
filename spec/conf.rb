require 'spec_helper'
require 'tempfile'

describe "Config tests" do

  before(:each) do
    @work_file = Tempfile.new( "git-blur.conf.tests" )
    @work_file.close
  end

  after(:each) do
    @work_file.unlink
  end

  it 'stored and accessed is the same' do
    dummy = { :ciphers => [ :a, :b ], :keys => 'dummy' }
    GitBlur::Conf.config = dummy
    GitBlur::Conf.config.should == dummy
    GitBlur::Conf.ciphers.should == [ :a, :b ]
    GitBlur::Conf.keys.should == 'dummy'
    GitBlur::Conf.ciphers = [ :c, :d ]
    GitBlur::Conf.ciphers.should == [ :c, :d ]
  end

  it 'Store and load the same' do
    dummy = { 'a' => 1, 'b' => 2 }
    GitBlur::Conf.config = dummy
    GitBlur::Conf.write_configuration( @work_file.path )
    GitBlur::Conf.config = {}
    GitBlur::Conf.read_configuration( @work_file.path )
    GitBlur::Conf.config.should == dummy
  end

end
