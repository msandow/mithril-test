require('./../../public/mithril.app.coffee')

m.ready(->

  for module in [
    require('./../dashboard/desktop.coffee')
    require('./../login/desktop.coffee')
  ]
    m.register(module)

  m.register(
    view: ->
    controller: ->
      if not window.sessionStorage.getItem('currentUser')
        m.route('/login')
      else
        m.route('/dashboard')

    route: '/'
  )

  m.start(m.query('body'))
)