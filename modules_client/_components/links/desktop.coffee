module.exports = 
  clickEvent: (text, conf = {}) ->
    oclick = conf.onclick or (->)
    conf.href = '#'
    
    conf.onclick = (evt)->
      evt.preventDefault()
      oclick(evt)
    
    m.el('a', conf, text)
  
  internalLink: (text, conf = {}) ->
    oclick = conf.onclick or (->)
    ohref = conf.href
    
    conf.onclick = (evt)->
      evt.preventDefault()
      oclick(evt)
      m.route(ohref)
      
    conf.href = "/#!" + conf.href
    
    m.el('a', conf, text)