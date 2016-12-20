/* eslint-env node*/

exports.webSocketServer = function(opts){
  return function(){
    return new require("ws").Server(opts);
  };
};

exports.onConnectionImpl = function(wss){
  return function(cb){
    return function(){
      wss.on("connection", function(ws){
        cb(ws)();
      });
    };
  };
};

