express = require('express')


module.exports = () ->
  Router = new express.Router()

  Router.use((req, res, next)->
    console.log('Auth request', req.originalUrl)
    if req.session.userId and req.session.CSRF and req.headers.csrf and (req.session.CSRF is req.headers.csrf)
      next()
    else
      res.status(401).json({message: 'Not logged in'}).end()
  )
  
  Router
