var express = require('express');
var app = express();
//used to connected mongodb
var mongoose = require('mongoose');
//express middlewares
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var session = require('client-sessions');
//require main passport
var passport = require('passport');

var server = require('http').Server(app);
var io = require('socket.io')(server);
//connect to mongo db
var mongoURL = require('./mongo_modules/mongoURL.json').url;
mongoose.connect(mongoURL,function(err) {
  if(err) {
    console.log(err);
    process.exit();
  } else {
    console.log('Connect to mongodb');
  }
});

require('./passport/passport-local.js')(passport);

//use middlewares for every route
app.use(express.static('client'));
app.use(cookieParser());
app.use(bodyParser());
app.use(session({'cookieName' : 'session',
                 'secret' : 'i am a zombie, but i drink milk 0W0',
                 'duration' : 12 * 60 * 60 * 1000,
                 'activeDuration' : 5 * 60 * 1000}));
app.use(passport.initialize());
app.use(passport.session());
//give app and passport router
require('./router.js')(app,passport);
io.on('connection', function(socket){
  require('./event')(socket,io);
});
//listen on port
var port = process.env.PORT || 4000;
server.listen(port,function(err) {
  if(err) {
    console.log(err);
    process.exit();
  } else {
    console.log('Server is listening on ' + port);
  }
});
