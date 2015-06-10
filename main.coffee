express = require('express')
app = express()
bodyParser = require('body-parser')
session = require('express-session')
uuid = require('uuid')

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

  for router in [ require(__dirname + '/routes/boxy.coffee'),
    require(__dirname + '/routes/user.coffee') ]
      if !Array.isArray(router.router)
        app.use(router.scope, router.router);
      else
        for subRouter in router.router
          app.use(router.scope, subRouter)


  app.listen(8000)