express = require('express')
getUTCTime = require('./utils.coffee').getUTCTime

module.exports = () ->
  Router = new express.Router()

  Router.use((req, res, next)->
    #console.log('Auth request', req.originalUrl)
    if !!(req.session?.userId &&
      req.session?.CSRF &&
      req.headers.csrf &&
      req.session.CSRF is req.headers.csrf &&
      req.session?.expires &&
      req.session.expires - getUTCTime() > 0
    )
        next()
    else
      req.session.destroy()
      res.status(401).json({message: 'Not logged in'}).end()
  )
  
  Router
