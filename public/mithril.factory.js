(function(m){
  var selectorMatches = function(el, selector){
    var method = el.matches || el.msMatchesSelector || el.mozMatchesSelector || el.webkitMatchesSelector || el.oMatchesSelector;
    return (method ? method.apply(el,[selector]) : false);
  };
  
  var removeEl = function(node){
    if (node.parentNode) {
      node.parentNode.removeChild(node);
    }
  };
  
  var defaultUnloader = function(){
    detachAllEvents();
  };
  
  var detachAllEvents = function(){
    while(m.withAttachedEvents.length){
      var t = m.withAttachedEvents[0];
      for(var ok in t.eventsMaps){
        if(t.eventsMaps.hasOwnProperty(ok)){
          t.removeEventListener(ok, t.eventsMaps[ok]);
        }
      }
      if(!document.body.contains(t)){
        removeEl(t)
      }
      m.withAttachedEvents.splice(0,1);
    }
  };
  
  var attachEvents = function(el, evts){
    el.eventsMaps = el.eventsMaps || {};
    
    for(evt in evts){
      if(evts.hasOwnProperty(evt)){
        if(el.eventsMaps[evt] !== undefined){
          el.removeEventListener(evt, el.eventsMaps[evt]);
        }
        el.eventsMaps[evt] = evts[evt];
        el.addEventListener(evt, el.eventsMaps[evt]);
      }
    }
    
    if(m.withAttachedEvents.indexOf(el) === -1){
      m.withAttachedEvents.push(el);
    }
  };

  m.boiler = function(o){
    if(o === undefined){
      o = {};
    }
    return {
      path: o.path || null,
      name: o.name || "",
      model: o.model || function(){},
      controller: o.controller || function(model){},
      view: o.view || function(ctrl){}
    };
  };
  
  m.appRoutes = [];
  m.addRoute = function(module){
     m.appRoutes.push(module);
     return m;
  };
  m.imported = {};
  m.withAttachedEvents = [];
  
  m.import = function(module){
    var buildImported = function(mod){
      var cont = new function(){};
      cont.model = function(){};
      mod.model.call(cont.model);
      mod.controller.call(cont);
      m.imported[mod.name] = cont;
      return cont;
    };
  
    if(typeof module === 'string'){
      var found = m.appRoutes.filter(function(r){return r.name === module});
      if(found.length){
        var cont = m.imported[module] == undefined ? buildImported(found[0]) : m.imported[module];
        found[0].view.apply(found[0], [cont]);
      }
    }else if(typeof module === 'object'){
      var cont = m.imported[module.name] == undefined ? buildImported(module) : m.imported[module.name];
      module.view.apply(module, [cont]);
    }
    
    return null;
  };
  
  m.el = function(str, hashOrChildren, children){
    var eventHash = {};

    if(children !== undefined){
      var keys = Object.keys(hashOrChildren), keys_i = 0;
      while(keys_i < keys.length){
        if(/^on[A-Za-z]/.test(keys[keys_i])){
          eventHash[keys[keys_i].substring(2)] = function(f){
            return function(evt){
              m.startComputation();
              f(evt);
              m.endComputation();
            }
          }(hashOrChildren[keys[keys_i]]);
          delete hashOrChildren[keys[keys_i]];
        }
        
        keys_i++;
      }
      
      var o_config = hashOrChildren.config || function(){};
      hashOrChildren.config = function(element, isInitialized, context){
        if(!isInitialized){
          attachEvents(element, eventHash);
        }
        o_config.apply(this, [element, isInitialized, context]);
      };
      
      return m(str,hashOrChildren,children);
    }

    return m(str,hashOrChildren);
  };
  
  m.buildRoutes = function(DOMRoot){
    var routeHash = {}, i = 0, otitle = document.title, nameHash = {};
    
    m.route.mode = "hash";
    
    while(i < m.appRoutes.filter(function(r){return r.path}).length){
      if(nameHash[m.appRoutes[i].name] !== undefined){
        console.warn('Module',m.appRoutes[i].name,'already exists');
        i++;
        continue;
      }
      
      (function(r){
        nameHash[r.name] = true;
        r.model = r.model || function(){};
        
        routeHash[r.path] = {}
        routeHash[r.path].controller = function(){
          this.model = function(){};
          r.model.call(this.model);
          r.controller.call(this);
          Object.preventExtensions(this.model);

          var ou = this.onunload || function(){};
          this.onunload = function(){              
            defaultUnloader();
            ou();
          };
          
          Object.preventExtensions(this);
        };

        routeHash[r.path].view = r.view;

      }(m.appRoutes[i]))
      i++;
    }

    m.route(DOMRoot, '/', routeHash);
  };
  
  m.ajax = {
    make: function(type, url, data, cb){
      var requestOptions = {method: type.toUpperCase(), url: url, background: true,
        extract: function(xhr, xhrOptions){
          if(xhrOptions.method === 'HEAD'){
            return xhr.getAllResponseHeaders();
          }

          return xhr.responseText;
        }
      };
      if(requestOptions.method === 'POST'){
        requestOptions.data = data;
        requestOptions.serialize = JSON.stringify;
      }

      m.request(requestOptions).then(function(response){
        m.startComputation();
        cb(null, response);
        m.endComputation();
      },
      function(response){
        m.startComputation();
        cb(response, null);
        m.endComputation();
      });
    },
    get: function(url, data, cb){
      this.make('GET', url, data, cb);
    },
    delete: function(url, data, cb){
      this.make('DELETE', url, data, cb);
    },
    post:function(url, data, cb){
      this.make('POST', url, data, cb);
    },
    put:function(url, data, cb){
      this.make('PUT', url, data, cb);
    },
    head: function(url, data, cb){
      this.make('HEAD', url, data, cb);
    }
  };

}(m || {}));