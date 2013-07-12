require 'find'
require 'assemblage/rails2-compat'

module Assemblage

  class Config
    attr_reader :basedir, :bundles, :level, :logging, :java

    VALID_TYPES = [:js,:css]

    class Error < Exception ; end
    class MissingFile < Error
      attr_accessor :filepath, :bundle
    end
 
    def initialize(assemblage_config_path=nil)
      @bundles = {} # named bundles
      @level = "SIMPLE_OPTIMIZATIONS"
      @logging = "DEFAULT"
      @java = "/usr/bin/java"
      assemblage_config_path=File.join(Rails.root,'config/assemblage.rb') if assemblage_config_path.nil?
      @basedir = File.expand_path(File.join(Rails.root,"public"))
      #puts "load config file at: #{assemblage_config_path.inspect}"
      evaluate assemblage_config_path 
    end

    #
    # change default base dir from public/  to something different e.g. public/foo/
    # if path is relative it will be assumed relative from Rails.root
    #
    def basedir(basedir)
      @basedir = basedir
      @basedir = File.expand_path(File.join(Rails.root, @basedir)) if !@basedir.match(/^\//)
    end

    def base_path
      @basedir
    end

    #
    # configure the bundle to be explicit
    #
    def bundle(bundle_name, type, *filelist)
      raise Error.new("Invalid bundle type, must be one of #{VALID_TYPES.inspect}") unless VALID_TYPES.include?(type)
      # verify ordered files exist
      basedir = type_to_path(type)
      filelist.each do|name|
        path = File.join(basedir, bundle_name.to_s, name)
        path << ".#{type.to_s}" unless path.match(/\.#{type.to_s}$/)
        unless File.exist?(path)
          error = MissingFile.new("Missing reference to file: #{name} at #{path}")
          error.filepath = path
          error.bundle = bundle_name
          raise error
        end

        # add a reference
        @bundles[type] ||= {}
        @bundles[type][bundle_name] ||= []
        @bundles[type][bundle_name] << {:name => name, :path => path}
      end
    end

    # valid levels, :simple, :whitespace, :advanced
    def closure(level, logging=:default)
      @level = {:simple => "SIMPLE_OPTIMIZATIONS",
                :whitespace => "WHITESPACE_ONLY",
                :advanced => "ADVANCED_OPTIMIZATIONS"}[level]
      raise "Unknown closure runtime level, should be one of :simple, :whitespace, or :advanced" if @level.blank?

      @logging = { :quiet => "QUIET",
                   :default => 'DEFAULT',
                   :verbose => 'VERBOSE'}[logging]
      raise "Unknown logging level, should be one of :quiet, :default, or :verbose" if @logging.blank?
    end

    def java(path_to_java="/usr/bin/java")
      @java = path_to_java
    end

    def has_order?(bundle_name, type)
      @bundles.key?(type.to_sym) && @bundles[type.to_sym].key?(bundle_name.to_sym)
    end

    def bundled_list(bundle_name, type)
      raise Error.new("#{bundle_name} not ordered") unless has_order? bundle_name, type
      @bundles[type][bundle_name]
    end

    def recursive_file_list(basedir, extname, load_config=true)
      files = []
      basedir = Rails.root.join("public", basedir)
      config = Config.load_config_instance if load_config

      extname.sub!(/^\./,'') # remove any leading .

      bundle_name = File.basename(basedir)
      if config && config.has_order?(bundle_name, extname.to_sym)

        config.bundled_list(bundle_name.to_sym, extname.to_sym).each do|ref|
          path = ref[:path]
          if block_given?
            files << yield(path)
          else
            files << path
          end
        end

      else
   
        Find.find(basedir) do |path|
          if FileTest.directory?(path)
            if File.basename(path)[0] == ?.
              Find.prune
            else
              next
            end
          end
        
          if File.extname(path).sub(/^\./,'') == extname
            if block_given?
              files << yield(path)
            else
              files << path
            end
          end
        end
        
        files.sort

      end

      files

    end

    def self.load_config_instance
      return nil if ENV["ASSEMBLAGE_NO_CONFIG"] == "1"
      config_path = ENV["ASSEMBLAGE_CONFIG_PATH"] if ENV["ASSEMBLAGE_CONFIG_PATH"].present?
      config_path = File.join(Rails.root,'config','assemblage.rb') if config_path.blank?
      #puts "Using config_path: #{config_path.inspect}"
      if File.exist?(config_path)
        if Rails.env == 'development'
          @assemblage_config = Config.new(config_path)
        else
          @assemblage_config ||= Config.new(config_path)
        end
      else
        raise "#{config_path.inspect} not found"
      end
    end

  private
    
    def type_to_path(type)
      basedir = @basedir
      case type
      when :js
        File.join(basedir,"javascripts") 
      when :css
        File.join(basedir,"stylesheets") 
      end
    end

    def evaluate(assemblage_path)
      self.instance_eval(File.read(assemblage_path), assemblage_path, 0)
    rescue => e
      raise Error.new("Config error: '#{e.message}' at #{e.backtrace[0].gsub(/:in `run'/,'')}")
    end

  end

end
