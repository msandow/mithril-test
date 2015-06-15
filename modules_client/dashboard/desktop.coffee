header = require('./../_components/header/desktop.coffee')
desktopController = require('./controller.coffee')

module.exports = ->
  m.ready(->
  
    Dashboard = 
      controller: class extends desktopController

      view: (ctx) ->
        return null if not ctx.viewReady
        [
          header()
          m.el('h1',"Hello user " + ctx.name)
        ]
        

      route: '/dashboard'

    m.register(Dashboard)
  
  )