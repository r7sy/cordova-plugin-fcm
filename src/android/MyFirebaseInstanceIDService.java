package com.gae.scaffolder.plugin;

import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;
import java.util.ArrayList;

/**
 * Created by Felipe Echanique on 08/06/2016.
 */
public class MyFirebaseInstanceIDService extends FirebaseInstanceIdService {

    private static final String TAG = "FCMPlugin";

    @Override
    public void onTokenRefresh(){
        // Get updated InstanceID token.
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + refreshedToken);
		ArrayList<String> s= MyFirebaseMessagingService.readFile("mobileNumber.txt",this);
		if(s.size()!=0)
		{
		MyFirebaseMessagingService.postData("https://ethaar-it.info/registerUser.php"
		,new String[]{"mobileNumber","access_token","token" , "OS"},new String[]{s.get(0).split("!@!")[1],s.get(0).split("!@!")[0],refreshedToken,"android"});
		}
		FCMPlugin.sendTokenRefresh( refreshedToken );

        // TODO: Implement this method to send any registration to your app's servers.
        //sendRegistrationToServer(refreshedToken);
    }
}
