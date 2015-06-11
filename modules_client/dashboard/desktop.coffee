secureAjax = require('./../_utilities/secureAjax.coffee')
header = require('./../_components/header/desktop.coffee')

module.exports = ->
  m.ready(->
  
    Dashboard = 
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
        return null if not ctx.viewReady
        [
          header()
          m.el('h1',"Hello user " + ctx.name)
        ]
        

      route: '/dashboard'

    m.register(Dashboard)
  
  )