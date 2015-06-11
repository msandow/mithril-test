express = require('express')


module.exports = () ->
  Router = new express.Router()

  Router.use((req, res, next)->
    #console.log('Open request', req.originalUrl)
    next()
  )
  
  Router
