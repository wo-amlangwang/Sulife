var makeToken = require('./middlewares/maketoken.js');
var middlewares = require('./middlewares/middlewares.js');
module.exports = function(app,passport){
  app.post('/register',function(req,res,next) {
    passport.authenticate('local-signup',function(err,user,info) {
      if(err){
        res.status(503).send(err);
      }else {
        if(user){
          makeToken.makeToken({'id' : user.id}).then(function(token) {
            res.status(200).send({'message' : 'OK',
                                  'Access_Token' : token});
          }).catch(function(err) {
            console.log(err);
            res.status(500).send({'message' : 'Server err',
                                  'err' : err});
          });
        }else {
          res.status(409).send(info);
        }
      }
    })(req,res,next);
  });
  app.post('/local/login',function(req,res,next){
    passport.authenticate('local-login',function(err,user,info) {
      if(err){
        res.status(503).send(err);
      }else {
        if(user){
          makeToken.makeToken({'id' : user.id}).then(function(token) {
            res.status(200).send({'message' : 'OK',
                                  'Access_Token' : token});
          }).catch(function(err) {
            console.log(err);
            res.status(500).send({'message' : 'Server err',
                                  'err' : err});
          });
        }else {
          res.status(401).send(info);
        }
      }
    })(req,res,next);
  });
  app.post('/event' , middlewares.verifyToken , middlewares.postEvent);
  app.get('/event' , middlewares.verifyToken , middlewares.getAllEvent);
  app.post('/eventf' , middlewares.verifyToken , middlewares.getFriendEvent);
  app.post('/eventd' , middlewares.verifyToken, middlewares.getEventByDate);
  app.delete('/event/:eventid' , middlewares.verifyToken , middlewares.checkEventid , middlewares.deleteEvent);
  app.get('/event/:eventid' , middlewares.verifyToken , middlewares.checkEventid ,middlewares.getEvent);
  app.post('/event/:eventid' , middlewares.verifyToken , middlewares.checkEventid ,middlewares.editEvent);
  app.get('/profile' , middlewares.verifyToken , middlewares.getProfile);
  app.post('/profile' , middlewares.verifyToken , middlewares.editProfile);
  app.post('/friendRequest' , middlewares.verifyToken , middlewares.friendRequest);
  app.get('/getMail', middlewares.verifyToken , middlewares.getMail);
  app.post('/acceptFriendRequest' , middlewares.verifyToken , middlewares.acceptFriendRequest, middlewares.buildFriendRelationship);
  app.post('/rejectFriendRequest' , middlewares.verifyToken , middlewares.rejectFriendRequest);
  app.get('/getFriends' ,  middlewares.verifyToken , middlewares.getFriends);
  app.post('/findUser' , middlewares.verifyToken , middlewares.findUser);
  app.get('/getUserInformation/:userid' , middlewares.verifyToken ,middlewares.getUserInformation);
  app.delete('/task/:taskid',middlewares.verifyToken, middlewares.deleteTask);
  app.post('/task/:taskid' , middlewares.verifyToken, middlewares.editTask);
  app.get('/task', middlewares.verifyToken, middlewares.getAllTask);
  app.get('/task/:taskid', middlewares.verifyToken, middlewares.getTask);
  app.post('/task',middlewares.verifyToken,middlewares.postTask);
  app.post('/taskd' , middlewares.verifyToken, middlewares.getTaskByDate);
  app.delete('/deleteFriend/:targetid' , middlewares.verifyToken , middlewares.deleteFriend);
  app.post('/resetPassword' , middlewares.resetPassword);
  app.post('/changePassword' , middlewares.verifyToken , middlewares.changePassword);
  app.get('/location/:EventOrTaskid', middlewares.verifyToken , middlewares.getLocation);
  app.post('/location',middlewares.verifyToken,middlewares.postLocation);
  app.post('/createGroup',middlewares.verifyToken, middlewares.createGroup);
  app.post('/joinGroup', middlewares.verifyToken, middlewares.joinGroup);
}
