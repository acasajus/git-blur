require 'yaml'
require 'base64'

module GitBlur
  module Conf
    class << self

      def config=( conf_hash )
        @config = conf_hash
      end

      def config
        @config ||= {}
      end

      def store_keys_from_gen( keygen )
        ciphers = keygen.cipher_list
        config[ :keys ] = keygen.cipher_keys
      end

      def ciphers=( cipher_list )
        config[:ciphers] = cipher_list
      end

      def ciphers
        config[ :ciphers ]
      end

      def keys
        config[ :keys ]
      end

      def read_configuration( config_file )
        config_file = File.expand_path( config_file )
        config_hash = YAML.load( File.read( config_file ) )
        if config_hash.include? :keys
          config_hash[ :keys ].each_key do |k|
            config_hash[ :keys ][k] = Base64.strict_decode64( config_hash[ :keys ][k] )
          end
        end
        self.config = config_hash || {}
      rescue Errno::ENOENT
        raise GitBlur::MissingConfiguration.new(config_file)
      end

      def write_configuration( config_file )
        config_file = File.expand_path( config_file )
        txt_config = self.config.clone
        if txt_config.include? :keys
          txt_config[ :keys ].each_key do |k|
            txt_config[ :keys ][k] = Base64.strict_encode64( txt_config[ :keys ][k] )
          end
        end
        File.open( config_file, "wb" ) do |f| 
          f.write( YAML.dump( self.config ) )
        end
      rescue Errno::ENOENT
        raise GitBlur::MissingConfiguration.new(config_file)
      end

    end

    # Exception raised when the path passed to
    # {Ripple::load_configuration} does not point to a existing file.
    class MissingConfiguration < StandardError
      def initialize(file_path)
        super(t("missing_configuration", :file => file_path))
      end
    end
  end
end
