express = require('express')
Boxy = require('BoxyBrown')
uuid = require('uuid')

serverShared = "#{__dirname}/../../modules_server/_utilities"
SecureRouter = require("#{serverShared}/authenticated_route.coffee")()


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
  router: [SecureRouter]