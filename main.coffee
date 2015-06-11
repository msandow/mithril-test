express = require('express')
app = express()
bodyParser = require('body-parser')
session = require('express-session')
uuid = require('uuid')
fs = require('fs')
async = require('async')

dirPathClean = (dir)->
  dir += "/" if dir[dir.length-1] isnt "/"
  dir


addRoutes = (rte) ->
    rtr = require(rte)
    if !Array.isArray(rtr.router)
        app.use(rtr.scope, rtr.router);
      else
        for subRouter in rtr.router
          app.use(rtr.scope, subRouter)


routerIncluder = (app, root) ->
  root = dirPathClean(root)
  
  (callback) ->
    fs.readdir(root, (err, dirs)->
      dirs = dirs
        .filter((i)-> i[0] isnt '_')
        .map((i)->
          (cb)->
            full = dirPathClean(root+i) + "routes.coffee"
            fs.exists(full, (exs)->
              if exs
                addRoutes(full)
              cb()
            )
        )
      
      async.series(dirs, ()-> callback())
          
    )

module.exports = ->

  app.use(session(
    genid: (req) ->
      uuid.v4()
    cookie:
      maxAge: 2419200000
    secret: '1234567890QWERTY'
    saveUninitialized: true
    resave: true
  ))

  app.use(bodyParser.urlencoded({ extended: false }))
  app.use(bodyParser.json())
  
  async.series([
    routerIncluder(app, "#{__dirname}/modules_server/")
    routerIncluder(app, "#{__dirname}/modules_client/")
  ],
  (err, res)->
    console.log('App started')
    app.listen(8000)
  )