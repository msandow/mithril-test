"use strict"

#
# @nodoc
#
isObject = (v) ->
  typeof v is 'object' and not Array.isArray(v) and v isnt null

#
# @nodoc
#
selectorMatches = (el, selector) ->
  method = el.matches or el.msMatchesSelector or el.mozMatchesSelector or el.webkitMatchesSelector or el.oMatchesSelector or false
  if method then method.apply(el, [selector]) else false

# Create a boiler-plate Mithril module with all the default module properties.
#
# @param  {Object} configs constructor object with optional path, name, model, controller and view properties
# @option configs {String} path the URL route path to the module
# @option configs {String} name the name of the module as used when importing it into another module
# @option configs {Object} model the model object describing the properties in the model
# @option configs {Function} controller the module controller function
# @option configs {Function} view the module view function
# @return {Object} a module object with path, name, model, controller and view properties extended from the configs
#
create = (configs = {}) ->
  o = {}
  
  mergeArray = (dest, source) ->
    dest.length = source.length
    #dest.splice(source.length, dest.length)
    
    for item, idx in source
      if typeof item is 'object' and !Array.isArray(item)
        dest[idx] = {} if dest[idx] is undefined
        mergeObject(dest[idx], item)
      else if Array.isArray(item)
        dest[idx] = [] if dest[idx] is undefined
        mergeArray(dest[idx], item)
      else
        dest[idx] = item
  
  mergeObject = (dest, source) ->
    for own kk, vv of source
      if typeof vv is 'object' and !Array.isArray(vv)
        mergeObject(dest[kk], source[kk])
      else if Array.isArray(vv)
        mergeArray(dest[kk], source[kk])
      else
        dest[kk] = source[kk]

    for own kk, vv of dest when source[kk] is undefined
      delete desk[kk]
  
  resetTo = new (configs.model or (->))()
  
  Object.defineProperties(o,
    path:
      configurable: false
      enumerable: true
      writable: false
      value: configs.path or null
    unload:
      configurable: false
      enumerable: false
      writable: false
      value: configs.unload or (->)
    view:
      configurable: false
      enumerable: false
      writable: false
      value: configs.view or (-> null)
    controller:
      configurable: false
      enumerable: false
      writable: false
      value: configs.controller or (->)
    name:
      configurable: false
      enumerable: true
      writable: false
      value: configs.name or null
    model:
      configurable: false
      enumerable: false
      writable: true
      value: new (configs.model or (->))()
    reset: 
      configurable: false
      enumerable: false
      writable: false
      value: ()->
        m.startComputation()
        mergeObject(o.model, resetTo)
        m.endComputation()
    bookmark:
      configurable: false
      enumerable: false
      writable: false
      value: ()->
        mergeObject(resetTo, o.model)
    serialize: 
      configurable: false
      enumerable: true
      writable: false
      value: ()->
        JSON.stringify(o.model)
    events:
      configurable: false
      enumerable: true
      writable: false
      value: Object.preventExtensions(configs.events or {})
  )

  Object.preventExtensions(o)

#
# @nodoc
#
m.create = create

#
# @nodoc
#
appModules = []

# Register a new module with the application
#
# @param  {Object} module a module object with a signature matching that created by the {boiler boiler method}
# @return {Object} a pointer back to the Mithril m object
#
register = (module = m.create()) ->
  appModules.push(module)
  module

#
# @nodoc
#
m.register = register

#
# @nodoc
#
imported = {}

#
# @nodoc
#
m.withAttachedEvents = []

#
# @nodoc
#
m.withCapturedEvents = []

#
# @nodoc
#
removeEl = (node) ->
  node.parentNode.removeChild(node) if node.parentNode
  return

#
# @nodoc
#
defaultUnloader = (root) ->
  imported = {}
  detachAllEvents(root)
  uncaptureAllEvents()
  return

#
# @nodoc
#
detachAllEvents = (root) ->
  idx = m.withAttachedEvents.length
  el = null
  
  while idx--
    el = m.withAttachedEvents[idx]
    
    if el and (root.contains(el) or not document.body.contains(el))
      for own ok, f of el.eventsMaps
        el.removeEventListener(ok, f)

    removeEl(el) unless document.body.contains(el)
    m.withAttachedEvents.splice(idx, 1)
  
  return

#
# @nodoc
#
uncaptureAllEvents = () ->
  idx = m.withCapturedEvents.length
  el = null
  
  while idx--
    el = m.withCapturedEvents[idx]

    for own hash, func of el.captureEventsMaps
      [full, evt, spaces, selector] = hash.match(/(\w+)([\s\t]+)(\w+)/i)
      captureOff(el, selector, evt)
    
     m.withCapturedEvents.splice(idx, 1)

  return

