module.exports = class
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
        url: '/login/login'
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