package com.gae.scaffolder.plugin;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import android.net.Uri;
import org.apache.cordova.PluginResult;
import android.util.Log;
import android.content.Context;
import com.twilio.voice.Call;
import android.Manifest;
import 	java.util.Collections;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;
import com.twilio.voice.Voice;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.FileInputStream;
import android.support.v4.app.ActivityCompat;
import java.io.InputStreamReader;
import com.twilio.voice.LogLevel;
import java.io.BufferedReader;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import android.os.Bundle;
import java.io.FileOutputStream;
import android.util.JsonWriter;
import 	java.io.IOException;
import android.util.JsonReader;
import java.util.ArrayList;
import java.io.BufferedWriter;
import android.media.AudioManager;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.iid.FirebaseInstanceId;
import android.media.RingtoneManager;
import android.content.Intent;
import java.util.Map;

public class FCMPlugin extends CordovaPlugin {
 
	private static final String TAG = "FCMPlugin";
	private CallbackContext callback;
	public static CordovaWebView gWebView;
	public static String notificationCallBack = "FCMPlugin.onNotificationReceived";
	public static String tokenRefreshCallBack = "FCMPlugin.onTokenRefreshReceived";
	public Call currentCall;
	public static String callConnectedCallBack = "FCMPlugin.onCallConnected";
	public static String callDisconnectedCallBack = "FCMPlugin.onCallDisconnected";
	
	public static Boolean notificationCallBackReady = false;
	
	public static Boolean callConnectedCallBackReady = false;
	