#
# @nodoc
#
attachEventsToElement = (el, evts) ->
  el.eventsMaps = el.eventsMaps or {}

  for own key, evt of evts
    if el.eventsMaps[key]?
      el.removeEventListener(key, el.eventsMaps[evt])

    el.eventsMaps[key] = evt
    el.addEventListener(key, el.eventsMaps[key])
    
  m.withAttachedEvents.push(el) if m.withAttachedEvents.indexOf(el) is -1
  
  return

# Bind a global event to an element and inspect for those events on sub-elements
#
# @param  {Element} parent DOM element to listen and inspect on
# @param {String} event string name of the event to listen for
# @param {String} selector string selector for sub-elements to listen for events from
# @param {Function} event function to fire
#
captureOn = (el, evt, selector, func) ->
  el.captureEventsMaps = el.captureEventsMaps or {}
  hash = evt + ' ' + selector
  
  if el.captureEventsMaps[hash] is undefined
    console.log('capture',evt,selector)
    captureFunc = (evt) ->
      if selectorMatches(evt.target, selector)
        m.startComputation()
        func.apply(evt.target,[evt])
        m.endComputation()

    el.captureEventsMaps[hash] = captureFunc
    el.addEventListener(evt, captureFunc, true)
    
    m.withCapturedEvents.push(el) if m.withCapturedEvents.indexOf(el) is -1
  return
  
#
# @nodoc
#
m.on = captureOn

# Remove a previous global event to an element and inspect for those events on sub-elements
#
# @param  {Element} parent DOM element to listen and inspect on
# @param {String} selector string selector for sub-elements to listen for events from
# @param {String} event string name of the event to listen for
#
captureOff = (el, selector, evt) ->
  hash = evt + ' ' + selector
  if el.captureEventsMaps and el.captureEventsMaps[hash]
    el.removeEventListener(evt, el.captureEventsMaps[hash], true)
    delete el.captureEventsMaps[hash]
  return


#
# @nodoc
#
m.off = captureOff

# Import an existing registered module, by name, into the view of another module. Useful for partials.
#
# @param  {String} module the name property of the registered module to import
# @return {Object} an element or array of elements from the imported module's view, or null if the name matches no module
#
importModule = (module) ->
  buildImported = (mod, cacheKey) ->
    #mod.reset()
    imp = new mod.controller()
    imported[cacheKey] = imp
    imp

  moduleName = if module.indexOf('.') > -1 then module.substr(0, module.indexOf('.')) else module
  found = getModule(moduleName)

  if found
    cont = if imported[moduleName] then imported[moduleName] else buildImported(found, moduleName)
    return found.view.apply(found, [cont])
    
  return null

#
# @nodoc
#
m.importModule = importModule


# Return a reference to a module registered with register
#
# @param  {String} module the name module to get
# @return {Object} the module, if found, or null if not
#
getModule = (module) ->
  if typeof module is 'string'
    found = appModules.filter((r) ->
      r.name is module
    )

    return found[0] or null
  else
    for m in appModules
      return m if m is module
    
    return null

#
# @nodoc
#
m.getModule = getModule

# A proxy for the Mithril m() method so that events are wired up so as to be destroyed properly on module unload
#
# @overload el(tag, children)
#   A proxy for the Mithril m() method so that events are wired up so as to be destroyed properly on module unload
#   @param  {String} tag the tag name of the HTML element to create, or a default of div
#   @param {Array} children nested children elements, each created by m.el() or m()
#   @return {Object} a virtual DOM element to be created
#
# @overload el(tag, attributes, children)
#   A proxy for the Mithril m() method so that events are wired up so as to be destroyed properly on module unload
#   @param  {String} tag the tag name of the HTML element to create, or a default of div
#   @param  {Object} a hash of all HTML attributes, on* events to bind, or the optional config tag {http://lhorie.github.io/mithril/mithril.html#accessing-the-real-dom-element}
#   @param {Array} children nested children elements, each created by m.el() or m()
#   @return {Object} a virtual DOM element to be created
#
el = (str, hashOrChildren, children) ->
  eventHash = {}
  if children isnt `undefined`
    for own key, val of hashOrChildren
      if /^on[A-Za-z]/.test(key) and typeof val is 'function'
        eventHash[key.substring(2)] = ((f) ->
          (evt) ->
            m.startComputation()
            f(evt)
            m.endComputation()
            return  
        )(val)
        
        delete hashOrChildren[key]

    o_config = hashOrChildren.config or (->)

    hashOrChildren.config = (element, isInitialized, context) ->
      attachEventsToElement(element, eventHash) unless isInitialized
      o_config.apply(this, [element, isInitialized, context])
      return
    
    return m(str, hashOrChildren, children)
    
  domEl = m(str, hashOrChildren)
  
  domEl.append = (newEl) ->
    domEl.children.push(newEl)
    domEl
  
  domEl

