require('coffee-script/register');
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var exec = require('child_process').exec;
var Boxy = require('BoxyBrown');
var session = require('express-session');
var uuid = require('uuid');

app.use(session({
  genid: function(req) {
    return uuid.v4();
  },
  secret: '1234567890QWERTY',
  saveUninitialized: true,
  resave: true
}));


app.get('/mithril.factory.js', function(req, res){
  exec('coffee -cp ./public/mithril.utils.coffee', function (error, stdout, stderr) {
    if(error) console.log(error);
    res.set('Content-Type', 'application/javascript')
    res.send(stdout);
  });
});

app.get('/mithril.app.js', function(req, res){
  exec('coffee -cp ./public/mithril.app.coffee', function (error, stdout, stderr) {
    if(error) console.log(error);
    res.set('Content-Type', 'application/javascript')
    res.send(stdout);
  });
});

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use(Boxy.CoffeeJs({
  route: '/js/app.js',
  source: __dirname + "/public/pack.coffee",
  debug: true
}));

//app.use(Boxy.Tokenized({
//  route: '/index_4.html',
//  source: __dirname + "/public/index_4.html",
//  debug: true,
//  tokens: {
//    token: new Date().getTime()
//  }
//}));

app.get('/index_4.html', function(req, res){
  if(!req.session.CSRF){
    req.session.CSRF = uuid.v4();
  }
  
  Boxy.TokenReplacer(__dirname + '/public/index_4.html',{
    csrf: req.session.CSRF
  }, function(err, data){
    if(err){
      res.status(500).send(null);      
      return;
    }    
    
    res.writeHead(200,{
      'Content-Type': 'text/html'
    });
    res.end(data);
  });
});

app.use(Boxy.ScssCss({
  route: '/css/app.css',
  source: __dirname + "/public/pack.scss",
  debug: true
}));

app.get('/getUsers', function(req, res){
  setTimeout(function(){
    res.json(require('./users.json'));
  },1000);
});

app.post('/getter', function(req, res){
  res.send({string:req.body.id});
});

app.get('/getNumber', function(req, res){
//  if(req.session.user == undefined){
//    req.session.user = '1234'
//    console.log('No user', 'setting to', '1234')
//  }else{
//    console.log('Current user', 'sett to', req.session.user)
//  }
  //session.destroy()
  
  setTimeout(function(){
    res.json({number: 1});
  },1000);
});

//app.use('/doc', express.static(__dirname + '/doc'));
//app.use(express.static(__dirname + '/public'));

app.listen(8000);