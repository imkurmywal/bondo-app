const functions = require('firebase-functions');


const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
var msgData;

exports.replyTriger = functions.firestore.document(
    'replies/{replieId}'
).onCreate((snapshot,context) => {
    msgData = snapshot.data();  


    var payload = {
        "notification" : {
            "title": 'Replie on '+ msgData.title + 'Note',
            "body": "You have recieve reply",
            "sound": "default"
        },
        "data": {
	    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            "title": msgData.title,
            "address": msgData.address,
            "docId": msgData.docId,
            "pic": msgData.pic,
            "token": msgData.token,
            "uid": msgData.uid,
            "noteUrl": msgData.noteUrl,
        }
    }


    return admin.messaging().sendToDevice(msgData.token,payload).then((response) => {

        console.log("Pushed them all");
    }).catch((err) => {
        console.log(err);
    })
    
    // admin.firestore().collection('deviceTokens').get().then((snapshot) => {
    //     var tokens = [];
    
    //     if(snapshot.empty)
    //     {
    //         console.log('No Device');
    //     }else{
    //         for (var token of snapshot.docs){
    //             tokens.push(token.data().deviceToken);
    //         }


    //         var payload = {
    //             "notification" : {
    //                 "title": "New Event.",
    //                 "body": "Fred Uploaded an event",
    //                 "sound": "default" 
    //             },
    //             "data": {
    //                 "sendername": "Fred",
    //                 "message": "Fred Uploaded an Event"
                
    //             }
    //         }

    //         return admin.messaging().sendToDevice(tokens,payload).then((response) => {

    //             console.log("Pushed them all");
    //         }).catch((err) => {
    //             console.log(err);
    //         })

    //     }
    // })
}  )