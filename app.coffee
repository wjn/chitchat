hbs = require 'hbs';
fs = require 'fs';

express = require 'express'
app = new express()
server = require("http").Server(app)
io = require("socket.io")(server)

redis = require('redis')
redisClient = redis.createClient(6379, '127.0.0.1', {max_attempts:1})
redis.debug_mode = true;

dirJs = "#{__dirname}/public/js"
dirViews = "#{__dirname}/app/views"
dirNodeMods = "#{__dirname}/node_modules"

app.use(express.static(__dirname + '/public'));
hbs.registerPartials "#{__dirname}/app/views/partials"

# Chatters: an array of objects with two properties:
# nickname: [nickname]
# online: [true|false]
chatters = []

# Messages : an array of objects with two properties:
# {
#   nickname: [value]
#   message: [message value]
#}
messages = []

server.listen 8080, ->
    console.log "Chitchat is running..."

app.get "/", (req,res) ->
    res.render "#{dirViews}/index.hbs"

io.on "connection", (client) ->
    console.log "Client connected..."

    client.on 'messages', (message) ->
        console.log data
        data =
            nickname: client.nickname
            message: message

        client.broadcast.emit 'messages', data
        client.emit 'messages', data

        storeMessages data

    client.on 'join', (name) ->
        client.nickname = name
        console.log "#{client.nickname} joined the Chitchat"

        client.broadcast.emit 'chatters',
            nickname: client.nickname
            online: true

        storeChatters
            nickname: client.nickname
            online: true

        # chatters is an array of nicknames
        chatters.forEach (chatter) ->
            client.emit 'chatters', chatter


        #each message in the messages array consists of an object with the following properties:
        # nickname: [nickname]
        # message: [message text]
        messages.forEach (message) ->
          client.emit "messages", message



#
# io.on 'error', (data) ->
#     console.log "Socket.io Error: #{data}"
#     alert "Socket.io Error: #{data}"
#
io.on 'disconnect', ->
    console.log 'Socket.io Disconnected.'

    storeChatters
        nickname: client.nickname
        online: false


# io.on 'reconnect', ->
#     console.log "Socket.io Reconnected."
#
# ----------- Routes ------------------------------------
# app.get "/dashboard", (req,res) ->
#     res.sendFile "#{dirViews}/dashboard.html"


# ---------- persistent data ----------------------------

storeMessages = (data) ->
    messages.push {nickname: data.nickname, message: data.message}
    if messages.length > 10 then messages.shift()

storeChatters = (data) ->
    chatters.push
        nickname: data.nickname
        online: data.online


redisClient.on "error", (err) ->
    console.log err

redisClient.on "connect", () ->
    console.log "connect"

redisClient.on 'ready', () ->
    console.log 'ready'

redisClient.on 'reconnecting', () ->
    console.log 'reconnecting'

redisClient.on 'end', () ->
    console.log 'end'


question1 = "Where is the dog?";
question2 = "Where is the cat?";

redisClient.set "key1", question1
redisClient.set "key2", question2
redisClient.get 'key2', (err,reply) ->
    console.log reply

redisClient.lpush "questions", question1
redisClient.lpush "questions", question2

redisClient.lrange 'questions', 0, -1, (err,reply) ->
    console.log reply