#
# @nodoc
#
m.el = el

#
# @nodoc
#
buildController = (route, DOMRoot) ->
  ->
    #route.reset()
    route.controller.call(@)
    
    for own hash, func of route.events
      [full, evt, spaces, selector] = hash.match(/(\w+)([\s\t]+)(\w+)/i)
      m.on(document.body, evt, selector, func)
    
    if DOMRoot
      ou = route.unload or (->)
      @onunload = () ->
        defaultUnloader(DOMRoot)
        ou.call(route)

    Object.preventExtensions(@)


# Take all modules added with register(), and initialize all the routes so the app can be used
#
# @param  {Object} DOMRoot the HTML DOM element to render all routed modules inside of
#
buildRoutes = (DOMRoot) ->
  routeHash = {}
  nameHash = {}
  empty = true
  
  m.route.mode = "hash"

  ((route)->
    if nameHash[route.name] isnt undefined
      console.warn('Module',route.name,'already exists')
      return

    empty = false
    nameHash[route.name] = true
    if Array.isArray(route.path)
      for subroute in route.path
        routeHash[subroute] = 
          controller: buildController(route, DOMRoot)
          view: route.view.bind(route)
    else
      routeHash[route.path] = 
        controller: buildController(route, DOMRoot)
        view: route.view.bind(route)

  )(route) for route in appModules when route.path and route.path.length

  if routeHash['/'] is undefined
    console.error('Missing base route with path "/"')
    return

  m.route(DOMRoot, '/', routeHash) unless empty


#
# @nodoc
#
m.buildRoutes = buildRoutes


# Take all modules added with register(), and initialize all the routes so the app can be used
#
# @param  {Object} DOMRoot the HTML DOM element to render the module inside of
# @param  {String} module the name property of the registered module to import
#
renderModule = (DOMRoot, moduleName) ->
  found = getModule(moduleName)
  if found
    m.module(DOMRoot, 
      controller: buildController(found, DOMRoot)
      view: found.view.bind(found)
    )

#
# @nodoc
#
m.renderModule = renderModule


# A helper for all types of ajax requests: m.ajax.get(), m.ajax.delete(), m.ajax.post(), m.ajax.put(), m.ajax.head(), each non-blocking unlike the m.request() method
#
# @param  {String} url the url to send the request to
# @param  {Object} data the post variables for POST or PUT requests, or the querystring for GET, DELETE and HEAD requests
# @param  {Function} callback the function to call on request completion with a signature of (error, response)
#
ajax =
  make: (type, url, data, cb) ->
    requestOptions = 
      method: type.toUpperCase()
      url: url
      background: true
      extract: (xhr, xhrOptions) ->
        if xhrOptions.method is 'HEAD' then xhr.getAllResponseHeaders() else xhr.responseText
    
    if requestOptions.method is 'POST' or requestOptions.method is 'PUT'
      requestOptions.data = data
    
    if requestOptions.method is 'GET' or requestOptions.method is 'DELETE' or requestOptions.method is 'HEAD'
      qs = []
      for own key, val of data
        qs.push(encodeURIComponent("#{key}=#{val}"))
      
      requestOptions.url += if requestOptions.url.indexOf("?") > -1 then "&" else "?"
      requestOptions.url += qs.join("&")

    m.request(requestOptions)
      .then(
        (response) ->
          m.startComputation()
          cb(null, response)
          m.endComputation()
        ,
        (response) ->
          m.startComputation()
          cb(response, null)
          m.endComputation()
      )
  
  get: (url, data = {}, cb) ->
    @make('GET', url, data, cb)

  delete: (url, data = {}, cb) ->
    @make('DELETE', url, data, cb)

  post: (url, data = {}, cb) ->
    @make('POST', url, data, cb)

  put: (url, data = {}, cb) ->
    @make('PUT', url, data, cb)

  head: (url, data = {}, cb) ->
    @make('HEAD', url, data, cb)

#
# @nodoc
#
m.ajax = ajax