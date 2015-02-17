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
        m.route("/" + href)
        ooc()

      conf.href = "/" + href
      m.el("a", conf, text)
  
  GlobalModels =
    User: class User
      constructor: (@fname = "", @lname = "", @id = "") ->

  UserHeader = m.create(
    name: "UserHeader"
    model:
      LoggedInUser: new GlobalModels.User()
    controller: () ->
      @login = () =>
        console.log(@model)
        @model.LoggedInUser().fname('Mr')
        @model.LoggedInUser().lname('Bob')
        @model.LoggedInUser().id(55678)
      
      @logout = () =>
        @model.LoggedInUser().fname('')
        @model.LoggedInUser().lname('')
        @model.LoggedInUser().id('')
      console.log(@)
      
    view: (ctrl) ->
      u = @model.LoggedInUser()
      name = if u.id() then u.fname() + ' ' + u.lname() else 'Guest'
      p = m.el('p', [ m.el('i', name) ])
      #console.log(ctrl)
      p.append(
        m.el('a[href="#"]',
          onclick: (evt) ->
            evt.preventDefault()

            if u.id() then ctrl.logout() else ctrl.login()
        , if u.id() then 'logout' else 'login')
      )
      
      p
  )

  Index = m.create(
    path: "/"
    name: "home"
    model:
      links: []
      title: ""
      linkObject: class linkObject
        constructor: (@text = '', @href = '') ->
    controller: () ->
      m.ajax.post("/getter", {id: 'foo'}, (err, response) =>
        @model.title(response.string)
      )

      @model.links().push(new @model.linkObject('Search Users', 'users'))
    view: (ctrl) ->
      [
        m.importModule("UserHeader")
        m.el('h6', @model.title())
        m.el('nav', {'class': 'nav'}, @model.links().map((l)->
          components.link(l.href, l.text)
        ))
      ]
  )

  Users = m.create(
    path: "/users"
    name: "Users"
    model:
      users: []
      incomplete: true
      userObj: GlobalModels.User
    controller: () ->
      m.ajax.get("/getUsers", {}, (err, response)=>
        @model.users(response.users.map((i)=>
          new @model.userObj(i.fname, i.lname, i.id)
        ))
        
        @model.incomplete(false)
      )
      
      @remove = (u) =>
        @model.users().splice(@model.users().indexOf(u), 1)
    view: (ctrl) ->
      [
        m.importModule("UserHeader")
        m.importModule("Header.header")
        m.el('div', @model.users().map((u)->
          m.el('p', 
            key: u.id()
            'class': 'user'
          , [
            m.el('span', u.fname() + ' ' + u.lname())
            m.el('span', m.trust('&nbsp;&nbsp;&nbsp;'))
            components.link('users/' + u.id(), 'Edit')
            m.el('a[href="#"]',
              onclick: (evt) ->
                evt.preventDefault()
                ctrl.remove(u)
            , 'Delete'
            )
          ]
          )
        ))
        m.el('div',{style:'display:' + (Users.model.incomplete() ? 'block' : 'none')},'loading')
        m.importModule("Header.footer")
      ]
  )

  User = m.create(
    path: "/users/:userID"
    model:
      incomplete: true
      fname: ''
      lname: ''
      id: ''
    controller: () ->
      m.ajax.get("/getUsers", {}, (err, response) =>
        for i in response
          if i.id is m.route.param("userID")
            @model.fname(i.fname)
            @model.lname(i.lname)
            @model.id(i.id)
            
            break
        
        @model.incomplete(false)
      )
    view: (ctrl) ->
      stack = []
      
      if @model.incomplete()
        stack.push(m.el('div', 'loading'))
      else
        stack.push(m.el('div',[
          m.el('h3', @model.fname() + " " + @model.lname())
          components.link('users', 'Go Back')
        ]))
      
      stack
  )

  Header = m.create(
    name: "Header"
    model:
      text: ''
    controller: () ->
      setTimeout(()=>
        m.startComputation()
        @model.text(Math.floor((Math.random() * 10) + 1))
        m.endComputation()
      ,1500)
    view: (ctrl) ->
      m.el('h2', 
        onmouseenter: (evt) ->
          console.log(evt.target)
      , @model.text())
  )

  m.addModule(UserHeader)
  m.addModule(Index)
  m.addModule(Users)
  m.addModule(User)
  m.addModule(Header)

  m.buildRoutes(document.body)
)