require 'assemblage'
require 'rails'

module Assemblage
  class Railtie < Rails::Railtie
    initializer "assemblage.boot" do
      ActionView::Base.send(:include, Assemblage::ViewHelpers)
    end

    rake_tasks do
      load "tasks/assemble.rake"
    end
  end
end
