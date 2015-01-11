// Generated by CoffeeScript 1.7.1
(function() {
  $(document).ready(function() {
    var insertMessage, socket;
    console.log("jQuery says document is ready.");
    insertMessage = function(data) {
      console.log('insertMessage() fired...');
      return $('<li class="entry row"><span class="chatter-name col-xs-3">name</span><span class="chat-content col-xs-8">' + data + '</span></li>').appendTo('#entries');
    };
    socket = io.connect('http://localhost');
    $("#chitchat").on('click', function(e) {
      var message;
      message = $('#chat-entry').val();
      console.log("chitchat: " + message);
      return socket.emit('messages', message);
    });
    return socket.on('messages', function(data) {
      return insertMessage(data);
    });
  });

}).call(this);
