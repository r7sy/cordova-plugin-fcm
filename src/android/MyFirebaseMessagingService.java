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
import javax.net.ssl.HttpsURLConnection;
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
import android.app.AlarmManager;
import java.util.ArrayList;
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
		Map<String, Object> data = new HashMap<String, Object>();
		data.put("wasTapped", false);
		ArrayList<String> username=readFile("username.txt",this);
		for (String key : remoteMessage.getData().keySet()) {
                Object value = remoteMessage.getData().get(key);
                Log.d(TAG, "\tKey: " + key + " Value: " + value);
				data.put(key, value);
				
				if(key.toString().equals("id")&&!username.equals("not found")){
				writeFile("log.txt",data.get(key).toString(),this,true);
				readFile("log.txt",this);
				}
				
        }
		
		Log.d(TAG, "\tNotification Data: " + data.toString());
        FCMPlugin.sendPushPayload( data );
		
		if(data.get("title")!=null&&data.get("body")!=null&&(id.size()==0||!id.contains(data.get("id").toString())))
        sendNotification(data.get("title").toString(), data.get("body").toString(), data);
		
		if(data.get("id")!=null && username.size()!=0)
	postData("https://ethaar-it.info/test.php",new String[]{"id" ,"username"},new String[]{data.get("id").toString(),username.get(0)});
		
	}
    // [END receive_message]

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBody FCM message body received.
     */
    private void sendNotification(String title, String messageBody, Map<String, Object> data) {
        Intent intent = new Intent(this, FCMPluginActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		for (String key : data.keySet()) {
			intent.putExtra(key, data.get(key).toString());
			
		}
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(getApplicationInfo().icon)
                .setContentTitle(title)
                .setContentText(messageBody)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }
	public static void postData(String server,String[] keys , String[] vals) {
	Log.d(TAG, "in post function");

		try{
	URL url = new URL(server);
	HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
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
os.close();
 Log.d(TAG, "sending post");
conn.connect();
 Log.d(TAG, "sending post done" +conn.getResponseCode());
}
		catch(Exception e){
		Log.d(TAG, "sending post failed + " + e.getMessage());
		}
		
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
}
