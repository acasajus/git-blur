require 'rspec'

#Load tha funk!
require 'git-blur'

def git_run( repo_path, cmds, mute = true )
  original_dir = Dir.pwd
  Dir.chdir( repo_path )
  data = []
  cmds = [ cmds ] if cmds.kind_of? String
  begin
    cmds.each do |cmd|
      io = IO.popen( cmd, :err=>[:child, :out]  )
      data << io.read
      Process.wait
      if $?.exitstatus > 0
        data = data[0] if cmds.length == 1 
        return [ false, data ]
      end
    end
  ensure
    Dir.chdir( original_dir )
  end
  data = data[0] if cmds.length == 1 
  [ true, data ]
end
