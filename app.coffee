hbs = require 'hbs';
fs = require 'fs';

express = require 'express'
app = new express()
server = require("http").Server(app)
io = require("socket.io")(server)

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

    client.on 'messages', (data) ->
        console.log data
        client.broadcast.emit 'messages', data


    # client.on "message", (message) ->
    #     console.log "client submitted this message : #{message}"
#
# io.on 'error', (data) ->
#     console.log "Socket.io Error: #{data}"
#     alert "Socket.io Error: #{data}"
#
# io.on 'disconnect', ->
#     console.log 'Socket.io Disconnected.'
#
# io.on 'reconnect', ->
#     console.log "Socket.io Reconnected."
#
# ----------- Routes ------------------------------------
# app.get "/js/:jsFile", (req,res) ->
#     res.sendFile "#{dirJs}/#{req.params.jsFile}"

# app.get "/dashboard", (req,res) ->
#     res.sendFile "#{dirViews}/dashboard.html"

# app.get "/socket.io/:filename", (req,res) ->
#     fn = req.params.filename
#     res.sendFile dirNodeMods
