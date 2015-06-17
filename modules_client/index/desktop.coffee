module.exports = 
  view: ->
  serverController: (req, res)->
    console.log(req)
  controller: ->
    if not window.sessionStorage.getItem('currentUser')
      m.route('/login')
    else
      m.route('/dashboard')

  route: '/'