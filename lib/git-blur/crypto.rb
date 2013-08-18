require 'base64'
require 'io/console'
require 'openssl'

module GitBlur
  module Crypto

    class CipherMgr
      attr_accessor :bsize

      def initialize
        @ciphers = GitBlur::Conf.ciphers
        @cipher_keys = GitBlur::Conf.keys
        raise "Repo does not seem to be initialized. Please execute git veil init" if @ciphers.nil? or @cipher_keys.nil?
        @bsize = 8192
      end

      def decrypt_stream( instream, outstream = nil )
        outstream = $stdout if outstream.nil?
        magic = instream.read( 12 )
        if magic != "GIT-VEILFTW|"
          #Not git-blur file
          outstream.write( magic )
          while not instream.eof?
            outstream.write( instream.read( @bsize ) )
          end
          return
        end
        #READ nonce ( SHA512 length )
        nonce = instream.read( 64 )
        process_stream( instream, outstream, get_decrypters( nonce ) )
      end

      def encrypt_stream( instream, outstream = nil )
        outstream = $stdout if outstream.nil?
        nonce = OpenSSL::Digest::SHA512.new
        data = ""
        while not instream.eof?
          rb = instream.read(8192)
          nonce.update(rb)
          data += rb 
        end
        nonce = nonce.digest
        outstream.write( "GIT-VEILFTW|#{nonce}" )
        process_stream( StringIO.new( data ), outstream, get_encrypters( nonce ) )
      end

      def get_encrypters( nonce )
        generate_cipers do |c|
          c.encrypt
          cnonce = "#{c.name}:#{nonce.to_s}" 
          c.iv = OpenSSL::Digest::SHA512.new( cnonce ).digest.slice( 1, c.iv_len ) 
        end
      end

      def generate_iv( cname, nonce, iv_len )
        cnonce = "#{cname}:#{nonce.to_s}" 
        OpenSSL::Digest::SHA512.new( cnonce ).digest.slice( 1, iv_len ) 
      end

      def get_decrypters( nonce )
        generate_cipers do |c|
          c.decrypt
          c.iv = generate_iv( c.name, nonce, c.iv_len )
        end.reverse
      end

      private

      def process_stream( instream, outstream, ciphers )
        while not instream.eof? 
          chunk = instream.read( @bsize )
          ciphers.each do |cobj|
            break if chunk.length == 0
            chunk = cobj.update( chunk )
          end
          outstream.write( chunk )
        end
        oend = String.new
        ciphers.each do |cobj|
          if oend.length > 0
            oend = cobj.update( oend ) + cobj.final
          else
            oend = cobj.final
          end
        end
        outstream.write( oend )
      end

      def generate_cipers
        clist = []
        clist.tap do
          @ciphers.each do |cname|
            c = OpenSSL::Cipher.new( cname )
            yield c
            c.key = @cipher_keys[ cname ]
            clist << c
          end
        end
      end

    end

  end
end
