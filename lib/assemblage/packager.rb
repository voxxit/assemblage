require 'assemblage/config'

module Assemblage

  class Packager
    attr_reader :config

    def initialize(config_path=nil)
      @config = Assemblage::Config.new(config_path)
    end

    def package_js
      paths = get_top_level_directories(:javascripts)
      targets = []

      paths.each do |bundle_directory|
        bundle_name = bundle_directory.basename
        files       = recursive_file_list(bundle_directory, ".js")

        next if files.empty? || bundle_name == "dev"

        target = execute_closure(files, bundle_name)

        targets << target
      end

      targets
    end

    def package_css
      paths = get_top_level_directories(:stylesheets)
      targets = []

      paths.each do |bundle_directory|
        bundle_name = bundle_directory.basename
        files = recursive_file_list(bundle_directory, ".css")

        next if files.empty? || bundle_name == 'dev'

        bundle = ""

        files.each do |file_path|
          bundle << File.read(file_path) << "\n"
        end

        target = execute_yui_compressor(bundle, bundle_name)

        targets << target
      end

      targets
    end

  private

    def execute_closure(files, bundle_name)
      jar = File.expand_path(File.join(File.dirname(__FILE__),'..','..', 'bin', 'compiler.jar')) # jar = Rails.root.join("vendor", "plugins", "assemblage", "bin", "compiler.jar")
      target = Rails.root.join("public/javascripts/bundle_#{bundle_name}.js")

      files = files.collect { |a| "--js=" + a }

      cmd = "#{@config.java} -jar #{jar} #{files.join(" ")} --compilation_level #{@config.level} --warning_level #{@config.logging} --js_output_file #{target}"
      puts cmd.inspect if @config.logging == "VERBOSE"
      system(cmd)

      return target
    end

    def execute_yui_compressor(bundle, bundle_name)
      jar = File.expand_path(File.join(File.dirname(__FILE__),'..','..', 'bin', 'yui-compressor.jar')) # jar = Rails.root.join("vendor", "plugins", "assemblage", "bin", "yui-compressor.jar")
      target = Rails.root.join("public/stylesheets/bundle_#{bundle_name}.css")
      temp_file = "/tmp/bundle_raw.css"

      File.open(temp_file, 'w') { |f| f.write(bundle) }

      `#{@config.java} -jar #{jar} --line-break 0 #{temp_file} -o #{target}`

      return target
    end

    def recursive_file_list(basedir, extname)
      @config.recursive_file_list(basedir, extname)
    end

    def get_top_level_directories(type)
      Dir.entries(Rails.root.join(@config.base_path, type.to_s)).collect do |path|
        path = Rails.root.join("#{@config.base_path}/#{type}/#{path}")

        File.basename(path)[0] == ?. || !File.directory?(path) ? nil : Pathname.new(path) # not dot directories or files
      end - [nil]
    end

  end

end
