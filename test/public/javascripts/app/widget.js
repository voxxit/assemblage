if (!window.console || typeof(console) == 'undefined') { console = {log:function(){},error:function(){}}; }
// register a call listener.  When the widget iframe loads it will call this function
window.__widget_callbacks = [];
// see: http://feather.elektrum.org/book/src.html, doesn't work for dynamic insertion
(function(window, document, callback) {
  if (window.__esp_loader_run) { return; } // only load core esp script once 
  window.__esp_loader_run = true;

  //
  // get the last script to be loaded e.g. this script, if we're inserted into the DOM dynamically this won't work
  // in that case users will need to use __esp and __esp_call
  //
  //var scripts = document.getElementsByTagName('script');
  //var index = scripts.length - 1;
  //var self = scripts[index];
  //var script_url = self.src.replace(/widget.js.*/,"").replace(/^https?:/,'');
  //var root_url = self.getAttribute("data-url");// || "//the-primary-root-domain.com/"; XXX: we need to know this url?

  //if (root_url == '' || root_url == undefined) {
  //  console.log("root is undefined fail");
  //  return;
  //}

  var anchors = null;
  if (document.getElementsByClassName) {
    anchors = document.getElementsByClassName("esp-reserviation-widget");
  }
  else {
    var a = document.getElementsByTagName("a");
    anchors = [];
    for (var i = 0, len = a.length; i < len; ++i) {
      if (a[i].className == 'esp-reserviation-widget') { anchors.push(a[i]); }
    }
  }
  var root_url = "//" + anchors[0].getAttribute("href").replace(/http:\/\//,'').replace(/\/.*/,'') + "/";

  var d;
  var loaded = false;
  var head = document.getElementsByTagName('head')[0];

  if (window.__esp) {
    callback(window.__esp, root_url);
  }
  else {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.onload = script.onreadystatechange = function() {
      if (!loaded && (!(d = this.readyState) || d == "loaded" || d == "complete")) {
        loaded = true;
        callback((window.__esp = window.jQuery).noConflict(1), root_url); // load iframe from reservation widget URL
        window.__esp_call = callback;
      }
    }
    script.src = root_url + "javascripts/widgetux.js";
    script.async = true;
    script.defer = true;
    head.appendChild(script);
  }
// esp is jQuery, root_url is the application primary url 
})(window, document, function(esp, root_url) {
  var idprefix = "esp-frame-";
  var widget_reg = null;

  if (window.__esp_count == undefined) {
    window.__esp_count = 0;
  }

  if (widget_reg) { // additional callback invoked directly
    enableWidgets(esp); 
  }
  else {
    console.log("run");
    // first time dom ready
    esp(coreInit);
  }

  function enableWidgets($) {
    $("a.esp-reserviation-widget").each(function() {
      var id = idprefix + __esp_count++;
      var widget_id = $(this).data("id");
      var widget_href_id = $(this).attr("href").replace(/.*(\d)$/,"$1");
      if (widget_id != widget_href_id) {
        console.log("warning: possibly incorrect embed code! data-id=" + widget_id + " != " + widget_href_id);
      }

      if (!widget_reg["widget_" + widget_id]) {
        widget_reg["widget_" + widget_id] = [];
      }
      widget_reg["widget_" + widget_id].push(id);

      $(this).hide(); // hide link
      $(this).after("<div id='" + id + "'><iframe allowtransparency='true' style='border:none;overflow:hidden;height:182px;width:258px;margin:0;padding:0;' border='none' border-frame='none'" +
                    "src='" + $(this).attr("href") + "' scrolling='no' frameborder='0'></iframe></div>");

      $(this).remove(); // remove link
    });
  }

  function coreInit($) {
    console.log("coreInit");
    if (!widget_reg) { widget_reg = new Object(); }

    enableWidgets($);

    // listen for iframe resize events
    $.receiveMessage(messageHandler, window.location);

    function messageHandler(e) {
      var data = $.parseJSON(e.data);
      var ids = widget_reg["widget_" + data.id];
      if (ids) {
        for ( var i = 0, len = ids.length; i < len; ++i) {
          var id = ids[i];
          //console.log(id);
          if (id && data.width && data.height) {
            console.log("adjust width: " + data.width + ", height: " + data.height);
            $("#" + id).css({width:data.width +'px', height:data.height+'px'});
            $("#" + id + " iframe").css({width:data.width +'px', height:data.height+'px'});
            console.log("message processed for: " + id);
          }
        }
      }
      else {
        console.log("no widgets registered for ids: " + data.id);
        console.log(data);
      }
    }
  }

});
