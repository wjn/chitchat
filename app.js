var express = require("express");
var app = new express();
app.use(express.static(__dirname + '/public'));

var server = require("http").createServer(app);
var io = require("socket.io")(server);

var dirViews = __dirname + "/public/views";

io.on("connection", function(){
    console.log("I/O connected...")
});


app.get("/", function(req,res){
    res.sendFile(dirViews + "/index.html");
});

app.listen(8080);
console.log("Chitchat is running...");
