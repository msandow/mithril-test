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

SecureRouter.get('/', (req, res)->
  setTimeout(->
    res.json({
      userId: req.session.userId
      name: 'Foobar'
    })
  , 500)
)


#OpenRouter.get('/ping', (req, res)->
#  console.log((req.session.expires - getUTCTime()))
#  if req.session?.expires && (req.session.expires - getUTCTime()) < 1
#    req.session.destroy()
#  
#  setTimeout(->
#    res.json({
#      ping: !!(req.session?.userId && req.session?.CSRF && req.session?.expires && (req.session?.expires - getUTCTime()) > 0)
#    })
#  , 500)
#)


module.exports = 
  scope: '/user'
  router: [OpenRouter, SecureRouter]