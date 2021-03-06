var exec = require('cordova/exec');

function FCMPlugin() { 
	console.log("FCMPlugin.js: is created");
}

// SUBSCRIBE TO TOPIC //
FCMPlugin.prototype.subscribeToTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'subscribeToTopic', [topic]);
}
// UNSUBSCRIBE FROM TOPIC //
FCMPlugin.prototype.unsubscribeFromTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'unsubscribeFromTopic', [topic]);
}

FCMPlugin.prototype.connectSupport = function( token, success, error ){
	exec(success, error, "FCMPlugin", 'connectSupport', [token]);
}
FCMPlugin.prototype.disconnectSupport = function(  success, error ){
	exec(success, error, "FCMPlugin", 'disconnectSupport', []);
}
// NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotification = function( callback, success, error ){
	FCMPlugin.prototype.onNotificationReceived = callback;
	exec(success, error, "FCMPlugin", 'registerNotification',[]);
}
// TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefresh = function( callback ){
	FCMPlugin.prototype.onTokenRefreshReceived = callback;
}
// GET TOKEN //
FCMPlugin.prototype.getToken = function( success, error ){
	exec(success, error, "FCMPlugin", 'getToken', []);
}
// PICK RINGTONE //
FCMPlugin.prototype.pickRingtone = function(id,sound,success, error ){
	exec(success, error, "FCMPlugin", 'ringtone', [id,sound]);
}
FCMPlugin.prototype.mute = function(id,success, error ){
	exec(success, error, "FCMPlugin", 'mute', [id]);
}

FCMPlugin.prototype.unmute = function(id,tok,success, error ){
	exec(success, error, "FCMPlugin", 'unmute', [id,tok]);
}
FCMPlugin.prototype.vibrateOn = function(id,success, error ){
	exec(success, error, "FCMPlugin", 'vibrateon', [id]);
}
FCMPlugin.prototype.vibrateOff = function(id,success, error ){
	exec(success, error, "FCMPlugin", 'vibrateoff', [id]);
}
// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotificationReceived = function(payload){
	console.log("Received push notification")
	console.log(payload)
}
// DEFAULT TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefreshReceived = function(token){
	console.log("Received token refresh")
	console.log(token)
}
// FIRE READY //
exec(function(result){ console.log("FCMPlugin Ready OK") }, function(result){ console.log("FCMPlugin Ready ERROR") }, "FCMPlugin",'ready',[]);





var fcmPlugin = new FCMPlugin();
module.exports = fcmPlugin;
