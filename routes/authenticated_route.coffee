express = require('express')


module.exports = () ->
  Router = new express.Router()

  Router.use((req, res, next)->
    console.log('Auth request', req.originalUrl)
  
    if req.session.user and req.session.CSRF and false
      next()
    else
      res.status(401).send(null)
  )
  
  Router
