$:.unshift File.expand_path(File.dirname(__FILE__) + "/lib")
require "assemblage/version"

Gem::Specification.new do |spec|
  spec.name           = "assemblage"
  spec.version        = Assemblage::VERSION
  spec.author         = "Josh Delsman"
  spec.email          = "assaf@labnotes.org"
  spec.homepage       = "https://github.com/voxxit/assemblage"
  spec.summary        = "Rails plugin to allow for compressing and bundling JavaScript & CSS files for production"
  spec.description    = "Rails plugin to allow for compressing and bundling JavaScript & CSS files for production"
  spec.post_install_message = ""
  spec.require_paths = ['lib']

  spec.files          = Dir["{lib,bin}/**/*", "MIT-LICENSE", "README.rdoc", "Rakefile", "*.gemspec"]

  spec.extra_rdoc_files = "README.rdoc"
  spec.rdoc_options     = "--title", "Assemblage #{spec.version}", "--main", "README.rdoc", "--webcvs", spec.homepage

  spec.required_ruby_version = '>= 1.8.7'
  spec.add_development_dependency "activesupport"
end
