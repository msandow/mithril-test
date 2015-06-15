invalidate = require('./invalidateUser.coffee')

module.exports = (configs) ->
  origCb = configs.complete or (->)
  
  configs = m.extend(configs,
    headers:
      csrf: window.sessionStorage.getItem('csrf') or ''
    complete: (error, response, xhr) ->
      if error and xhr?.status is 401
        invalidate('/login/timeout')
        return 

      origCb.apply(this, arguments)
  )
  
  m.ajax(configs)