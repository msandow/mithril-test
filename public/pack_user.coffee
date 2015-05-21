require('./mithril.app.coffee')
require('../apps/user/app.coffee')()

m.ready(->
  m.start(m.query('body'))
)