require 'assemblage/config'
require 'assemblage/packager'
require 'assemblage/version'

module Assemblage

  module ViewHelpers
    def bundle_files?
      Rails.env.production? || Rails.env.staging? || params[:bundle] || cookies[:bundle] == "yes"
    end

    def javascript_bundle(*sources)
      sources = sources.to_a
      bundle_files? ? javascript_include_bundles(sources) : javascript_include_files(sources)
    end

    # This method assumes you have manually bundled js using a rake command
    # or similar. So, there better be bundle_* files!
    def javascript_include_bundles(bundles)
      output = ""
      
      bundles.each do |bundle|
        output << javascript_include_tag("bundle_#{bundle}") + "\n"
      end
      
      output.html_safe
    end

    def javascript_include_files(bundles)
      output = ""
      
      bundles.each do |bundle|
        files = recursive_file_list("javascripts/#{bundle}", ".js")
      
        files.each do |file|
          file = file.gsub('public/', '')
      
          output << javascript_include_tag(file) + "\n"
        end
      end
      
      output.html_safe
    end

    def javascript_dev(*sources)
      output = ""
      sources = sources.to_a
      
      sources.each do |pair|
        output << javascript_include_tag(Rails.env.development? ? "dev/#{pair[0]}" : pair[1]) + "\n"
      end
      
      output.html_safe
    end

    def stylesheet_bundle(*sources)
      sources = sources.to_a
      bundle_files? ? stylesheet_include_bundles(sources) : stylesheet_include_files(sources)
    end

    # This method assumes you have manually bundled css using a rake command
    # or similar. So, there better be bundle_* files!
    def stylesheet_include_bundles(bundles)
      stylesheet_link_tag(bundles.collect {|b| "bundle_#{b}"})
    end

    def stylesheet_include_files(bundles)
      output = ""
      
      bundles.each do |bundle|
        files = recursive_file_list("stylesheets/#{bundle}", ".css")
      
        files.each do |file|
          file = file.gsub('public/', '')
          
          output << stylesheet_link_tag(file) + "\n"
        end
      end
      
      output.html_safe
    end

    def recursive_file_list(basedir, extname)
      Config.recursive_file_list(basedir, extname) do|path|
        path.gsub(Rails.root.to_s, '')
      end
    end


  end
end
