express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')

sharedFolder = "#{__dirname}/../_utilities"
publicFolder = "#{__dirname}/../../public"
clientFolder = "#{__dirname}/../../modules_client"

Router = require("#{sharedFolder}/open_route.coffee")()

Router.use(Boxy.CoffeeJs(
  route: '/js/app2.js'
  source: "#{clientFolder}/main/desktop.coffee"
  debug: true
))


Router.use(Boxy.ScssCss(
  route: '/css/desktop.css'
  source: "#{clientFolder}/main/desktop.scss"
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