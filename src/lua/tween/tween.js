



  p.toString = function() {
      return "[Tween]";
  };


  p.clone = function() {
      throw("Tween can not be cloned.")
  };

  Tween.installPlugin = function(plugin, properties) {
      var priority = plugin.priority;
      if (priority == null) { plugin.priority = priority = 0; }
      for (var i=0,l=properties.length,p=Tween._plugins;i<l;i++) {
          var n = properties[i];
          if (!p[n]) { p[n] = [plugin]; }
          else {
              var arr = p[n];
              for (var j=0,jl=arr.length;j<jl;j++) {
                  if (priority < arr[j].priority) { break; }
              }
              p[n].splice(j,0,plugin);
          }
      }
  };
