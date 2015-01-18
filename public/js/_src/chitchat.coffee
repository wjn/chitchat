$(document).ready () ->
    console.log "jQuery says document is ready."

    insertMessage = (data) ->
      console.log 'insertMessage() fired...'
      $('<li class="entry row"><span class="chatter-name col-xs-3">'+data.nickname+'</span><span class="chat-content col-xs-8">'+data.message+'</span></li>').appendTo('#entries');

    addChatters = (data) ->
      console.log "updating chatters..."
      if data.online then status = 'online' else status = 'not-online'
      $("<li class='chatter row'><span class='chatter-name col-xs-12 #{status}'>#{data.nickname}</span></li>").appendTo('#chatters-list');

    collectMessage = () ->
      message = $('#chat-entry').val()
      console.log("chitchat: " + message)
      socket.emit('messages', message)
      $("#chat-entry").val("")

    askForNickname = (data) ->
      console.log "asking user for name..."
      nickname = prompt('What\'s your name?')
      if nickname isnt null
        console.log "user set nickname: #{nickname}"
        $('#status').html('Connected to Chitchat <span id="nickname">...</span>')
        socket.emit('join', nickname)
        $('#status #nickname').html("as <strong>#{nickname}</strong>.")
        return
      else
        askForNickname data

    # Socket.io client calls
    socket = io.connect('http://localhost')

    $('#chat-entry').keypress (e) ->
        if(e.which == 13)
            collectMessage()

    $("#chitchat").on('click', (e) ->
        collectMessage()
    )

    socket.on('messages', (data) ->
        insertMessage(data)
    )

    socket.on('error', (message) ->
        alert(message);
    )

    socket.on('chatters', (data) ->
        addChatters(data)
    )
    socket.on('askForName', (data) ->
        askForNickname(data)
    )
    socket.on('connect', (data) ->
        askForNickname(data)
    )
