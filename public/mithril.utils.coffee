"use strict"
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
  o = 
    path: configs.path or null
    name: configs.name or ""
    view: configs.view or (-> null)
    controller: configs.controller or (->)

  switcher = (ob, k, v) ->
    if ['number','string','boolean','null','undefined'].indexOf(typeof v) > -1 or Array.isArray(v)
      Object.defineProperty(ob, '___' + k,
        configurable: false
        enumerable: false
        writable: false
        value: m.prop(v)
      )
      
      Object.defineProperty(ob, k,
        configurable: false
        enumerable: true
        writable: false
        value: (v) ->
          if v is undefined
            return ob['___' + k]()
          else
            if typeof v is 'object'
              if not Array.isArray(v)
                ob['___' + k](objectCreator(v))
              else
                ob['___' + k](v.map((ii)->
                  if typeof ii is 'object' and not Array.isArray(ii)
                    return objectCreator(ii)
                  else
                    return ii
                ))
            else
              ob['___' + k](v)
      )
    else if typeof v is 'function'
      ob[k] = v
    else if typeof v is 'object'
      ob[k] = m.prop(objectCreator(v))
  
  objectCreator = (ob) ->
    _o = {}

    for own k,v of ob
      switcher(_o, k, v)
    
    Object.preventExtensions(_o)
    
  cloner = (ob) ->
    if Array.isArray(ob)
      newob = []
      for v in ob
        if typeof v is 'object'
          newob.push(cloner(v))
        else
          newob.push(v)
    else
      newob = {}
      for own k, v of ob
        if typeof v is 'object'
          newob[k] = cloner(v)
        else
          newob[k] = v
        
    newob
    
  replace = (destination, source) ->
    for own k, v of source when destination[k] isnt undefined
      if ['number','string','boolean','null','undefined'].indexOf(typeof v) > -1 or Array.isArray(v)
        destination[k](v)
      else if typeof v is 'object'
        destination[k] = replace(destination[k], v)
      
  o.reset = ()->
    o.model = configs.model

  Object.defineProperty(o, '___model',
    configurable: false
    enumerable: false
    writable: true
    value: objectCreator(cloner(configs.model or {}))
  )
  
  Object.defineProperty(o, 'model',
    configurable: false
    enumerable: true
    set: (v)->
      o.___model = objectCreator(cloner(v))
    get: ()->
      o.___model
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
addModule = (module = m.boiler()) ->
  appModules.push(module)
  m

#
# @nodoc
#
m.addModule = addModule

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
removeEl = (node) ->
  node.parentNode.removeChild(node) if node.parentNode
  return

#
# @nodoc
#
defaultUnloader = (root) ->
  detachAllEvents(root)
  return

#
# @nodoc
#
detachAllEvents = (root) ->
  for el, idx in m.withAttachedEvents when el and (root.contains(el) or not document.body.contains(el))
    for own ok, f of el.eventsMaps
      el.removeEventListener(ok, f)
    removeEl(el) unless document.body.contains(el)
    m.withAttachedEvents[idx] = null
  
  m.withAttachedEvents = m.withAttachedEvents.filter((e)->
    e isnt null
  )

  return

#
# @nodoc
#
attachEvents = (el, evts) ->
  el.eventsMaps = el.eventsMaps or {}

  for own key, evt of evts
    if el.eventsMaps[key]?
      el.removeEventListener(key, el.eventsMaps[evt])

    el.eventsMaps[key] = evt
    el.addEventListener(key, el.eventsMaps[key])
    
  if m.withAttachedEvents.indexOf(el) is -1
    m.withAttachedEvents.push(el)
  
  return

# Import an existing registered module, by name, into the view of another module. Useful for partials.
#
# @param  {String} module the name property of the registered module to import
# @return {Object} an element or array of elements from the imported module's view, or null if the name matches no module
#
importModule = (module) ->
  buildImported = (mod, cacheKey) ->
    imp = new mod.controller()
    imported[cacheKey] = imp
    imp

  moduleName = if module.indexOf('.') > -1 then module.substr(0, module.indexOf('.')) else module
  found = getModule(moduleName)

  if found
    cont = imported[module] or buildImported(found, module)
    return found.view.apply(found, [cont])
    
  return null

#
# @nodoc
#
m.importModule = importModule


# Return a reference to a module registered with addModule
#
# @param  {String} module the name module to get
# @return {Object} the module, if found, or null if not
#
getModule = (module) ->
  found = appModules.filter((r) ->
    r.name is module
  )

  found[0] or null

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
      attachEvents(element, eventHash) unless isInitialized
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
    route.reset()
    route.controller.call(@)
    if DOMRoot
      ou = @onunload or (->)
      @onunload = () ->
        defaultUnloader(DOMRoot)
        ou()

    Object.preventExtensions(@)


# Take all modules added with addModule(), and initialize all the routes so the app can be used
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
    routeHash[route.path] = 
      controller: buildController(route, DOMRoot)
      view: route.view.bind(route)

  )(route) for route in appModules when route.path

  if routeHash['/'] is undefined
    console.error('Missing base route with path "/"')
    return

  m.route(DOMRoot, '/', routeHash) unless empty


#
# @nodoc
#
m.buildRoutes = buildRoutes


# Take all modules added with addModule(), and initialize all the routes so the app can be used
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