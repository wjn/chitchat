var express = require("express"),
    app = new express();
app.use(express.static(__dirname + '/public'));

var server = require("http").createServer(app),
    io = require("socket.io")(server),
    dirViews = __dirname + "/public/views",
    dirNodeMods = __dirname + "/node_modules";



io.on("connection", function(client){
    console.log("I/O connected...");
    client.on("message", function(message){
        console.log("client submitted this message : " + message);
    });
});

app.get("/", function(req,res){
    res.sendFile(dirViews + "/index.html");
});
app.get("/socket.io/:filename", function(req,res){
    var fn = req.params.filename;
    res.sendFile(dirNodeMods + /)
});

app.listen(8080);
console.log("Chitchat is running...");
