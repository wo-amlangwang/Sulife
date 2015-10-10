var Event = require('../mongo_modules/event.js');
module.exports = {
  deleteEvent : function(req,res,next) {
    Event.findOne({'id' : req.params.eventid},function(err,thisevent) {
      if(req.userid === thisevent.userid){
        thisevent.remove();
        res.status(200).send({'message' : 'OK!'});
      }else{
        res.status(403).send({'message' : 'You have no right to do this'});
      }
    });
  }
}
