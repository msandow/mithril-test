module.exports = ->
  m.ready(->
    
    Utils = 
      constructAppLink: (str) ->
        '#' + str
      destructAppLink: (str) ->
        str.substring(1)
        
    
    
    App = 
      view: ->
      controller: ->
        m.route '/home'
      route: '/'
    
    m.register(App)
    
    
    
    
    Navigation = 
      controller: class
        constructor: ->
          @links = [
            {
              text: 'Home'
              url: '/home'
            }
            {
              text: 'Account'
              url: '/account'
            }
          ]

      view: (ctx, args) ->
        m.el('nav', {
          onclick: (evt) ->
            evt.preventDefault()
            m.route Utils.destructAppLink(evt.target.getAttribute('href'))
            false
        }, ctx.links.map((l) ->
            configs = href: Utils.constructAppLink(l.url)
            if l.url == args.url
              configs.style = {}
              configs.style['font-weight'] = 'bold'
            m('a', configs, l.text)
          )
        )
        
        
    
    LoadingScreen = m.component(
      controller: class
        constructor: ->
          @active = true
  
      view: (ctx) ->
        if ctx.active
          return m.el('p', 'Loading...')
        null
    )
    
    
    
    Home = 
      controller: class
        constructor: ->
          @navigationPanel = m.component(Navigation, url: m.route())
          @counter = 0
          @isLoading = true

          request = m.ajax(
            type: 'GET'
            url: '/getNumber'
            complete: (error, response) =>
              @isLoading = false
              if !error
                @counter = response.number

            headers: foo: 'bar')
          #request.abort();
          @message = 'Welcome back'

      view: (ctx) ->
        m('section', [
          ctx.navigationPanel()
          m.el('span',{
            onclick: ->
              ctx.counter++
          },
          ctx.message + ' ' + ctx.counter
          if ctx.isLoading then LoadingScreen() else null
          )
        ])

      route: '/home'
    
    m.register Home
    
    
    Account = 
      controller: class
        constructor: ->
          @navigationPanel = m.component(Navigation, url: m.route())

      view: (ctx) ->
        m 'section', [
          ctx.navigationPanel()
          m.el('h2', 'Account')
        ]
        
      route: '/account'
    
    m.register Account
  )