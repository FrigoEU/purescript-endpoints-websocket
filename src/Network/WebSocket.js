exports.connectImpl = function(errCb){
  return function(successCb){
    return function(url){
      return function(){
        var ws = new WebSocket(url);
        ws.onopen = function(){
          successCb(ws)();
        };
        ws.onerror = function(err){
          errCb(err)();
        };
      };
    };
  };
};

exports.wrapWS = function(ws){
  var messageHandlers = [];
  var closeHandlers = [];
  ws.onmessage = function(ev){
    for (var i = 0; i < messageHandlers.length; i++){
      messageHandlers[i](ev.data)();
    }
  };
  ws.onclose = function(){
    for (var i = 0; i < closeHandlers.length; i++){
      closeHandlers[i]()();
    }
  };
  return {
    onMessage: function(cb){
      return function(){
        messageHandlers.push(cb);
        return function(){
          messageHandlers.splice(messageHandlers.indexOf(cb), 1);
        };
      };
    },
    onClose: function(cb){
      return function(){
        closeHandlers.push(cb);
        return function(){
          closeHandlers.splice(closeHandlers.indexOf(cb), 1);
        };
      };
    },
    send: function(mess){
      ws.send(mess);
    },
    ws: ws
  };
};
