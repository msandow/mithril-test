secureAjax = require('./../_utilities/secureAjax.coffee')

module.exports = class
  constructor: ->
    @name = ''
    @viewReady = false

    secureAjax(
      method: 'GET'
      url: '/user/'
      complete: (error, response)=>
        @name = response.name
        @viewReady = true
    )