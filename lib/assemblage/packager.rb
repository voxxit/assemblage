require 'assemblage/config'

module Assemblage

  class Packager

    def package_js
      paths = get_top_level_directories("public/javascripts")
      targets = []

      paths.each do |bundle_directory|
        bundle_name = bundle_directory.basename
        files = recursive_file_list(bundle_directory, ".js")

        next if files.empty? || bundle_name == "dev"

        target = execute_closure(files, bundle_name)

        targets << target
      end

      targets
    end

    def package_css
      paths = get_top_level_directories("public/stylesheets")
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

      # TODO: add java path to the config/assemblage.rb file
      `java -jar #{jar} #{files.join(" ")} --js_output_file #{target}`

      return target
    end

    def execute_yui_compressor(bundle, bundle_name)
      jar = File.expand_path(File.join(File.dirname(__FILE__),'..','..', 'bin', 'yui-compressor.jar')) # jar = Rails.root.join("vendor", "plugins", "assemblage", "bin", "yui-compressor.jar")
      target = Rails.root.join("public/stylesheets/bundle_#{bundle_name}.css")
      temp_file = "/tmp/bundle_raw.css"

      File.open(temp_file, 'w') { |f| f.write(bundle) }

      # TODO: add java path to the config/assemblage.rb file
      `java -jar #{jar} --line-break 0 #{temp_file} -o #{target}`

      return target
    end

    def recursive_file_list(basedir, extname)
      Config.recursive_file_list(basedir, extname)
    end

    def get_top_level_directories(base_path)
      Dir.entries(Rails.root.join(base_path)).collect do |path|
        path = Rails.root.join("#{base_path}/#{path}")

        File.basename(path)[0] == ?. || !File.directory?(path) ? nil : Pathname.new(path) # not dot directories or files
      end - [nil]
    end

  end

end
