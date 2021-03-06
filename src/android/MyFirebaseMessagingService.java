package com.gae.scaffolder.plugin;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import java.util.Map;
import java.util.HashMap;
import android.net.Uri;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.net.HttpURLConnection;
import java.io.BufferedWriter;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import java.io.FileOutputStream;
import android.util.JsonWriter;
import 	java.io.IOException;
import android.util.JsonReader;
import java.util.ArrayList;
import java.io.File;
import android.database.Cursor;
import java.lang.StringBuilder;
/**
 * Created by Felipe Echanique on 08/06/2016.
 */
public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "FCMPlugin";

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // TODO(developer): Handle FCM messages here.
        // If the application is in the foreground handle both data and notification messages here.
        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
        Log.d(TAG, "==> MyFirebaseMessagingService onMessageReceived");
		
		if( remoteMessage.getNotification() != null){
			Log.d(TAG, "\tNotification Title: " + remoteMessage.getNotification().getTitle());
			Log.d(TAG, "\tNotification Message: " + remoteMessage.getNotification().getBody());
		}
		ArrayList<String> id=readFile("log.txt",this);
		if(id.size()>500)
		{
				writeFile("log.txt",id.get(249).toString(),this,false);
			for(int i=250;i<id.size();i++)
			{
			writeFile("log.txt",id.get(i).toString(),this,true);
				
			}
			
		}
		Map<String, Object> data = new HashMap<String, Object>();
		data.put("wasTapped", false);
		ArrayList<String> username=readFile("mobileNumber.txt",this);
		for (String key : remoteMessage.getData().keySet()) {
                Object value = remoteMessage.getData().get(key);
                Log.d(TAG, "\tKey: " + key + " Value: " + value);
				data.put(key, value);
				
				
				
        }
		
		Log.d(TAG, "\tNotification Data: " + data.toString());
       
		
		
		if(data.get("id")!=null && username.size()!=0)
		{
			String res = postData("http://ultranotify.com/app/api.php",new String[]{"id" ,"mobileNumber","access_token","confirmRecieve"},new String[]{data.get("id").toString(),username.get(0).split("!@!")[1],username.get(0).split("!@!")[0],""});
		 Log.d(TAG, "post response"+res);
		if(res!=null && res.contains("no-400"))
		{ 		
			 this.deleteData();
			 data = new HashMap<String, Object>();
			 data.put("valid","false");
		  FCMPlugin.sendPushPayload( data );
		}
			else if (res!=null && res.contains("ok-200")){
				data.put("valid","true");
				 FCMPlugin.sendPushPayload( data );
			 if(data.get("title")!=null&&data.get("body")!=null&&data.get("id")!=null&&(id.size()==0||!id.contains(data.get("id").toString())))
        {writeFile("log.txt",data.get("id").toString(),this,true);
			sendNotification(data.get("title").toString(), data.get("body").toString(), data);
			ArrayList<Message> messages =new ArrayList<Message>();
			readJsonFile("messages.json",this,messages);
			messages.add(new Message(remoteMessage.getData().get("id"),remoteMessage.getData().get("title"),remoteMessage.getData().get("body"),remoteMessage.getData().get("senderId"),remoteMessage.getData().get("senderName"),remoteMessage.getData().get("thumbnail_url"),remoteMessage.getData().get("thumbnail_hash"),null));
			writeJsonFile("messages.json",this,messages);
			}
			 
		 }
		}
		  
		
	}
    // [END receive_message]

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBody FCM message body received.
     */
    private void sendNotification(String title, String messageBody, Map<String, Object> data) {
        String senderId= data.get("senderId").toString();
		Intent intent;
		if(data.get("url")!=null)
		{
		 intent = new Intent(Intent.ACTION_VIEW, Uri.parse(data.get("url").toString()));
        	
		}
		else{
		 intent = new Intent(this, FCMPluginActivity.class);
        	
		}
		
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		for (String key : data.keySet()) {
			intent.putExtra(key, data.get(key).toString());
			
		}
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);
		Sender sender =FCMPlugin.getSender(senderId,this);
		   Uri soundUri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
		if(sender!=null && !sender.getSound().equals("default"))
		{
			 soundUri= Uri.parse(sender.getSound());
		}
     
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(getApplicationInfo().icon)
                .setContentTitle(title)
                .setContentText(messageBody)
                .setAutoCancel(true)
               .setContentIntent(pendingIntent);
			if(sender==null || (sender!=null  && !sender.getMuted()))
			{	 notificationBuilder.setSound(soundUri);
			}
			if(sender==null || (sender!=null  && sender.getVibrate()))
			{	 
				notificationBuilder.setVibrate(new long[] { 1000, 1000, 1000, 1000, 1000 });
			}
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }
	public static String postData(String server,String[] keys , String[] vals) {
	Log.d(TAG, "in post function");

		try{
	URL url = new URL(server);
	HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setReadTimeout(10000);
conn.setConnectTimeout(15000);
conn.setRequestMethod("POST");
conn.setDoInput(true);
conn.setDoOutput(true);

Uri.Builder builder = new Uri.Builder();
for(int i=0;i<keys.length;i++)
{
builder.appendQueryParameter(keys[i],vals[i]);

}
String query = builder.build().getEncodedQuery();
OutputStream os = conn.getOutputStream();
BufferedWriter writer = new BufferedWriter(
        new OutputStreamWriter(os, "UTF-8"));
writer.write(query);
writer.flush();
writer.close();
conn.connect();
os.close();
BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
StringBuilder sb = new StringBuilder();
String output;
while ((output = br.readLine()) != null) 
sb.append(output);
br.close();

 Log.d(TAG, "sending post");

 Log.d(TAG, "sending post done" +conn.getResponseCode());
 
return sb.toString();
}
		catch(Exception e){
		Log.d(TAG, "sending post failed + " + e.getMessage());
		
		}
		return null;
}
public void deleteData()
{
	File dir = getFilesDir();
File file = new File(dir, "mobileNumber.txt");
boolean deleted = file.delete();
	
}
public static void writeFile(String fname ,String data,Context c , boolean append) {
try {
 Log.d(TAG, "Writing to file");
 


FileOutputStream fos = c.openFileOutput(fname, (append ?Context.MODE_APPEND:Context.MODE_PRIVATE));
BufferedWriter bufferedWriter=new BufferedWriter(new OutputStreamWriter(fos));

bufferedWriter.write(data,0,data.length());
bufferedWriter.newLine();
bufferedWriter.flush();
bufferedWriter.close();
fos.close();
}
catch (Exception e){
 Log.d(TAG, "Writing to file failed "+e.getMessage());
}  
}
public static ArrayList<String> readFile(String fname,Context c)
{ArrayList<String> result = new ArrayList<String>();
try {
 Log.d(TAG, "reading file");
FileInputStream fis = c.openFileInput(fname);
   InputStreamReader isr = new InputStreamReader(fis);
   BufferedReader bufferedReader = new BufferedReader(isr);
   String s;
   while( (s= bufferedReader.readLine())!=null)
   {Log.d(TAG, " file content:"+s);
   result.add(s);
   }
	
   fis.close();
   isr.close();
   bufferedReader.close();
   }
   catch (Exception e)
   {
  
 Log.d(TAG, "failed to read file" + e.getMessage());
   
   }
return result;
}
public static void readJsonFile(String fname,Context c,ArrayList<Message> messages)
{
	try{
	
FileInputStream fis = c.openFileInput(fname);
	 InputStreamReader isr = new InputStreamReader(fis);
  JsonReader reader=new JsonReader(isr);
  reader.beginArray();
    while (reader.hasNext()) {
       messages.add(readMessage(reader));
     }
  reader.endArray();
  reader.close();	
		
	}
	catch(Exception e){
 Log.d(TAG, "failed to read json file" + e.getMessage());
		
	}
}
 public static Message readMessage(JsonReader reader) throws IOException {
      String id=null;
	 String title=null;
	 String body=null;
	 String senderId=null;
	 String thumbnail_url= null;
	 
	 String thumbnail_hash= null;
	 String senderName=null;
	String arrivalTime=null;

     reader.beginObject();
     while (reader.hasNext()) {
       String name = reader.nextName();
       if (name.equals("id")) {
         id = reader.nextString();
       } else if (name.equals("title")) {
         title = reader.nextString();
       } else if (name.equals("body") ) {
         body=reader.nextString();
       } else if (name.equals("senderName")) {
         senderName=reader.nextString();
       } else if (name.equals("senderId")) {
         senderId=reader.nextString();
       } else if (name.equals("arrivalTime")) {
         arrivalTime=reader.nextString();
       }else if (name.equals("thumbnail_url")) {
         thumbnail_url=reader.nextString();
       }else if (name.equals("thumbnail_hash")) {
         thumbnail_hash=reader.nextString();
       }  
	   else {
         reader.skipValue();
       }
     }
     reader.endObject();
     return new Message(id, title , body , senderId ,senderName,thumbnail_url,thumbnail_hash,arrivalTime );
   }
   public static void writeJsonFile(String fname ,Context c, ArrayList<Message> messages)
   {
	   try {
 Log.d(TAG, "Writing to json file");
 

FileOutputStream fos = c.openFileOutput(fname, Context.MODE_PRIVATE);
JsonWriter writer = new JsonWriter(new OutputStreamWriter(fos));
writer.setIndent("  ");
writer.beginArray();
     for (Message message : messages) {
       writeMessage(writer, message);
     }
     writer.endArray();
writer.close();
}
catch (Exception e){
 Log.d(TAG, "Writing to json file failed "+e.getMessage());
}  

	   
   }
    public static void writeMessage(JsonWriter writer, Message message) throws IOException {
     writer.beginObject();
     writer.name("id").value(message.getId());
     writer.name("title").value(message.getTitle());
     writer.name("body").value(message.getBody());
     writer.name("senderId").value(message.getSenderId());
	 writer.name("thumbnail_url").value(message.getThumbnailUrl());
	 
	 writer.name("thumbnail_hash").value(message.getThumbnailHash());
     writer.name("senderName").value(message.getSenderName());
	 writer.name("arrivalTime").value(Long.toString(message.getArrivalTime()));
    
     writer.endObject();
   }
   public ArrayList<String> getNotificationSounds() {
    RingtoneManager manager = new RingtoneManager(this);
    manager.setType(RingtoneManager.TYPE_NOTIFICATION);
    Cursor cursor = manager.getCursor();

    ArrayList<String> list = new ArrayList<String>();
    while (cursor.moveToNext()) {
        String id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX);
        String uri = cursor.getString(RingtoneManager.URI_COLUMN_INDEX);

        list.add(uri + "/" + id);
    }

    return list;
}
}
