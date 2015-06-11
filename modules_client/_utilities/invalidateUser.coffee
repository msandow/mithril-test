module.exports = () ->
  window.sessionStorage.removeItem('currentUser')
  window.sessionStorage.removeItem('csrf')
  m.route('/login')