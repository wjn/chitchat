$(document).ready () ->
    console.log "jQuery says document is ready."

    insertMessage = (data) ->
        console.log 'insertMessage() fired...'
        $('<li class="entry row"><span class="chatter-name col-xs-3">name</span><span class="chat-content col-xs-8">'+data+'</span></li>').appendTo('#entries');


    # Socket.io client calls
    socket = io.connect('http://localhost')

    $("#chitchat").on('click', (e) ->
        message = $('#chat-entry').val()
        console.log("chitchat: " + message)
        socket.emit('messages', message)
    )

    socket.on('messages', (data) ->
        insertMessage(data)
    )
