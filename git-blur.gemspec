require File.expand_path("../lib/git-blur/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "git-blur"
  s.version       = GitBlur::VERSION
  s.platform      = Gem::Platform::RUBY
  s.date          = '2013-08-13'
  s.summary       = "Blur your files in your git repo"
  s.description   = "git-blur transparently encrypts and decrypts files in your git repo"
  s.authors       = ["Adria Casajus"]
  s.email         = 'adriancasajus@gmail.com'
  s.files         = Dir[ "{lib}/**/*.rb", "bin/*", "LICENSE", "*.md" ] 
  s.executables   = [ "git-blur" ]
  s.require_path  = 'lib'
  s.homepage      = "https://github.com/acasajus/git-blur"
  s.license       = "GPL-3"
end
