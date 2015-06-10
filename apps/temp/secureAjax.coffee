module.exports = (configs) ->
  configs.headers  = {} if configs.headers is undefined
  configs.headers.csrf = window.sessionStorage.getItem('csrf') or ''
  origCb = configs.complete or (->)
  configs.complete = (error, response, xhr) ->
    if error and xhr?.status is 401
      m.route('/login/timeout')
      return 

    origCb.apply(this, arguments)

  m.ajax(configs)