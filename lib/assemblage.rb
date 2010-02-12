require 'find'

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
        output << javascript_src_tag("bundle_#{bundle}", {}) + "\n"
      end
      
      output
    end

    def javascript_include_files(bundles)
      output = ""
      
      bundles.each do |bundle|
        files = recursive_file_list("public/javascripts/#{bundle}", ".js")
      
        files.each do |file|
          file = file.gsub('public/javascripts/', '')
      
          output << javascript_src_tag(file, {}) + "\n"
        end
      end
      
      output
    end

    def javascript_dev(*sources)
      output = ""
      sources = sources.to_a
      
      sources.each do |pair|
        output << javascript_src_tag(Rails.env.development? ? "dev/#{pair[0]}" : pair[1], {})
      end
      
      output
    end

    def stylesheet_bundle(*sources)
      sources = sources.to_a
      bundle_files? ? stylesheet_include_bundles(sources) : stylesheet_include_files(sources)
    end

    # This method assumes you have manually bundled css using a rake command
    # or similar. So, there better be bundle_* files!
    def stylesheet_include_bundles(bundles)
      stylesheet_link_tag(bundles.collect{ |b| "bundle_#{b}"})
    end

    def stylesheet_include_files(bundles)
      output = ""
      
      bundles.each do |bundle|
        files = recursive_file_list("public/stylesheets/#{bundle}", ".css")
      
        files.each do |file|
          file = file.gsub('public/stylesheets/', '')
      
          output << stylesheet_link_tag(file)
        end
      end
      
      output
    end

    def recursive_file_list(basedir, extname)
      files = []
      basedir = Rails.root.join(basedir)
      
      Find.find(basedir) do |path|
        if FileTest.directory?(path)
          if File.basename(path)[0] == ?.
            Find.prune
          else
            next
          end
        end
      
        files << path.gsub(Rails.root, '') if File.extname(path) == extname
      end
      
      files.sort
    end
  end
end