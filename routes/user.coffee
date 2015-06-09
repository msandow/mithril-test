express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')

OpenRouter = require('./open_route.coffee')()
SecureRouter = require('./authenticated_route.coffee')()

OpenRouter.post('/login', (req, res)->
  if req.body.un is '1' and req.body.pw is '2'
    req.session.userId = '1234'

    req.session.CSRF = uuid.v4() if !req.session.CSRF
    res.json(
      userId: 1234
      csrf: req.session.CSRF
    )
  
  else
    res.json({message: 'Invalid'})
)


SecureRouter.post('/logout', (req, res)->
  req.session.destroy()
  res.json({})
)



OpenRouter.get('/ping', (req, res)->
  setTimeout(->
    res.json({
      ping: !!(req.session.userId && req.session.CSRF)
    })
  , 500)
)


module.exports = 
  scope: '/user'
  router: [OpenRouter, SecureRouter]