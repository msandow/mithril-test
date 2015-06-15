links = require('./../../_components/links/desktop.coffee')
desktopController = require('./controller.coffee')

module.exports = m.component(
  
  controller: class extends desktopController

  view: (ctx) ->
    m.el('header',[
      links.clickEvent('Log Out', {onclick: ctx.logOut})
      m.trust('&nbsp;&nbsp;&nbsp;')
      links.clickEvent('Refresh', {onclick: ctx.refresh})
    ]);
)