(function(){
  var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent),
  scriptFile = document.createElement('script'), styleFile = document.createElement('link'),
  scriptSrc = 'js/' + (isMobile ? 'mobile.js' : 'desktop.js'),
  styleSrc = 'css/' + (isMobile ? 'mobile.css' : 'desktop.css'),
  head = document.querySelector('head');
  
  scriptFile.type = 'text/javascript';
  scriptFile.src = scriptSrc;
  
  styleFile.rel = 'stylesheet';
  styleFile.href = styleSrc;
  
  head.appendChild(styleFile);
  head.appendChild(scriptFile);
})();