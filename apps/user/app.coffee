module.exports = ->
  m.ready(->
    
    class ShouldBeLoggedIn
      checkLoggedIn: (cb = (->)) ->
        m.ajax(
          type: 'GET'
          url: '/user/ping'
          complete: (error, response) =>
            if error or !response.ping or !window.sessionStorage.getItem('currentUser')
              m.route('/login')
              return
            
            cb()
        )
    
    
    LogOutButton = m.component(
      controller: ->
  
      view: (ctx) ->
        m.el('a',{
          href: '#'
          onclick: (evt)->
            evt.preventDefault()
            
            m.ajax(
              type: 'POST'
              url: '/user/logout'
              headers:
                csrf: window.sessionStorage.getItem('csrf')
              complete: (error, response) =>
                window.sessionStorage.removeItem('currentUser')
                window.sessionStorage.removeItem('csrf')
                m.refresh()
            )
            false
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
          
          
      view: (ctx) ->
        m.el('form',{
          onsubmit: (evt)->
            evt.preventDefault()
            
            un = m.query(evt.target, 'input[type="text"]').value
            pw = m.query(evt.target, 'input[type="password"]').value
            
            if not un or not pw
              alert('Please fill out the form')
            else
              m.ajax(
                type: 'POST'
                url: '/user/login'
                data:
                  un: un
                  pw: pw
                complete: (error, response) =>
                  if error
                    alert('Please try again')
                    return
                  
                  window.sessionStorage.setItem('currentUser', response.userId)
                  window.sessionStorage.setItem('csrf', response.csrf)

                  m.route('/dashboard')
              )
            
            false
        },[
          m.el('input',{type: 'text', placeholder: 'Username'}),
          m('br'),
          m.el('input',{type: 'password', placeholder: 'Password'}),
          m('br'),
          m.el('button','Login')
        ])
        

      route: '/login'
    
    m.register(Login)
    
    
    Dashboard = 
      controller: class extends ShouldBeLoggedIn
        constructor: ->
          @checkLoggedIn()
      view: (ctx) ->
        [
          m.el('h1',"Hello user " + window.sessionStorage.getItem('currentUser')),
          LogOutButton()
        ]
        

      route: '/dashboard'
    
    m.register(Dashboard)

  )