/**
* Helper functions
**/

$(document).ready(function(){

    $("#chitchat").on("click", function(){
        alert("chitchat");
    });

    function postMessage(message) {
        console.log("postMessage called with this message : " + message);
    }

});
