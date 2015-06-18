forms = require('./../_components/forms/desktop.coffee')

module.exports =
  
  serverController: class
    constructor: (req, res, triggerView) ->
      @headerMessage = switch req.params?.message
        when 'timeout' then 'You\'ve timed out'
        when undefined, false then 'Welcome'
      triggerView(@)

  controller: class      
    constructor: ->      
      @headerMessage = switch m.route.param("message")
        when 'timeout' then 'You\'ve timed out'
        when undefined, false then 'Welcome'

      @un = m.prop("")
      @pw = m.prop("")


    loginSubmit: (evt)->
      evt.preventDefault()

      if not @un() or not @pw()
        alert('Please fill out the form')
      else
        m.ajax(
          method: 'POST'
          url: '/endpoint/login/login'
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
      onsubmit: ctx.loginSubmit?.bind(ctx)
    },[
      m.el('h4',ctx.headerMessage)
      forms.text(ctx.un, {placeholder: 'Username'}),
      m('br'),
      forms.password(ctx.pw, {placeholder: 'Password'}),
      m('br'),
      m.el('button','Login')
    ])


  route: ['/login', '/login/:message']