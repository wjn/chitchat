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

    askForName = () ->
        console.log "asking user for name..."
        nickname = prompt('What\'s your name?')
        console.log "nickname: #{nickname}"
        if nickname? and nickname != ""
            return nickname
        else
            askForName()


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

    socket.on('chatters', (data) ->
        addChatters(data)
    )

    socket.on('connect', (data) ->
        $('#status').html('Connected to Chitchat <span id="nickname">...</span>')
        nickname = askForName()
        socket.emit('join', nickname)
        $('#status #nickname').html("as <strong>#{nickname}</strong>.")

    )
