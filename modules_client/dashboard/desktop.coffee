secureAjax = require('./../_utilities/secureAjax.coffee')
header = require('./../_components/header/desktop.coffee')


module.exports = 
  controller: class
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

  view: (ctx) ->
    return m.el('span','loading...') if not ctx.viewReady
    [
      header()
      m.el('h1',"Hello user " + ctx.name)
    ]


  route: '/dashboard'