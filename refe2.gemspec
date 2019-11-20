$:.push File.expand_path("../lib", __FILE__)
require "bitclust/version"

Gem::Specification.new do |s|
  s.name        = "refe2"
  s.version     = BitClust::VERSION
  s.authors     = ["https://github.com/rurema"]
  s.email       = [""]
  s.homepage    = "https://docs.ruby-lang.org/ja/"
  s.summary     = %Q!BitClust is a rurema document processor.!
  s.description =<<EOD
Rurema is a Japanese ruby documentation project, and
bitclust is a rurema document processor.
This is tools for Rubyists.
EOD

  s.files         = Dir["bin/refe"]
  s.executables   = ["refe"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency "bitclust-core", "= #{BitClust::VERSION}"
end
