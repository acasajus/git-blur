module GitBlur
  $raw_version = "0.0.1"
  if ENV.include? 'BUILD_NUMBER'
    VERSION = "#{$raw_version}.dev.#{ENV[ 'BUILD_NUMBER' ]}"
  else
    VERSION = $raw_version
  end
end
