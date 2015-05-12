var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var exec = require('child_process').exec;

app.get('/mithril.factory.js', function(req, res){
  exec('coffee -c -p ./public/mithril.utils.coffee', function (error, stdout, stderr) {
    if(error) console.log(error);
    res.set('Content-Type', 'application/javascript')
    res.send(stdout);
  });
});

app.get('/mithril.app.js', function(req, res){
  exec('coffee -c -p ./public/mithril.app.coffee', function (error, stdout, stderr) {
    if(error) console.log(error);
    res.set('Content-Type', 'application/javascript')
    res.send(stdout);
  });
});

app.use('/doc', express.static(__dirname + '/doc'));
app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json());

app.get('/getUsers', function(req, res){
  setTimeout(function(){
    res.json(require('./users.json'));
  },1000);
});

app.post('/getter', function(req, res){
  res.send({string:req.body.id});
});

app.get('/getNumber', function(req, res){
  setTimeout(function(){
    res.json({number: 1});
  },1000);
});

app.listen(8000);