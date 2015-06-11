secureAjax = require('./../../_utilities/secureAjax.coffee')
invalidate = require('./../../_utilities/invalidateUser.coffee')
links = require('./../../_components/links/desktop.coffee')

module.exports = m.component(
  controller: class
    constructor: ->

    logOut: (evt)=>
      evt.preventDefault()

      secureAjax(
        method: 'POST'
        url: '/user/logout'
        complete: (error, response) =>
          invalidate()
      )
      false
      
    refresh: (evt)->
      evt.preventDefault()
      m.refresh()
      false


  view: (ctx) ->
    m.el('header',[
      links.clickEvent('Log Out', {onclick: ctx.logOut})
      m.trust('&nbsp;&nbsp;&nbsp;')
      links.clickEvent('Refresh', {onclick: ctx.refresh})
    ]);
)