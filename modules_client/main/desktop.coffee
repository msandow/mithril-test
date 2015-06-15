require('./../../public/mithril.app.coffee')
require('./../login/desktop.coffee')()
require('./../dashboard/desktop.coffee')()

m.ready(->
  Default = 
    view: ->
    controller: ->
      if not window.sessionStorage.getItem('currentUser')
        m.route('/login')
      else
        m.route('/dashboard')

    route: '/'

  m.register(Default)

  m.start(m.query('body'))
)