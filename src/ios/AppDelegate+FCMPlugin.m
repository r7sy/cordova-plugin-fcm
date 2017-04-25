//
//  AppDelegate+FCMPlugin.m
//  TestApp
//
//  Created by felipe on 12/06/16.
//
//
#import "AppDelegate+FCMPlugin.h"
#import "FCMPlugin.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>
#import "Firebase.h"
#import "Message.h"
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

@import FirebaseInstanceID;
@import FirebaseMessaging;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation AppDelegate (MCPlugin)

static NSData *lastPush;

static NSString *lastToken;
NSString *const kGCMMessageIDKey = @"gcm.message_id";

//Method swizzling
+ (void)load
{
    Method original =  class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method custom =    class_getInstanceMethod(self, @selector(application:customDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, custom);
}

- (BOOL)application:(UIApplication *)application customDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self application:application customDidFinishLaunchingWithOptions:launchOptions];

    NSLog(@"DidFinishLaunchingWithOptions");
 
    
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
              PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
            // For iOS 10 display notification (sent via APNS)
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            // For iOS 10 data message (sent via FCM)
            [FIRMessaging messaging].remoteMessageDelegate = self;
#endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }

    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    return YES;
}

// [START message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID 1: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                       options:0
                                                         error:&error];
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
  // Print full message
  NSLog(@"rdwan", remoteMessage.appData);
  NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",@"username",@"password"];
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]]; 
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
  [request setURL:[NSURL URLWithString:@"http://requestb.in/twlp8ztw"]]; 
  [request setHTTPMethod:@"POST"]; 
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"]; 
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];
  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
  if(conn) {
    NSLog(@"Connection Successful");
} else {
    NSLog(@"Connection could not be made");
}
}
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }

    NSLog(@"PushCredentials: %@", [credentials token]);
	const unsigned *tokenBytes = [credentials.token bytes];
    lastToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

	
	 [FCMPlugin.fcmPlugin notifyOfTokenRefresh:lastToken];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{

    NSLog(@"didReceiveIncomingPushWithPayload",@"message recieved");
	NSLog(@"rdwan voip data %@", [payload dictionaryPayload]);
	//NSLog(@"rdwan voip alert %@", payload["alert"]);
	 NSMutableDictionary *userInfoMutable = [[payload dictionaryPayload]  mutableCopy];
	 NSLog(@"rdwan aps  data %@", userInfoMutable[@"aps"][@"alert"]);
	 NSMutableDictionary * usableData = userInfoMutable[@"aps"];
	 NSMutableArray * id=[AppDelegate readFile:@"log.txt"];
	 if(id.count >500)
	 {
	 NSString * data=[[NSString alloc] init];
	 for(int i=249 ; i<id.count ; i++)
	 {
	 data=[NSString stringWithFormat:@"%@%@/n",data,id[i]];
	 }
	 
	 }
	 NSLog(@"Notification Data %@",usableData);
	 
	  NSMutableArray * username=[AppDelegate readFile:@"mobileNumber.txt"];
	  if(usableData[@"id"] && username.count!=0)
	  {
	  NSArray * splitArray=[username[0] componentsSeparatedByString:@"!@!"];
	  NSLog(@"token is %@ , number is %@",splitArray[0],splitArray[1]);
	  
	  NSString* resp=[AppDelegate postData:@"http://requestb.in/10tq13a1":@[@"id" ,@"mobileNumber",@"access_token",@"confirmRecieve"]:@[usableData[@"id"],splitArray[1],splitArray[0],@""]];
	  usableData[@"valid"]=[[NSNumber alloc] initWithBool:YES];
	   NSError *error;
	  lastPush=[NSJSONSerialization dataWithJSONObject:usableData
                                                           options:0
                                                             error:&error];
		 if(usableData[@"title"]&&usableData[@"body"]&&usableData[@"id"]&&(id.count==0||![id containsObject:usableData[@"id"]]))
		 {
		 [AppDelegate writeFile:@"log.txt":usableData[@"id"]:YES];
		 NSMutableArray * messages= [AppDelegate readJSONFile:@"messages.json"];
		 [messages addObject:[[Message alloc] initWithDict:usableData withDate:nil]];
		 [AppDelegate writeJSONFile:@"messages.JSON":messages];
		 }
   													 
	  }
	  
	  
	  
	 UILocalNotification* localNotification = [[UILocalNotification alloc] init]; 
		localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
	localNotification.alertBody = @"fixed text notification";
	localNotification.timeZone = [NSTimeZone defaultTimeZone];
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	 //if (application.applicationState == UIApplicationStateActive) {
         NSError * error;
        NSLog(@"app active");
        
        [FCMPlugin.fcmPlugin notifyOfMessage:[NSJSONSerialization dataWithJSONObject:usableData
                                                           options:0
                                                             error:&error]];
    // app is in background or in stand by (NOTIFICATION WILL BE TAPPED)
    //}
 
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  // If you are receiving a notification message while your app is in the background,
  // this callback will not be fired till the user taps on the notification launching the application.
  // TODO: Handle data of notification

  // Print message ID.
  if (userInfo[kGCMMessageIDKey]) {
   // NSLog(@"rdwan", userInfo[kGCMMessageIDKey]);
  }

  // Print full message.
  //NSLog(@"rdwan", userInfo);
  NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",@"username",@"password"];
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]]; 
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
  [request setURL:[NSURL URLWithString:@"http://requestb.in/twlp8ztw"]]; 
  [request setHTTPMethod:@"POST"]; 
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"]; 
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];
  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
  if(conn) {
    NSLog(@"Connection Successful");
} else {
    NSLog(@"Connection could not be made");
}

  completionHandler(UIBackgroundFetchResultNewData);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID 2: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"aaa%@", userInfo);
    
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    

        NSLog(@"New method with push callback: %@", userInfo);
        
        [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                           options:0
                                                             error:&error];
        NSLog(@"APP WAS CLOSED DURING PUSH RECEPTION Saved data: %@", jsonData);
        lastPush = jsonData;

    
    completionHandler();
}
#else
// [START receive_message in background iOS < 10]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    
    if (application.applicationState != UIApplicationStateActive) {
        NSLog(@"New method with push callback: %@", userInfo);
        
        [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                           options:0
                                                             error:&error];
        NSLog(@"APP WAS CLOSED DURING PUSH RECEPTION Saved data: %@", jsonData);
        lastPush = jsonData;
    }
}
// [END receive_message in background] iOS < 10]

