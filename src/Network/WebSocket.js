// TODO this is kinda shit, confuses PS and JS style
exports.connect = function(errCb){
  return function(successCb){
    return function(url){
      return function(){
        var ws = new WebSocket(url);
        var messageHandlers = [];
        var closeHandlers = [];
        var fakeWs = {
          on: function(event, cb){
            if (event === "message"){
              messageHandlers.push(cb);
            } else if (event === "close"){
              closeHandlers.push(cb);
            }
          },
          send: function(mess){
            ws.send(mess);
          }
        };
        ws.onopen = function(){
          successCb(fakeWs)();
        };
        ws.onerror = function(err){
          errCb(err)();
        };
        ws.onmessage = function(mess){
          for (var i = 0; i < messageHandlers.length; i++){
            messageHandlers[i](mess)();
          }
        };
        ws.onclose = function(){
          for (var i = 0; i < closeHandlers.length; i++){
            closeHandlers[i]({})();
          }
        };
      };
    };
  };
};

exports.onMessage = function(ws){
  return function(cb){
    return function(){
      ws.on("message", function(mess){
        cb(mess)();
      });
    };
  };
};
exports.onClose = function(ws){
  return function(cb){
    return function(){
      ws.on("close", function(){
        cb({})();
      });
    };
  };
};

exports.send = function(ws){
  return function(mess){
    return function(){
      ws.send(mess);
    };
  };
};
