require 'git-blur/crypto'
require 'git-blur/keygen'
require 'git-blur/conf'

module GitBlur

  class Actions

    def initialize( new_repo = false, repo_dir = false )
      if repo_dir
        Dir.chdir( repo_dir )
      end

      status, out = exec( "git rev-parse --show-cdup 2>/dev/null" )
      raise "#{Dir.pwd} does not seem to be a git repo" if status != 0

      @repo_dir = File.join( Dir.pwd, out )
      @conf_file = File.join( @repo_dir, ".git", "blur.conf" )

      if new_repo
        status, out = exec( "git status -uno --porcelain" )
        raise "Can't retrieve repo status" if status != 0
        raise "Your repo is dirty. Please commit or stash your changes" if out.length > 0
      end

      GitBlur::Conf.read_configuration( @conf_file ) if not new_repo
    end

    def init
      raise "Configuration file #{@conf_file} already exists. I won't overwrite it :)" if File.file? @conf_file

      GitBlur::Conf.ciphers = [ 'aes-256-cbc', 'bf-cbc', 'des-ede3-cbc' ]

      kg = GitBlur::KeyGen.get_key_generators[ 'password' ].new
      kg.generate_keys
      GitBlur::Conf.store_keys_from_gen( kg )

      #Configure filters
      status, out = exec( "git config filter.git-blur.smudge 'git-blur smudge'" )
      raise "Git config failed" if status != 0
      status, out = exec( "git config filter.git-blur.clean 'git-blur clean'" )
      raise "Git config failed" if status != 0
      status, out = exec( "git config diff.git-blur.textconv 'git-blur diff'" )
      raise "Git config failed" if status != 0
     
      puts "Storing configuration file in #{@conf_file}"
      GitBlur::Conf.write_configuration( @conf_file )

      status, out = exec( "git rev-parse HEAD >/dev/null 2>/dev/null" )
      if status == 0 
        puts "Checking out HEAD to decrypt any stored file"
        status, out = exec( "git checkout -f HEAD -- #{@repo_dir}" )
        raise "Git checkout failed" if status != 0
      end

    end

    def clean
      #STDIN -> encrypt -> STDOUT
      cm = GitBlur::Crypto::CipherMgr.new
      cm.encrypt_stream( $stdin )
    end


    def smudge
      #STDIN -> decrypt -> STDOUT
      cm = GitBlur::Crypto::CipherMgr.new
      cm.decrypt_stream( $stdin )
    end

    def diff( file_path )
      cm = GitBlur::Crypto::CipherMgr.new
      File.open( file_path ) do |f|
        cm.decrypt_stream( f )
      end
    end


    private

    def exec( cmd )
      io = IO.popen( cmd )
      out = io.read
      Process.wait
      [ $?.exitstatus, out.strip ]
    end

  end

end

__END__

@@ welcome
Thanks for using git-blur!
Before using it we need to configure how you want to encrypt your files


