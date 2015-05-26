"use strict"
window.m = window.m or {}
m = window.m

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
    enumerable: false
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
    enumerable: false
    configurable: false
    writable: false
    value: (module) ->
      module.controller = (->) if module.controller is undefined
      module.view = (-> return null) if module.view is undefined
      module.route = null if module.route is undefined or !module.route.length
      
      m.toRegister.push(module) if m.toRegister.indexOf(module) is -1
      
  'start':
    enumerable: false
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
    enumerable: false
    configurable: false
    writable: false
    value: (module, args, extra) ->
      module.view.bind(this, new module.controller(args, extra), args, extra)


  'refresh':
    enumerable: false
    configurable: false
    writable: false
    value: (module, args, extra) ->
      m.route(m.route())


  'el':
    enumerable: false
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
    enumerable: false
    configurable: false
    writable: false
    value: (conf) ->
      conf = formatAjaxRequest(conf)
      transport = null

      requestOptions = 
        method: conf.type
        url: conf.url
        background: true
        data: conf.data
        extract: (xhr, xhrOptions) ->
          if xhr.status is 0
            return if xhr.statusText.length then xhr.statusText else JSON.stringify(
              message: 'aborted'
            )

          if xhrOptions.method is 'HEAD' then xhr.getAllResponseHeaders() else xhr.responseText
        config: (xhr)->
          transport = xhr

          if conf.headers
            for own kk, vv of conf.headers
              xhr.setRequestHeader(kk, vv)
          xhr

      requestOptions.type = conf.cast if conf.cast

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


)

formatAjaxRequest = (ob) ->
  ret = {
    type: if ob.type then ob.type.toUpperCase() else 'GET'
    url: if ob.url then ob.url else '/'
    complete: if ob.complete then ob.complete else (->)
    data: {}
    headers: if ob.headers then ob.headers else {}
  }
  
  if ['POST','PUT'].indexOf(ret.type) > -1 and typeof ob.data is 'object'
    ret.data = ob.data

  if ['GET','DELETE','HEAD'].indexOf(ret.type) > -1 and typeof ob.data is 'object'
    qs = []
    for own key, val of data
      qs.push(encodeURIComponent("#{key}=#{val}"))

    ret.url += if requestOptions.url.indexOf("?") > -1 then "&" else "?"
    ret.url += qs.join("&")
  
  ret.cast = ob.cast if ob.cast

  ret

bindElEvents = (el, events) ->
  for own key, evt of events
    el.addEventListener(key, evt)

unbindElEvents = (el, events) ->
  for own key, evt of events
    el.removeEventListener(key, evt)
    delete events[key]