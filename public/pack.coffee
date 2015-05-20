require('./mithril.app.coffee')
require('../apps/1/app.coffee')()
require('../apps/2/app.coffee')()
require('../apps/index4/app.coffee')()

m.ready(->
  m.start(m.query('body'))
)