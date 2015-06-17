require('./../../public/mithril.app.coffee')

desktop = ->

  for module in [
    require('./../index/desktop.coffee')
    require('./../dashboard/desktop.coffee')
    require('./../login/desktop.coffee')
  ]
    m.register(module)

  m.start(m.query('body'))

if typeof window is 'undefined'
  module.exports = desktop
else
  m.ready(desktop)