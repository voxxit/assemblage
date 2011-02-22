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
end
