express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')

sharedFolder = "#{__dirname}/../_utilities"
publicFolder = "#{__dirname}/../../public"
clientFolder = "#{__dirname}/../../modules_client"

Router = require("#{sharedFolder}/open_route.coffee")()

Router.use(Boxy.CoffeeJs(
  route: '/js/desktop.js'
  source: "#{clientFolder}/main/desktop.coffee"
  debug: true
))


Router.use(Boxy.ScssCss(
  route: '/css/desktop.css'
  source: "#{clientFolder}/main/desktop.scss"
  debug: true
))


Router.use(Boxy.CoffeeJs(
  route: '/js/mobile.js'
  source: "#{clientFolder}/main/mobile.coffee"
  debug: true
))


Router.use(Boxy.ScssCss(
  route: '/css/mobile.css'
  source: "#{clientFolder}/main/mobile.scss"
  debug: true
))

Router.use(
  express.static(publicFolder, setHeaders: (res, file, stats) ->
    if /\.map$/i.test(file) and !res.headersSent
      res.set('Content-Type', 'application/json')
    return
  )
)

module.exports = 
  scope: '/'
  router: Router