secureAjax = require('./../_utilities/secureAjax.coffee')
forms = require('./../_components/forms/desktop.coffee')

module.exports = ->
  m.ready(->

    Login = 
      controller: class
        constructor: ->
          @headerMessage = switch m.route.param("message")
            when 'timeout' then 'You\'ve timed out'
            when undefined, false then 'Welcome'
          
          @un = m.prop("")
          @pw = m.prop("")
        
        loginSubmit: (evt)->
          evt.preventDefault()

          #un = m.query(evt.target, 'input[type="text"]').value
          #pw = m.query(evt.target, 'input[type="password"]').value

          if not @un() or not @pw()
            alert('Please fill out the form')
          else
            m.ajax(
              method: 'POST'
              url: '/user/login'
              data:
                un: @un()
                pw: @pw()
              complete: (error, response) =>
                if error or not response.userId
                  alert('Please try again')
                  return

                window.sessionStorage.setItem('currentUser', response.userId)
                window.sessionStorage.setItem('csrf', response.csrf)

                m.route('/dashboard')
            )

          false
        
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