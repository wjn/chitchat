hbs = require 'hbs';
fs = require 'fs';

express = require 'express'
app = new express()
server = require("http").Server(app)
io = require("socket.io")(server)

redis = require('redis')
redisClient = redis.createClient(6379, '127.0.0.1', {max_attempts:1})
redis.debug_mode = false;

dirJs = "#{__dirname}/public/js"
dirViews = "#{__dirname}/app/views"
dirNodeMods = "#{__dirname}/node_modules"

app.use(express.static(__dirname + '/public'));
hbs.registerPartials "#{__dirname}/app/views/partials"


server.listen 8080, ->
  console.log "Chitchat is running..."

app.get "/", (req,res) ->
  res.render "#{dirViews}/index.hbs"

io.on "connection", (client) ->
  console.log "Client connected..."

  client.on 'messages', (message) ->
    console.log message
    data =
      nickname: client.nickname
      message: message

    client.broadcast.emit 'messages', data
    client.emit 'messages', data

    storeMessages data

  client.on 'join', (name) ->
    client.nickname = name.toLowerCase()

    if name is 'removeAllChatters'
      emptyHashTable 'names'
      client.emit 'askForName'
      return

    console.log "#{client.nickname} joined the Chitchat"
    storeChatters
      nickname: client.nickname
      online: true

    console.log "Chatters stored..."
    redisClient.hkeys "names", (err, names) ->
      # chatters is an array of nicknames
      names.forEach (name) ->
        isOnline = redisClient.hget "names", name
        client.emit 'chatters',
          nickname: name
          online: isOnline


    #each message in the messages array consists of an object with the following properties:
    # nickname: [nickname]
    # message: [message text]
    redisClient.lrange "messages", 0, -1, (err,messages) ->
      console.log "retrieving messages " + messages.toString();
      messages = messages.reverse()
      messages.forEach (message) ->
        console.log "message sent to client: #{message}"
        message = JSON.parse message
        client.emit "messages", message

io.on 'error', (data) ->
    console.log "Socket.io Error: #{data}"
    client.emit 'socketError'

io.on 'disconnect', ->
  console.log 'Socket.io Disconnected.'

  storeChatters
    nickname: client.nickname
    online: false


# ----------- Routes ------------------------------------
# app.get "/dashboard", (req,res) ->
#     res.sendFile "#{dirViews}/dashboard.html"


# ---------- persistent data ----------------------------
# Messages : an array of objects with two properties:
# {
#   nickname: [value]
#   message: [message value]
#}
storeMessages = (data) ->
  console.log "storeMessages function called --->"
  console.log "\tredisClient.lpush \"messages\"  JSON.stringify {nickname: #{data.nickname}, message: #{data.message}},..."
  redisClient.lpush "messages", JSON.stringify {nickname: data.nickname, message: data.message}, (err, reply) ->
    redisClient.ltrim "messages", 0, 9

# Chatters: an array of objects with two properties:
# nickname: [nickname]
# online: [true|false]
storeChatters = (data) ->
  nickname = data.nickname || null
  isOnline = data.online || false
  console.log "Nickname: #{nickname}, isOnline: #{isOnline}"
  console.log "storeChatters function called --->"
  console.log "\tredisClient.hset \"chatters\", #{data.nickname}, #{data.online}\n"
  redisClient.hset "names", data.nickname.toLowerCase(), data.online, (err,reply) ->
    if err then console.dir "storeChatters ERROR: #{err}"
    if reply then console.dir "storeChatters REPLY: #{reply}"

removeChatter = (tableName = 'names', name) ->
  redisClient.hdel tableName, name, (err,reply) ->
    if err then console.log "removeChatter ERROR: #{err}"
    if reply == 1 then console.log "#{name} was removed from the #{tableName} hash table."
    else console.log "#{name} was not found in the #{tableName} hash table."


emptyHashTable = (tableName) ->
  redisClient.hkeys tableName, (err, keys) ->
    keys.forEach (key) ->
      redisClient.hdel tableName, key, (err,reply) ->
        if err then console.log "There was an error emptyin the #{tableName} hash table: #{err}"
        if reply then console.log "#{tableName} was successfully emptied. REPLY: #{reply}"


redisClient.on "error", (err) ->
  console.log err

redisClient.on "connect", () ->
  console.log "redis connect ..."

redisClient.on 'ready', () ->
  console.log 'redis ready ...'

redisClient.on 'reconnecting', () ->
  console.log 'redis reconnecting ...'

redisClient.on 'end', () ->
  console.log 'redis end ...'
