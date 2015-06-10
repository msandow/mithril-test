express = require('express')

getUTCTime = ()->
  now = new Date()
  now_utc = new Date(now.getTime() + now.getTimezoneOffset() * 60000)
  now.getTime()

module.exports = () ->
  Router = new express.Router()

  Router.use((req, res, next)->
    console.log('Auth request', req.originalUrl)
    if !!(req.session?.userId && req.session?.CSRF && req.session?.expires && req.headers.csrf &&
      (req.session?.expires - getUTCTime()) > 0 && req.session.CSRF is req.headers.csrf)
        next()
    else
      req.session.destroy()
      res.status(401).json({message: 'Not logged in'}).end()
  )
  
  Router
