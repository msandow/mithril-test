express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')
fs = require('fs')

sharedFolder = "#{__dirname}/../_utilities"
publicFolder = "#{__dirname}/../../public"
clientFolder = "#{__dirname}/../../modules_client"

global.m = require("#{publicFolder}/mithril.app.coffee")
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
  Router.get("/_escaped_fragment_#{route}", (req, res)->
    fs.readFile("#{__dirname}/../../public/index.html", "utf8", (error, data)->
      html = data
        .replace(/<head>/gim, '<head>\n<base href="../"/>')
        .replace(/<!--\scontent\s-->/gim, m.toString(module, req, res))
      res.send(html)
    )
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

#Router.get('/server', (req, res)->
#  doc = m('html[lang="en"]', [
#    m.el('head', [
#      m('meta[charset="utf-8"]')
#      m('title','Server Side Mithril')
#    ])
#    m('body',{onclick: ()->alert('f')}, loginView)
#  ])
#  
#  res.writeHead(200,
#    'Content-Type': 'text/html'
#  )
#  res.end("<!doctype html>" + m.toString(doc))
#)


module.exports = 
  scope: '/'
  router: Router