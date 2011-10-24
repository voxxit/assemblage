# We only really need a few rails 3.0 features e.g. Rails.root Rails.env
if !defined?(Rails)
  class Rails
  end
end

if !Rails.respond_to?(:root)
  Rails.class_eval do
    def self.root
      Pathname.new(if defined?(RAILS_ROOT)
        RAILS_ROOT
      else
        Dir.pwd
      end)
    end
  end
end

if !Rails.respond_to?(:env)
  Rails.class_eval do
    def self.env
      if RAILS_ENV
        RAILS_ENV
      elsif ENV["RAILS_ENV"]
        ENV["RAILS_ENV"]
      else
        "development"
      end
    end
  end
end
