# Assemblage bundle configuration
closure :whitespace, :quiet # (:simple, :advanced, :whitespace), (:quiet, :default, :verbose)
java "/usr/bin/java"

# define the order for each bundle
bundle :widget, :js, 'jquery-1.4.4.min.js', 'jquery-ui-1.8.7.custom.min.js', 'jquery.maskedinput-1.2.2.min.js', 'raphael-1.5.2.min.js', 'jquery.ba-postmessage.0.5.min.js'
bundle :widget, :css, 'jquery-ui-1.8.7.custom.css'

bundle :app, :js, 'jquery-1.4.4.min.js', 'jquery-ui-1.8.7.custom.min.js', 'farbtastic'
bundle :app, :css, 'jquery-ui-1.8.7.custom.css', 'farbtastic'
