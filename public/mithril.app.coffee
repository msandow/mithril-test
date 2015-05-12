"use strict"
window.m = window.m or {}
m = window.m

Object.defineProperties(m,
  'query':
    enumerable: true
    configurable: false
    writable: false
    value: (selector) ->
      document.querySelector.apply(document, [selector])
  
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
      
      m.route(DOMRoot, '/', routeHash) if Object.keys(routeHash).length
      
  
  'component':
    enumerable: false
    configurable: false
    writable: false
    value: (module, args, extra) ->
      module.view.bind(this, new module.controller(args, extra), args, extra)


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
    
        requestOptions = 
          method: conf.type
          url: conf.url
          background: true
          data: conf.data
          extract: (xhr, xhrOptions) ->
            if xhrOptions.method is 'HEAD' then xhr.getAllResponseHeaders() else xhr.responseText

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
      
      format: (ob) ->

)

formatAjaxRequest = (ob) ->
  ret = {
    type: if ob.type then ob.type.toUpperCase() else 'GET'
    url: if ob.url then ob.url else '/'
    complete: if ob.complete then ob.complete else (->)
    data: {}
  }
  
  if ['POST','PUT'].indexOf(ret.type) > -1 and typeof ob.data is 'object'
    ret.data = ob.data

  if ['GET','DELETE','HEAD'].indexOf(ret.type) > -1 and typeof ob.data is 'object'
    qs = []
    for own key, val of data
      qs.push(encodeURIComponent("#{key}=#{val}"))

    ret.url += if requestOptions.url.indexOf("?") > -1 then "&" else "?"
    ret.url += qs.join("&")
  
  ret

bindElEvents = (el, events) ->
  for own key, evt of events
    el.addEventListener(key, evt)

unbindElEvents = (el, events) ->
  for own key, evt of events
    el.removeEventListener(key, evt)
    #delete events[key]
