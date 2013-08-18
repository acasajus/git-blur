#!/usr/bin/env ruby

require 'git-blur'
require 'optparse'

module GitBlur
  class CmdParser
    attr_accessor :cmds

    def initialize
      @cmds = Hash[ self.methods.select do |mn|
        mn.to_s.index( "cmd_" ) == 0
      end.map do |mn|
        [ mn.slice( 4, mn.length ) , self.method( mn ) ] 
      end ]
    end


    def run
      cmd = ARGV[0]

      if cmd == "--help"
        cmd_help
        return
      end

      if not @cmds.include? cmd
        msg = String.new
        if cmd.nil?
          msg += "Missing command\n"
        else
          msg += "Unknown command #{cmd}\n"
        end
        msg += "\n" + command_list
        raise msg
      end

      @cmds[ cmd ].call
    end

    def desc_init() "Initialize crypo keys and git configuration" end
    def cmd_init
      GitBlur::Actions.new( true ).init
    end

    def desc_clean() "Encrypt stdin into stdout" end
    def cmd_clean
      GitBlur::Actions.new.clean
    end

    def desc_smudge() "Decrypt stdin into stdout" end
    def cmd_smudge
      GitBlur::Actions.new.smudge
    end

    def desc_version() "Show git-blur version" end
    def cmd_version
      puts "git-blur #{GitBlur::VERSION}"
    end

    def desc_help() "Show help" end
    def cmd_help
      puts "git-blur transparently encrypts and decrypts files in your repo"
      puts "Usage: git blur command [opts]"
      puts ""
      puts command_list
    end

    def desc_diff() "Decrypt a file into stdout" end
    def cmd_diff
      if ARGV.length < 2
        raise "Missing file"
      end
      GitBlur::Actions.new.diff ARGV[1]
    end

    private

    def command_list
      msg = "Valid commands:\n"
      self.methods.sort.select do |mn|
        mn.to_s.index( "cmd_" ) == 0
      end.each do |mn|
        mn = mn[4..-1]
        begin
          desc = self.send( "desc_#{mn}" )
        rescue
          desc = ""
        end
        msg += "  #{mn}#{" "*(15-mn.length)}#{desc}\n"
      end
      msg
    end

  end
end
