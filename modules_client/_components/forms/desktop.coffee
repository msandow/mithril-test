input = (binding, conf={}) ->
  conf.onkeyup = (evt)->
    binding(evt.target.value)
  m.el('input',conf)

module.exports = 
  text: (binding = (->), conf={}) ->
    conf.type = 'text'
    input(binding, conf)

  password: (binding = (->), conf={}) ->
    conf.type = 'password'
    input(binding, conf)