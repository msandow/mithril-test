express = require('express')
Boxy = require('BoxyBrown')

OpenRouter = require('./open_route.coffee')()
SecureRouter = require('./authenticated_route.coffee')()

OpenRouter.get('/getUsers', (req, res) ->
  setTimeout (->
    res.json(require(__dirname + '/../users.json'))
    return
  ), 1000
  return
)

OpenRouter.post('/getter', (req, res) ->
  return res.send string: req.body.id
)

SecureRouter.get('/getNumber', (req, res) ->
  #  if(req.session.user == undefined){
  #    req.session.user = '1234'
  #    console.log('No user', 'setting to', '1234')
  #  }else{
  #    console.log('Current user', 'sett to', req.session.user)
  #  }
  #session.destroy()
  setTimeout (->
    res.json number: 1
    return
  ), 1000
  return
)

#app.use('/doc', express.static(__dirname + '/doc'));

OpenRouter.use(
  express.static(__dirname + '/../public', setHeaders: (res, file, stats) ->
    if /\.map$/i.test(file) and !res.headersSent
      res.set('Content-Type', 'application/json')
    return
  )
)

module.exports = 
  scope: '/'
  router: [OpenRouter, SecureRouter]