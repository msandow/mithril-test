links = require('../_components/links/desktop.coffee')

module.exports = 
  serverController: class
    constructor: (req, res, triggerView)->
      triggerView(@)
    
  controller: class
    constructor: ->
      if not window.sessionStorage.getItem('currentUser')
        m.route('/login')
      else
        m.route('/dashboard')

  view: ->
    [
      m.el('h1','Weclome to our site')
      links.internalLink('Please log in', {href: '/login'})
    ]

  route: '/'