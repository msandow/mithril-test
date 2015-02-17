runLoad = (cb = (->)) ->
  if document.readyState is 'complete'
    cb()
  else
    window.onload = cb

runLoad( ->
  components = 
    link: (href, text, conf = {}) ->
      ooc = conf.onclick or (->)
      conf.onclick = (evt) ->
        evt.preventDefault()
        m.route(href)
        ooc()

      conf.href = "/" + href
      m.el("a", conf, text)

  Navigation = m.create(
    name: "Navigation"
    model:
      links: [
        {text: 'Home', link: '/home'},
        {text: 'About', link: '/about'}
      ]
    view: (ctrl) ->
      @model.links().map((l)->
        li = components.link(l.link, l.text)
        li.attrs.style = 'font-weight:bold' if m.route() is l.link
        li
      )
  )

  Empty = m.create(
    name: "Empty"
    path: "/"
    view: (ctrl) ->
      null
  )

  simpleFactory = (name, route) ->
    newModule = m.create(
      name: name
      path: route
      model:
        text: ''
      controller: () ->
        setTimeout(()=>
          m.startComputation()
          @model.text(name)
          m.endComputation()
        ,500)
      view: (ctrl) ->
        [
          m.el('h4', @model.text())
          m.el('a[href="#"]',
            onclick: (evt) ->
              evt.preventDefault()
              Navigation.model.links().push({text: 'Return', link: '/home'})
          , 'push'
          )
        ]
    )

    m.addModule(newModule)
    newModule

  m.addModule(Empty)
  m.addModule(Navigation)
  simpleFactory('Home', '/home')
  simpleFactory('About', '/about')

  m.renderModule(document.querySelector('#nav'), 'Navigation')
  m.buildRoutes(document.querySelector('#body'))
)