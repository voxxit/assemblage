require 'rubygems'
require 'test/unit'
require 'active_support'
require 'pathname'

ENV["ASSEMBLAGE_CONFIG_PATH"] = File.expand_path(File.join(File.dirname(__FILE__),'config','assemblage.rb'))

# redefine for test
class Rails
  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)))
  end

  def self.env
    "test"
  end
end

$:.unshift File.join(Rails.root, '..', 'lib')
require 'assemblage'
