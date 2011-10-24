require 'test_helper'

class AssemblageTest < ActiveSupport::TestCase
  WIDGET_JSLIST = ['jquery-1.4.4.min.js', 'jquery-ui-1.8.7.custom.min.js', 'jquery.maskedinput-1.2.2.min.js', 'raphael-1.5.2.min.js', 'jquery.ba-postmessage.0.5.min.js']

  def test_configuration_exceptions
    assert_raises Assemblage::Config::MissingFile do
      config = Assemblage::Config.new(File.join(File.dirname(__FILE__), 'config/assemblage-config-error.rb'))
    end
  end

  def test_configuration_loader_alternative_basedir
    config = Assemblage::Config.new(File.join(File.dirname(__FILE__), 'config/assemblage-alt.rb'))
  end

  def test_configuration_loader
    config = Assemblage::Config.load_config_instance

    assert config.has_order? :widget, :js
    assert config.has_order? 'widget', :js
    assert config.has_order? :app, 'js'

    list = config.bundled_list :widget, :js
    assert_equal WIDGET_JSLIST.size, list.size

    WIDGET_JSLIST.each do|name|
      list.select {|ref| ref[:name] == name }.each do|ref|
        assert File.exist?(ref[:path])
      end
    end

    assert_equal "WHITESPACE_ONLY", config.level
    assert_equal "QUIET", config.logging

  end

  def test_can_list_files_recursivesly_with_and_without_a_configuration_file
    files = Assemblage::Config.new.recursive_file_list(Rails.root.join("public/javascripts/widget"), "js", false)

    assert_equal WIDGET_JSLIST.size, files.size

    WIDGET_JSLIST.each do|name|
      assert files.map{|f| File.basename(f) }.include?(name), "Missing expected file: #{name}"
    end

    files = Assemblage::Config.new.recursive_file_list(Rails.root.join("public/javascripts/widget"), "js", true)

    assert_equal WIDGET_JSLIST.size, files.size

    WIDGET_JSLIST.each do|name|
      assert files.map{|f| File.basename(f) }.include?(name), "Missing expected file: #{name}"
    end

  end

  def test_assemblage_assembles_with_config
    assemblage_package
  end

  def test_assemblage_assembles_without_config
    ENV["ASSEMBLAGE_NO_CONFIG"] = "1"
    assemblage_package
    ENV.delete("ASSEMBLAGE_NO_CONFIG")
  end

  def assemblage_package
    app_bundle    = "test/public/javascripts/bundle_app.js"
    widget_bundle = "test/public/javascripts/bundle_widget.js"

    File.unlink app_bundle if File.exist?(app_bundle)
    File.unlink widget_bundle if File.exist?(widget_bundle)

    packager = Assemblage::Packager.new
    packager.package_js

    assert File.exist?(app_bundle)
    assert File.exist?(widget_bundle)

    assert File.size(app_bundle) >= 270000, "bundle_app.js looks too small?"
    assert File.size(widget_bundle) >= 330000, "bundle_widget.js looks too small?"

  ensure
    File.unlink app_bundle if File.exist?(app_bundle)
    File.unlink widget_bundle if File.exist?(widget_bundle)
  end

end
