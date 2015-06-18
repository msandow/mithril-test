secureAjax = require('./../_utilities/secureAjax.coffee')
header = require('./../_components/header/desktop.coffee')


module.exports = 
  serverController: class
    constructor: (req, res, triggerView)->
      @name = ''
      @viewReady = true
      setTimeout(=>
        @name = '___'
        triggerView(@)
      ,1000)
  
  controller: class
    constructor: ->
      @name = ''
      @viewReady = false

      secureAjax(
        method: 'GET'
        url: '/endpoint/user/'
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