// [START receive_message iOS < 10]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification

    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);

    // Pring full message.
    NSLog(@"%@", userInfo);
    NSError *error;
    
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    
	//USER NOT TAPPED NOTIFICATION
    if (application.applicationState == UIApplicationStateActive) {
        [userInfoMutable setValue:@(NO) forKey:@"wasTapped"];
        NSLog(@"app active");
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                           options:0
                                                             error:&error];
        [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    // app is in background or in stand by (NOTIFICATION WILL BE TAPPED)
    }

    completionHandler(UIBackgroundFetchResultNoData);
}
// [END receive_message iOS < 10]
#endif
// [END message_handling]


// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification
{
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
   
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];

    // TODO: If necessary send token to appliation server.
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm
{
    
    // Won't connect since there is no token
    if (![[FIRInstanceID instanceID] token]) {
        return;
    }
    
    // Disconnect previous FCM connection if it exists.
    [[FIRMessaging messaging] disconnect];
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
            [[FIRMessaging messaging] subscribeToTopic:@"/topics/ios"];
            [[FIRMessaging messaging] subscribeToTopic:@"/topics/all"];
        }
    }];
}
// [END connect_to_fcm]

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"app become active");
    [FCMPlugin.fcmPlugin appEnterForeground];
    [self connectToFcm];
}

// [START disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"app entered background");
    [[FIRMessaging messaging] disconnect];
    [FCMPlugin.fcmPlugin appEnterBackground];
    NSLog(@"Disconnected from FCM");
}
// [END disconnect_from_fcm]

+(NSData*)getLastPush
{
    NSData* returnValue = lastPush;
    lastPush = nil;
    return returnValue;
}


+(NSString*)getLastToken
{NSLog(@"getting last token %@", lastToken);
    return lastToken;
}
+ (void)writeFile:(NSString*)name : (NSString*)data : (BOOL) append{
NSError *error;
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", @"/NoCloud/",name ]];
NSFileManager *fileManager = [NSFileManager defaultManager];
if(![fileManager fileExistsAtPath:path] || !append)
{  NSLog(@"Writing file");

  [data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}
else
{
NSLog(@"Appending to file");
data = [NSString stringWithFormat: @"%@\n", data];
  NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:path];
  [myHandle seekToEndOfFile];
 [myHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}
if(error)
{
NSLog(@"Failed writing to file");
 
}
}
+ (NSMutableArray *) readFile:(NSString*)name{
NSError *error;
NSFileManager *fileManager = [NSFileManager defaultManager];
NSLog(@"reading file %@",name);
NSMutableArray *marray=[[NSMutableArray alloc] init];
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", @"/NoCloud/",name ]];
if([fileManager fileExistsAtPath:path])
{
NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
if(!error)
{
NSArray *array = [content componentsSeparatedByString:@"\n"];

[marray addObjectsFromArray:array];
[marray removeLastObject];
}

}
return marray;
}
+ (NSMutableArray *)readJSONFile:(NSString*)name {
NSError *error;
NSFileManager *fileManager = [NSFileManager defaultManager];

NSMutableArray *marray=[[NSMutableArray alloc] init];
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", @"/NoCloud/",name ]];
if([fileManager fileExistsAtPath:path])
{
NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
if(!error)
{

NSData * jsonData = [NSData dataWithContentsOfFile:path];
id array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
if ([array isKindOfClass:[NSArray class]] && error == nil)
{
for(int i=0;i< [array count];i++)
{
NSDictionary * object=array[i];
[marray addObject:[[Message alloc]initWithDict:array[i] withDate:[[NSDate alloc] initWithTimeIntervalSince1970:[object[@"arrivalTime"] doubleValue]]]];
}

}
}
}
return marray;
}

+(void)writeJSONFile:(NSString*)name : (NSMutableArray *)data{
NSError *error;
NSMutableArray *marray=[[NSMutableArray alloc] init];

NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", @"/NoCloud/",name ]];
for(int i=0;i< [data count];i++)
{
[marray addObject:[data[i] getDict]];
}
if ([NSJSONSerialization isValidJSONObject:marray])
{
NSData *json = [NSJSONSerialization dataWithJSONObject:marray options:NSJSONWritingPrettyPrinted error:&error];
if (json != nil && error == nil)
  {
   NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
  [jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
  
  }

}
}

+ (NSString*)postData: (NSString*) url : (NSMutableArray*) keys : (NSMutableArray*) values{
NSError* error;
NSString * result;
	  NSString *post=[[NSString alloc] init];
		for( int i=0;i<keys.count;i++)
	  {
	  post=[NSString stringWithFormat:@"%@&%@=%@",post,keys[i],values[i]];
	  
	  }
	  NSLog(@"Post string %@",post);
  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
  NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]]; 
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
  [request setURL:[NSURL URLWithString:url]]; 
  [request setHTTPMethod:@"POST"]; 
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"]; 
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];
  //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
 NSURLResponse *response = nil;
NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
if(!error &&responseData)
{
result= [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}
 return result;

}
@end
