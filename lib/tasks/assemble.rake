$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'..'))
require 'assemblage'

namespace :assemble do
  desc "Assemble all bundles for javascripts and stylesheeets"
  task :all => [ :js, :css ]
 
  task :js do
    Assemblage::Packager.new.package_js.each do |target|
      puts "=> Assembled JavaScript at: #{target}"
    end
  end
 
  task :css do
    Assemblage::Packager.new.package_css.each do |target|
      puts "=> Assembled CSS at: #{target}"
    end
  end
end
