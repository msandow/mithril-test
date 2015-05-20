express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')

Router = require('./open_route.coffee')()

Router.use(Boxy.CoffeeJs(
  route: '/js/app.js'
  source: __dirname + "/../public/pack.coffee"
  debug: true
))


#app.use(Boxy.Tokenized({
#  route: '/index_4.html',
#  source: __dirname + "/public/index_4.html",
#  debug: true,
#  tokens: {
#    token: new Date().getTime()
#  }
#}));


Router.get('/index_4.html', (req, res)->
  req.session.CSRF = uuid.v4() if !req.session.CSRF

  
  Boxy.TokenReplacer(__dirname + '/../public/index_4.html',
    csrf: req.session.CSRF
  ,
    (err, data)->
      return res.status(500).send(null) if err

      res.writeHead(200,
        'Content-Type': 'text/html'
      )
      res.end(data)
  )
)


Router.use(Boxy.ScssCss(
  route: '/css/app.css'
  source: __dirname + "/../public/pack.scss"
  debug: true
))


module.exports = Router