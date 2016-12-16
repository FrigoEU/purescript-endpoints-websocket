/* eslint-env node*/

exports.webSocketServer = function(opts){
  return function(){
    return new require("ws").Server(opts);
  };
};

exports.onConnection = function(wss){
  return function(cb){
    return function(){
      wss.on("connection", function(ws){
        cb(ws)();
      });
    };
  };
};

