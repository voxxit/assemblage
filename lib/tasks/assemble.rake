$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'..'))
require 'assemblage'

namespace :assemble do
  desc "Assemble all bundles for javascripts and stylesheeets"
  task :all => [ :js, :css ]
 
  task :js do
    targets = Assemblage::Packager.new.package_js.each do |target|
      puts "=> Assembled JavaScript at: #{target}"
    end
    File.open(File.join(Rails.root,'config/assembled.js.yml'), 'wb') {|f| f <<  YAML.dump(targets) }
  end
 
  task :css do
    targets = Assemblage::Packager.new.package_css.each do |target|
      puts "=> Assembled CSS at: #{target}"
    end
    File.open(File.join(Rails.root,'config/assembled.css.yml'), 'wb') {|f| f <<  YAML.dump(targets) }
  end

  desc "Given an assemblage configuration file, setup the correct directory strucutre and copy all css and js files into the each bundle folder"
  task :setup do
    if !File.exist?(Rails.root + "config/assemblage.rb")
      STDERR.puts "Unforuntately this command will only work if you have an config/assemblage.rb file."
      exit(1)
    end
    begin
      config = Assemblage::Config.new(Rails.root + "config/assemblage.rb")
    rescue Assemblage::Config::MissingFile => e
      original_filepath = e.filepath.gsub(e.bundle.to_s + '/','')
      if File.exist?(original_filepath)
        FileUtils.mkdir_p(File.dirname(e.filepath))
        FileUtils.cp(original_filepath,e.filepath)
        puts "copy #{File.basename(original_filepath)} to #{e.bundle}"
        retry
      else
        raise "Unable to determine orgiinal file path of expected: #{e.filepath} in bundle: #{e.bundle}"
      end
    end
  end
end
