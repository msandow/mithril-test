express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')
fs = require('fs')

sharedFolder = "#{__dirname}/../_utilities"
publicFolder = "#{__dirname}/../../public"
clientFolder = "#{__dirname}/../../modules_client"

desktopStaticApp = require("#{clientFolder}/main/desktop.coffee")

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


buildStaticRoute = (route, module) ->
  Router.get(route, (req, res)->
    m.toString(module, (html)->
      Boxy.TokenReplacer("#{__dirname}/../../public/index.html", {
        compiledHtml: html
        keywords: 'foo, bar'
        description: 'my site'
      }, (err, data)->
        res.end(err or data)
      )
    , req, res)
  )

for deskTopModule in desktopStaticApp()
  if Array.isArray(deskTopModule.route)
    for subRoute in deskTopModule.route
      buildStaticRoute(subRoute, deskTopModule)
  else
    buildStaticRoute(deskTopModule.route, deskTopModule)


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