require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe "Actions tests" do

  before(:each) do
    @prev_dir = Dir.pwd
    @work_dir = Dir.mktmpdir( "git-blur.tests" )
  end

  after(:each) do
    FileUtils.rmtree( @work_dir )
    Dir.chdir( @prev_dir )
  end

  it 'Should test if directory is a git dir' do
    cmd = GitBlur::Actions 
    expect{ cmd.new( true, @work_dir ) }.to raise_error( "#{File.realpath @work_dir} does not seem to be a git repo" )
    git_run( @work_dir, [ 'git init', 'date > fn', 'git add fn', 'git commit -m "C1"', 'date >> fn' ] )
    expect{ cmd.new( true, @work_dir ) }.to raise_error( "Your repo is dirty. Please commit or stash your changes" )
    git_run( @work_dir, 'git reset --hard HEAD' )
    cmd.new( true, @work_dir )
  end

  it 'Should init properly' do
    begin
      pout, pin = IO.pipe
      $stdin = pout
      $stdout = File.new( "/dev/null", "w" )
      cmd = GitBlur::Actions 
      git_run( @work_dir, [ 'git init', 'date > fn', 'git add fn', 'git commit -m "C1"' ]  )
      pin.write( "mypass\nmypass\n" )
      c = cmd.new( true, @work_dir )
      c.init
    ensure
      $sdtin = STDIN
      $stdout = STDOUT
    end
    git_run( @work_dir, "git config --local filter.git-blur.smudge" ).should == [ true, "git-blur smudge\n" ]
    git_run( @work_dir, "git config --local filter.git-blur.clean" ).should == [ true, "git-blur clean\n" ]
    git_run( @work_dir, "git config --local diff.git-blur.textconv" ).should == [ true, "git-blur diff\n" ]
    File.open( File.join( @work_dir, ".git", "blur.conf" ) ) do |f|
      read_conf = YAML.load( f.read )
      GitBlur::Conf.config.should == read_conf
    end
  end

end