	public static Boolean callDisconnectedCallBackReady = false;
	public static Map<String, Object> lastPush = null;
	 private AudioManager audioManager;
    private int savedAudioMode = AudioManager.MODE_INVALID;
	 public String senderId;
	public FCMPlugin() {}
	
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);
		gWebView = webView;
		Log.d(TAG, "==> FCMPlugin initialize");
		FirebaseMessaging.getInstance().subscribeToTopic("android");
		FirebaseMessaging.getInstance().subscribeToTopic("all");
	}
	 private Call.Listener callListener() {
        return new Call.Listener() {
            public void onConnected(Call call) {
				
                Log.d(TAG, "Connected to voip call");
				FCMPlugin.callConnected();
            }

            @Override
            public void onDisconnected(Call call, CallException error) {
                
                Log.d(TAG, "Disconnected from voip call");
				FCMPlugin.callDisconnected();
                if(error != null) {
                    String message = String.format("Call Error: %d, %s", error.getErrorCode(), error.getMessage());
                    Log.e(TAG, message);
                    }
            }
			
        };
    }

	public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

		Log.d(TAG,"==> FCMPlugin execute: "+ action);
		
		try{
				// READY //
			if (action.equals("ready")) {
				//
				callbackContext.success();
			}
		// CHOOSE RINGTONE //
		else if (action.equals("ringtone"))
		{callback = callbackContext;
			Intent intent = new Intent(RingtoneManager.ACTION_RINGTONE_PICKER);
		  intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION);
		  intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Select RingTone");
		  intent.putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, (Uri) null);
		  this.senderId=args.getString(0);
		   PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
			r.setKeepCallback(true);
			callbackContext.sendPluginResult(r);
			cordova.startActivityForResult((CordovaPlugin) this,intent, 5);
			return true;
		}
		// MUTE //
		else if (action.equals("mute"))
		{
			
			muteSender(args.getString(0));
			callbackContext.success( );
		}
		// UNMUTE //
		else if (action.equals("unmute"))
		{
		requestPermissionForMicrophone();
			unmuteSender(args.getString(0));
			callbackContext.success( );
		}
		// VIBRATION ON //
		else if (action.equals("vibrateon"))
		{
			turnVibrateOn(args.getString(0));
			callbackContext.success( );
		}
		// VIBRATIon OFF //
		else if (action.equals("vibrateoff"))
		{
			turnVibrateOff(args.getString(0));
			callbackContext.success( );
		}
			// GET TOKEN //
			else if (action.equals("getToken")) {
				cordova.getActivity().runOnUiThread(new Runnable() {
					public void run() {
						try{
							String token = FirebaseInstanceId.getInstance().getToken();
							
							callbackContext.success( FirebaseInstanceId.getInstance().getToken() );
							Log.d(TAG,"\tToken: "+ token);
						}catch(Exception e){
							Log.d(TAG,"\tError retrieving token");
						}
					}
				});
			}
			// NOTIFICATION CALLBACK REGISTER //
			else if (action.equals("registerNotification")) {
				notificationCallBackReady = true;
				cordova.getActivity().runOnUiThread(new Runnable() {
					public void run() {
						if(lastPush != null) FCMPlugin.sendPushPayload( lastPush );
						lastPush = null;
						callbackContext.success();
					}
				});
			}
			else if (action.equals("connectSupport")) {
				Voice.setLogLevel(LogLevel.DEBUG);
			currentCall=Voice.call(this.cordova.getActivity().getApplicationContext(),args.getString(0),Collections.<String, String>emptyMap(),callListener());
			
				
				callbackContext.success();
					
			}
			else if (action.equals("disconnectSupport")) 
			{
			try{
			currentCall.disconnect();
			}
			catch(Exception e)
			{
			}
			callbackContext.success();
			}
			// UN/SUBSCRIBE TOPICS //
			else if (action.equals("subscribeToTopic")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
							FirebaseMessaging.getInstance().subscribeToTopic( args.getString(0) );
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
			}
			else if (action.equals("unsubscribeFromTopic")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
							FirebaseMessaging.getInstance().unsubscribeFromTopic( args.getString(0) );
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
			}
			else{
				callbackContext.error("Method not found");
				return false;
			}
		}catch(Exception e){
			Log.d(TAG, "ERROR: onPluginAction: " + e.getMessage());
			callbackContext.error(e.getMessage());
			return false;
		}
		
		//cordova.getThreadPool().execute(new Runnable() {
		//	public void run() {
		//	  //
		//	}
		//});
		
		//cordova.getActivity().runOnUiThread(new Runnable() {
        //    public void run() {
        //      //
        //    }
        //});
		return true;
	}
	
	public static void sendPushPayload(Map<String, Object> payload) {
		Log.d(TAG, "==> FCMPlugin sendPushPayload");
		Log.d(TAG, "\tnotificationCallBackReady: " + notificationCallBackReady);
		Log.d(TAG, "\tgWebView: " + gWebView);
	    try {
		    JSONObject jo = new JSONObject();
			for (String key : payload.keySet()) {
			    jo.put(key, payload.get(key));
				Log.d(TAG, "\tpayload: " + key + " => " + payload.get(key));
            }
			String callBack = "javascript:" + notificationCallBack + "(" + jo.toString() + ")";
			if(notificationCallBackReady && gWebView != null){
				Log.d(TAG, "\tSent PUSH to view: " + callBack);
				gWebView.sendJavascript(callBack);
			}else {
				Log.d(TAG, "\tView not ready. SAVED NOTIFICATION: " + callBack);
				lastPush = payload;
			}
		} catch (Exception e) {
			Log.d(TAG, "\tERROR sendPushToView. SAVED NOTIFICATION: " + e.getMessage());
			lastPush = payload;
		}
	}

	public static void sendTokenRefresh(String token) {
		Log.d(TAG, "==> FCMPlugin sendRefreshToken");
	  try {
			String callBack = "javascript:" + tokenRefreshCallBack + "('" + token + "')";
			gWebView.sendJavascript(callBack);
		} catch (Exception e) {
			Log.d(TAG, "\tERROR sendRefreshToken: " + e.getMessage());
		}
	}
	public static void callConnected( ) {
		Log.d(TAG, "==> FCMPlugin call connected");
	  try {
			String callBack = "javascript:" + callConnectedCallBack + "(" +  ")";
			gWebView.sendJavascript(callBack);
		} catch (Exception e) {
			Log.d(TAG, "\tERROR callConnected: " + e.getMessage());
		}
	}
	public static void callDisconnected( ) {
		Log.d(TAG, "==> FCMPlugin call disconnected");
	  try {
			String callBack = "javascript:" + callDisconnectedCallBack + "(" +  ")";
			gWebView.sendJavascript(callBack);
		} catch (Exception e) {
			Log.d(TAG, "\tERROR callDisconnected: " + e.getMessage());
		}
	}
  
  @Override
	public void onDestroy() {
		gWebView = null;
		notificationCallBackReady = false;
	}
	@Override
