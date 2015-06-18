express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')

serverShared = "#{__dirname}/../../modules_server/_utilities"

getUTCTime = require("#{serverShared}/utils").getUTCTime

OpenRouter = require("#{serverShared}/open_route.coffee")()
SecureRouter = require("#{serverShared}/authenticated_route.coffee")()


OpenRouter.post('/login', (req, res)->
  if req.body.un is '1' and req.body.pw is '2'
    req.session.reload(->
      req.session.userId = '1234'
      req.session.expires = getUTCTime() + (1000 * 30)

      req.session.CSRF = uuid.v4() if !req.session.CSRF
      res.json(
        userId: 1234
        csrf: req.session.CSRF
      )
    )
  
  else
    res.json({message: 'Invalid'})
)

SecureRouter.post('/logout', (req, res)->
  req.session.destroy()
  res.json({})
)


module.exports = 
  scope: '/endpoint/login'
  router: [OpenRouter, SecureRouter]