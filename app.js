require('coffee-script/register');
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var exec = require('child_process').exec;
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

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());



[ require(__dirname + '/routes/boxy.coffee'),
  require(__dirname + '/routes/user.coffee') ].forEach(function(router){
  if(!Array.isArray(router.router)){
    app.use(router.scope, router.router);
  }else{
    router.router.forEach(function(subRouter){
      app.use(router.scope, subRouter);
    });
  }
});




app.listen(8000);