public void onActivityResult(final int requestCode, final int resultCode, final Intent intent)
 {
	 Log.d(TAG, "==> FCMPlugin onActivityResult");
     if (resultCode == Activity.RESULT_OK && requestCode == 5)
     {
          Uri uri = intent.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI);
         String result = new String();
          if (uri != null)
          {
              result = uri.toString();
          }
          else
          {
              result =  "none";
			
		 }
		  Log.d(TAG, result);
		  this.updateSenderSound(this.senderId,result);
		  this.callback.success( result);

		  
      }            
  }
  public static void readJsonFile(String fname,Context c,ArrayList<Sender> senders)
{
	try{
	
FileInputStream fis = c.openFileInput(fname);
	 InputStreamReader isr = new InputStreamReader(fis);
  JsonReader reader=new JsonReader(isr);
  reader.beginArray();
    while (reader.hasNext()) {
       senders.add(readSender(reader));
     }
  reader.endArray();
  reader.close();	
		
	}
	catch(Exception e){
 Log.d(TAG, "failed to read json file" + e.getMessage());
		
	}
}
   public static Sender readSender(JsonReader reader) throws IOException {
      String id=null;
	 String sound=null;
	boolean muted=false;
	
	boolean vibrate=true;
     reader.beginObject();
     while (reader.hasNext()) {
       String name = reader.nextName();
       if (name.equals("id")) {
         id = reader.nextString();
       } else if (name.equals("sound")) {
         sound = reader.nextString();
       }
		else if (name.equals("muted")) {
         muted = reader.nextBoolean();
       }
else if (name.equals("vibrate")) {
         vibrate = reader.nextBoolean();
       }	   	   
	   else {
         reader.skipValue();
       }
     }
     reader.endObject();
     return new Sender(id, sound , muted ,vibrate );
   }
  
  
  public static void writeJsonFile(String fname ,Context c, ArrayList<Sender> senders)
   {
	   try {
 Log.d(TAG, "Writing senders to json file");
 


FileOutputStream fos = c.openFileOutput(fname, Context.MODE_PRIVATE);
JsonWriter writer = new JsonWriter(new OutputStreamWriter(fos));
writer.setIndent("  ");
writer.beginArray();
     for (Sender sender : senders) {
       writeSender(writer, sender);
     }
     writer.endArray();
writer.close();
}
catch (Exception e){
 Log.d(TAG, "Writing to json file failed "+e.getMessage());
}  

	   
   }
  public static void writeSender(JsonWriter writer, Sender sender) throws IOException {
     writer.beginObject();
     writer.name("id").value(sender.getId());
     writer.name("muted").value(sender.getMuted());
	 
     writer.name("vibrate").value(sender.getVibrate());
	 writer.name("sound").value(sender.getSound());
    
     writer.endObject();
   }
   public  void updateSenderSound(String id , String sound)
   { ArrayList<Sender> senders = new ArrayList<Sender>();
	 try{
		  readJsonFile("senders.json",cordova.getActivity(),senders);
	   boolean found = false;
	   for(int i=0; i < senders.size() ;i++)
	   {
		   if(senders.get(i).getId().equals(id))
		   {
			   if(sound.equals("none")) 
			   {
				   senders.get(i).setMuted(true);
				   
			   }
			   else{
			    senders.get(i).setSound(sound);
			   senders.get(i).setMuted(false);
			   }
			  
			   found=true;
			   break;
		   }
		   
	   }
	   if(!found)
	   {
		   senders.add(new Sender(id,sound,false,true));
		   
	   }
	 } 
	 catch(Exception e)
	 {
		 
	 }try {
		  writeJsonFile("senders.json",cordova.getActivity(),senders);
		 
	 }catch (Exception e ) {
		 
		 
	 }
	  
   }
   public  void muteSender(String id )
   { ArrayList<Sender> senders = new ArrayList<Sender>();
	 try{
		  readJsonFile("senders.json",cordova.getActivity(),senders);
	   boolean found = false;
	   for(int i=0; i < senders.size() ;i++)
	   {
		   if(senders.get(i).getId().equals(id))
		   {
			   senders.get(i).setMuted(true);
			   found=true;
			   break;
		   }
		   
	   }
	   if(!found)
	   {
		   senders.add(new Sender(id,"default",true,true));
		   
	   }
	 } 
	 catch(Exception e)
	 {
		 
	 }try {
		  writeJsonFile("senders.json",cordova.getActivity(),senders);
		 
	 }catch (Exception e ) {
		 
		 
	 }
	  
   }
   public  void unmuteSender(String id )
   { ArrayList<Sender> senders = new ArrayList<Sender>();
	 try{
		  readJsonFile("senders.json",cordova.getActivity(),senders);
	   boolean found = false;
	   for(int i=0; i < senders.size() ;i++)
	   {
		   if(senders.get(i).getId().equals(id))
		   {
			   senders.get(i).setMuted(false);
			   found=true;
			   break;
		   }
		   
	   }
	   if(!found)
	   {
		   senders.add(new Sender(id,"default",false,true));
		   
	   }
	 } 
	 catch(Exception e)
	 {
		 
	 }try {
		  writeJsonFile("senders.json",cordova.getActivity(),senders);
		 
	 }catch (Exception e ) {
		 
		 
	 }
	  
   }
   public  void turnVibrateOn(String id )
   { ArrayList<Sender> senders = new ArrayList<Sender>();
	 try{
		  readJsonFile("senders.json",cordova.getActivity(),senders);
	   boolean found = false;
	   for(int i=0; i < senders.size() ;i++)
	   {
		   if(senders.get(i).getId().equals(id))
		   {
			   senders.get(i).setVibrate(true);
			   found=true;
			   break;
		   }
		   
	   }
	   if(!found)
	   {
		   senders.add(new Sender(id,"default",true,true));
		   
	   }
	 } 
	 catch(Exception e)
	 {
		 
	 }try {
		  writeJsonFile("senders.json",cordova.getActivity(),senders);
		 
	 }catch (Exception e ) {
		 
		 
	 }
	  
   }
    public  void turnVibrateOff(String id )
   { ArrayList<Sender> senders = new ArrayList<Sender>();
	 try{
		  readJsonFile("senders.json",cordova.getActivity(),senders);
	   boolean found = false;
	   for(int i=0; i < senders.size() ;i++)
	   {
		   if(senders.get(i).getId().equals(id))
		   {
			   senders.get(i).setVibrate(false);
			   found=true;
			   break;
		   }
		   
	   }
	   if(!found)
	   {
		   senders.add(new Sender(id,"default",true,false));
		   
	   }
	 } 
	 catch(Exception e)
	 {
		 
	 }try {
		  writeJsonFile("senders.json",cordova.getActivity(),senders);
		 
	 }catch (Exception e ) {
		 
		 
	 }
	  
   }
   
   public static Sender getSender(String id,Context c)
   {  Log.d(TAG, "getting id for sender " + id);
	   ArrayList<Sender> senders = new ArrayList<Sender>();
	   try{
		readJsonFile("senders.json",c,senders);
	   for(int i=0; i < senders.size() ;i++)
	   {
		   if(senders.get(i).getId().equals(id))
		   {  Log.d(TAG, "getting id for sender " + id + senders.get(i).getSound() );
			   return senders.get(i);
		   }
		   
	   }   
	   }catch (Exception e)
	   {
		   Log.d(TAG, e.getMessage());
	   }

	   return null;
   }
   private void requestPermissionForMicrophone() {
        ActivityCompat.requestPermissions(
                    cordova.getActivity(),
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    1);
    }

} 
