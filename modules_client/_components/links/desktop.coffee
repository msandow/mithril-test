module.exports = 
  clickEvent: (text, conf) ->
    oclick = conf.onclick or (->)
    conf.href = '#'
    
    conf.onclick = (evt)->
      evt.preventDefault()
      oclick(evt)
    
    m.el('a', conf, text)