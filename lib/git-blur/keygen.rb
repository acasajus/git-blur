require 'openssl'
begin
  require 'io/console'
rescue
end

module GitBlur
  module KeyGen
    class << self

      def get_key_generators
        kg = GitBlur::KeyGen::KeyGenerator
        genlist = GitBlur::KeyGen.constants.select do |cname|
          cobj = GitBlur::KeyGen.const_get( cname )
          cobj.class == Class and cobj.ancestors.include? kg and cobj != kg
        end.collect do |cname|
          [ cname.to_s.gsub( "KeyGen", "" ).downcase , GitBlur::KeyGen.const_get( cname ) ]
        end
        Hash[ genlist ]
      end

    end

    MAX_CRYPT_BYTES=(1<<32)*16

    class KeyGenerator
      attr_reader :cipher_list, :cipher_keys

      def initialize( )
        @cipher_list = GitBlur::Conf.ciphers
        raise 'No ciphers defined' if @cipher_list.nil?
        @cipher_keys = {}
      end

      def generate_keys
        raise "Please overwrite this method in your generator"
      end

      def keys
        @cipher_keys
      end

      def hex_keys
        Hash[ @cipher_keys.keys.collect{ |k| [ k, Base64.strict_encode64( @cipher_keys[k] ) ] } ]
      end

    end


    class RandomKeyGen < KeyGenerator

      def generate_keys
        @cipher_list.each do |cname|
          c = OpenSSL::Cipher.new( cname )
          @cipher_keys[ cname ] = c.random_key
        end
        @cipher_keys
      end
    end


    class PasswordKeyGen < KeyGenerator

      @@iter = 100000

      def generate_keys( password = nil )
        if not password
          puts "Enter your password:"
          begin
            pass1 = $stdin.noecho(&:gets)
          rescue Errno::ENOTTY, Errno::EINVAL
            pass1 = $stdin.gets
          end
          puts "Enter it again:"
          begin
            pass2 = $stdin.noecho(&:gets)
          rescue Errno::ENOTTY, Errno::EINVAL
            pass2 = $stdin.gets
          end

          raise "Passwords do not match" if pass1 != pass2
          pass1.gsub!( /\n/, '' )
          raise "Password is empty. Why do you want to crypt then?" if pass1 == ""
          @pass = pass1
        else
          @pass = password
        end
        @cipher_list.each do |cname|
          c = OpenSSL::Cipher.new( cname )
          @cipher_keys[ cname ] = generate_cipher_key( cname, c.key_len )
        end
        @cipher_key
      end

      private

      def generate_cipher_key( salt, key_len )
        raise "No password defined" if @pass.nil?
        salt = OpenSSL::Digest::SHA512.new( "#{@pass}:#{salt}" ).digest()
        OpenSSL::PKCS5.pbkdf2_hmac( @pass, salt, @@iter, key_len, OpenSSL::Digest::SHA512.new )
      end

    end

  end
end
