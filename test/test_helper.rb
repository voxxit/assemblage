require 'rubygems'
require 'test/unit'
require 'active_support'
require 'pathname'

if !defined?(Rails)

class Rails
  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)))
  end

  def self.env
    "test"
  end
end

end

$:.unshift File.join(Rails.root, '..', 'lib')
require 'assemblage'
