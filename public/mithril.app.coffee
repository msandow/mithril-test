"use strict"
window.m = window.m or {}
m = window.m



formatAjaxRequest = (ob) ->
  ob.method = ob.method.toUpperCase()
  ob.complete = (->) if typeof ob.complete isnt 'function'
  ob.background = true
  
  if ['HEAD','DELETE','GET'].indexOf(ob.method) > -1 and typeof ob.data is 'object' and Object.keys(ob.data).length
    qs = []
    for own key, val of ob.data
      qs.push(encodeURIComponent(key) + "=" + encodeURIComponent(val))

    ob.url += if ob.url.indexOf("?") > -1 then "&" else "?"
    ob.url += qs.join("&")
    ob.data = {}

  ob



bindElEvents = (el, events) ->
  for own key, evt of events
    el.addEventListener(key, evt)



unbindElEvents = (el, events) ->
  for own key, evt of events
    el.removeEventListener(key, evt)
    delete events[key]



headersToJson = (str) ->
  ob = {}
  
  for line in str.split("\n")
    ob[line.substring(0, line.indexOf(":")).trim()] = line.substring(line.indexOf(":")+1).trim()
  
  JSON.stringify(ob)



Object.defineProperties(m,
  'query':
    enumerable: true
    configurable: false
    writable: false
    value: (selectorOrElement, selector) ->
      if selector is undefined
        q = document.querySelectorAll.apply(document, [selectorOrElement])
        return if q.length is 1 then q[0] else q
      else
        q = selectorOrElement.querySelectorAll.apply(selectorOrElement, [selector])
        return if q.length is 1 then q[0] else q



  'matches':
    enumerable: true
    configurable: false
    writable: false
    value: (el, selector) ->
      method = el.matches or el.msMatchesSelector or el.mozMatchesSelector or el.webkitMatchesSelector or el.oMatchesSelector or false
      if method then method.apply(el, [selector]) else false



  'toRegister':
    enumerable: false
    configurable: false
    writable: false
    value: []



  'readyQueue':
    enumerable: false
    configurable: false
    writable: false
    value: []



  'ready':
    enumerable: true
    configurable: false
    writable: false
    value: (cb) ->
      if document.readyState is "complete"
        cb()
      else
        if !m.readyQueue.length
          window.onload = ()->
            while m.readyQueue.length
              (m.readyQueue.shift())()

        m.readyQueue.push(cb)



  'register':
    enumerable: true
    configurable: false
    writable: false
    value: (module) ->
      module.controller = (->) if module.controller is undefined
      module.view = (-> return null) if module.view is undefined
      module.route = null if module.route is undefined or !module.route.length
      
      m.toRegister.push(module) if m.toRegister.indexOf(module) is -1



  'start':
    enumerable: true
    configurable: false
    writable: false
    value: (DOMRoot) ->
      m.route.mode = "hash"
      routeHash = {}
    
      while m.toRegister.length
        currMod = m.toRegister.shift()

        if currMod.route
          if Array.isArray(currMod.route)
            for subroute in currMod.route
              routeHash[subroute] = currMod
          else
            routeHash[currMod.route] = currMod
      
      if routeHash['/'] is undefined
        return console.warn("No root \"/\" route defined")
      
      m.route(DOMRoot, '/', routeHash) if Object.keys(routeHash).length



  'component':
    enumerable: true
    configurable: false
    writable: false
    value: (module, args, extra) ->
      module.view.bind(this, new module.controller(args, extra), args, extra)



  'refresh':
    enumerable: true
    configurable: false
    writable: false
    value: (module, args, extra) ->
      m.route(m.route())



  'el':
    enumerable: true
    configurable: false
    writable: false
    value: (str, hashOrChildren, children) ->
      hasEvents = false
      
      if children isnt undefined
        for own kk, vv of hashOrChildren when /^on[A-Za-z]/.test(kk) and typeof vv is 'function'
          hasEvents = {} if typeof hasEvents is 'boolean'
          hasEvents[kk.substring(2).toLowerCase()] = ((f)->
            () ->
              m.startComputation()
              f.apply(this, arguments)
              m.endComputation()
          )(vv)
          delete hashOrChildren[kk] 
        
        if hasEvents
          o_config = hashOrChildren.config or (->)

          hashOrChildren.config = (element, isInitialized, context) ->
            o_config.apply(this, [element, isInitialized, context])

            if !isInitialized
              context.eventMap = hasEvents
              bindElEvents(element, context.eventMap)

            o_unload = context.onunload or (->)
            context.onunload = () ->
              o_unload()                
              unbindElEvents(element, context.eventMap)


      m(str, hashOrChildren, children)
      


  'ajax':
    enumerable: true
    configurable: false
    writable: false
    value: (conf) ->
      requestOptions = formatAjaxRequest(conf)
      transport = null
      
      requestOptions.extract = (xhr, xhrOptions) ->
        if xhr.status is 0
          return if xhr.statusText.length then xhr.statusText else JSON.stringify(
            message: 'aborted'
          )

        if xhr.status is 404
          return JSON.stringify(
            message: xhr.responseText or xhr.statusText
          )

        if xhrOptions.method is 'HEAD' then headersToJson(xhr.getAllResponseHeaders()) else xhr.responseText
        
      requestOptions.config = (xhr)->
        transport = xhr

        if conf.headers
          for own kk, vv of conf.headers
            xhr.setRequestHeader(kk, vv)
        xhr
      

      m.request(requestOptions)
        .then(
          (response) ->
            m.startComputation()
            conf.complete(null, response)
            m.endComputation()
          ,
          (response) ->
            m.startComputation()
            conf.complete(response, null)
            m.endComputation()
        )
    
      transport



  'extend':
    enumerable: true
    configurable: false
    writable: false
    value: (extend = {}, using = {}) ->
      for own kk, vv of using
        if typeof vv is 'object' and not Array.isArray(vv) and typeof extend[kk] is 'object' and not Array.isArray(extend[kk])
          extend[kk] = m.extend(extend[kk], vv)
        else
          extend[kk] = vv
      
      extend


  'multiClass':
    enumerable: true
    configurable: false
    writable: false
    value: (classes...)->
      classes.reduce (Parent, Child)->
        class Child_Projection extends Parent
          constructor: ->
            # Temporary replace Child.__super__ and call original `constructor`
            child_super = Child.__super__
            Child.__super__ = Child_Projection.__super__
            Child.apply(@, arguments)
            Child.__super__ = child_super

            # If Child.__super__ not exists, manually call parent `constructor`
            unless child_super?
              super()

        # Mixin prototype properties, except `constructor`
        for own key  of Child::
          if Child::[key] isnt Child
            Child_Projection::[key] = Child::[key]

        # Mixin static properties, except `__super__`
        for own key  of Child
          if Child[key] isnt Object.getPrototypeOf(Child::)
            Child_Projection[key] = Child[key]

        Child_Projection
)