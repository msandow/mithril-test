secureAjax = require('./../../_utilities/secureAjax.coffee')
invalidate = require('./../../_utilities/invalidateUser.coffee')

module.exports = class

  constructor: ->

  logOut: (evt)=>
    evt.preventDefault()

    secureAjax(
      method: 'POST'
      url: '/endpoint/login/logout'
      complete: (error, response) =>
        invalidate()
    )
    false

  refresh: (evt)->
    evt.preventDefault()
    m.refresh()
    false