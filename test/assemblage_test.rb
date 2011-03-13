require 'test_helper'

class AssemblageTest < ActiveSupport::TestCase
  WIDGET_JSLIST = ['jquery-1.4.4.min.js', 'jquery-ui-1.8.7.custom.min.js', 'jquery.maskedinput-1.2.2.min.js', 'raphael-1.5.2.min.js', 'jquery.ba-postmessage.0.5.min.js']

  test "configuration exceptions" do
    assert_raises Assemblage::Config::Error do
      raise Assemblage::Config::Error.new("raise")
    end
  end

  test "configuration loader" do
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

  end

  test "can list files recursivesly with and without a configuration file" do
    files = Assemblage::Config.recursive_file_list(Rails.root.join("public/javascripts/widget"), "js", false)

    assert_equal WIDGET_JSLIST.size, files.size

    WIDGET_JSLIST.each do|name|
      assert files.map{|f| File.basename(f) }.include?(name), "Missing expected file: #{name}"
    end

    files = Assemblage::Config.recursive_file_list(Rails.root.join("public/javascripts/widget"), "js", true)

    assert_equal WIDGET_JSLIST.size, files.size

    WIDGET_JSLIST.each do|name|
      assert files.map{|f| File.basename(f) }.include?(name), "Missing expected file: #{name}"
    end

  end

  test "assemblage assembles with config" do
    assemblage_package
  end

  test "assemblage assembles without config" do
    ENV["ASSEMBLAGE_NO_CONFIG"] = "1"
    assemblage_package
    ENV.delete("ASSEMBLAGE_NO_CONFIG")
  end

  def assemblage_package
    File.unlink "test/public/javascripts/bundle_app.js" if File.exist?("test/public/javascripts/bundle_app.js")
    File.unlink "test/public/javascripts/bundle_widget.js" if File.exist?("test/public/javascripts/bundle_widget.js")

    packager = Assemblage::Packager.new
    packager.package_js

    assert File.exist?("test/public/javascripts/bundle_app.js")
    assert File.exist?("test/public/javascripts/bundle_widget.js")

    assert File.size("test/public/javascripts/bundle_app.js") >= 281196
    assert File.size("test/public/javascripts/bundle_widget.js") >= 342264 

  ensure
    File.unlink "test/public/javascripts/bundle_app.js" if File.exist?("test/public/javascripts/bundle_app.js")
    File.unlink "test/public/javascripts/bundle_widget.js" if File.exist?("test/public/javascripts/bundle_widget.js")
  end

end
