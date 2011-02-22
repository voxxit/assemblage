Capistrano::Configuration.instance.load do
  namespace :assemblage do
    desc "Assemble JavaScript and CSS files"
    task :assemble, :roles => :web, :except => { :no_release => true } do
      # run the assembly locally
      system("rake assemble:all") 
 
      YAML.load_file("config/assembled.css.yml").each do|local_file|
        remote_path = release_path + "/public/stylesheets/#{File.basename(local_file)}"
        puts "#{local_file.to_s.inspect} => #{remote_path.inspect}"
        top.upload(local_file.to_s, remote_path, :via => :scp) do |channel, name, sent, total|
          print "#{sent}/#{total}\r"
        end   
        puts
      end
 
      YAML.load_file("config/assembled.js.yml").each do|local_file|
        remote_path = release_path + "/public/javascripts/#{File.basename(local_file)}"
        puts "#{local_file.to_s.inspect} => #{remote_path.inspect}"
        top.upload(local_file.to_s, remote_path, :via => :scp) do |channel, name, sent, total|
          print "#{sent}/#{total}\r"
        end
        puts
      end

      #run "cd #{release_path} && rake assemble:all RAILS_ENV=#{stage}"
    end
  end
end
