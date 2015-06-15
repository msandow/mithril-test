secureAjax = require('./../_utilities/secureAjax.coffee')
forms = require('./../_components/forms/desktop.coffee')
desktopController = require('./controller.coffee')

module.exports = ->
  m.ready(->

    Login = 
      controller: class extends desktopController
        
      view: (ctx) ->
        m.el('form',{
          onsubmit: ctx.loginSubmit.bind(ctx)
        },[
          m.el('h4',ctx.headerMessage)
          forms.text(ctx.un, {placeholder: 'Username'}),
          m('br'),
          forms.password(ctx.pw, {placeholder: 'Password'}),
          m('br'),
          m.el('button','Login')
        ])
        

      route: ['/login', '/login/:message']
    
    m.register(Login)
  )