secureAjax = require('./../temp/secureAjax.coffee')

module.exports = ->
  m.ready(->

    class DeferredView
      
      foo: 2
      
      viewReady: false


    LogOutButton = m.component(
      controller: class
        constructor: ->
          @logOut = (evt)=>
            evt.preventDefault()
            
            secureAjax(
              method: 'POST'
              url: '/user/logout'
              complete: (error, response) =>
                window.sessionStorage.removeItem('currentUser')
                window.sessionStorage.removeItem('csrf')
                m.route('/login')
            )
            false
            
  
      view: (ctx) ->
        m.el('a',{
          href: '#'
          onclick: ctx.logOut
        },'Log Out')
    )
    
    
    Default = 
      view: ->
      controller: ->
        if not window.sessionStorage.getItem('currentUser')
          m.route('/login')
        else
          m.route('/dashboard')

      route: '/'
    
    m.register(Default)
    
    
    Login = 
      controller: class
        constructor: ->
          @loginSubmit = (evt)->
            evt.preventDefault()
            
            un = m.query(evt.target, 'input[type="text"]').value
            pw = m.query(evt.target, 'input[type="password"]').value
            
            if not un or not pw
              alert('Please fill out the form')
            else
              m.ajax(
                method: 'POST'
                url: '/user/login'
                data:
                  un: un
                  pw: pw
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
          onsubmit: ctx.loginSubmit
        },[
          m.el('input',{type: 'text', placeholder: 'Username'}),
          m('br'),
          m.el('input',{type: 'password', placeholder: 'Password'}),
          m('br'),
          m.el('button','Login')
        ])
        

      route: ['/login', '/login/:message']
    
    m.register(Login)
    
    
    Dashboard = 
      controller: class extends DeferredView
        constructor: ->
          @name = ''
          
          secureAjax(
            method: 'GET'
            url: '/user/fetch'
            complete: (error, response)=>
              @name = response.name
              @viewReady = true
          )

      view: (ctx) ->
        return null if not ctx.viewReady
        [
          m.el('h1',"Hello user " + ctx.name),
          LogOutButton()
        ]
        

      route: '/dashboard'
    
    m.register(Dashboard)

  )