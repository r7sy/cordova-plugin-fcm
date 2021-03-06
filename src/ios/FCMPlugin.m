#include <sys/types.h>
#include <sys/sysctl.h>
@import TwilioVoice;
#import "AppDelegate+FCMPlugin.h"
#import "Message.h"
#import "Sender.h"
#import <Cordova/CDV.h>
#import "FCMPlugin.h"
#import "Firebase.h"

@interface FCMPlugin () {}
@end

@implementation FCMPlugin

static BOOL notificatorReceptorReady = NO;
static BOOL appInForeground = YES;

static NSString *notificationCallback = @"FCMPlugin.onNotificationReceived";
static NSString *tokenRefreshCallback = @"FCMPlugin.onTokenRefreshReceived";
TVOCall * currentCall;
static NSString *callConnectedCallBack = @"FCMPlugin.onCallConnected";
static NSString *callDisconnectedCallBack = @"FCMPlugin.onCallDisconnected";
static FCMPlugin *fcmPluginInstance;

+ (FCMPlugin *) fcmPlugin {
    
    return fcmPluginInstance;
}

- (void) ready:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova view ready");
    fcmPluginInstance = self;
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

- (void) connectSupport : (CDVInvokedUrlCommand*) command{
[self.commandDelegate runInBackground:^{

currentCall =[[TwilioVoice sharedInstance] call:[command.arguments objectAtIndex:0] params:NULL delegate:self];;


}];
}
- (void) disconnectSupport : (CDVInvokedUrlCommand*) command{
[self.commandDelegate runInBackground:^{
if(currentCall)
{
[currentCall disconnect];
}}];
}
- (void) ringtone : (CDVInvokedUrlCommand*) command{

NSNumber* id=[command.arguments objectAtIndex:0];
NSString* sound=[command.arguments objectAtIndex:1];
 [self.commandDelegate runInBackground:^{
   NSMutableArray* senders = [FCMPlugin readJSONFile:@"senders.json"];
   BOOL found = NO;
   for(int i=0;i<senders.count;i++)
		{
		NSNumber * temp= (NSNumber *) [senders[i] id];
		if([id intValue]== [temp intValue]){
		Sender* s1=(Sender *) senders[i];
		s1.sound=sound;
		s1.muted=[[NSNumber alloc] initWithBool:NO];
		found=YES;
		break;
		}
		
		}
		if(!found)
		{
		NSDictionary * dict=@{@"id":id,@"sound":sound,@"muted":[[NSNumber alloc] initWithBool:NO],@"vibrate":[[NSNumber alloc] initWithBool:YES]};
		Sender * s=[[Sender alloc] initWithDict:dict];
		[senders addObject:s];
		}
		[FCMPlugin writeJSONFile:@"senders.json":senders];
   }];

}
- (void) mute : (CDVInvokedUrlCommand*) command{

NSNumber* id=[command.arguments objectAtIndex:0];
 [self.commandDelegate runInBackground:^{
   NSMutableArray* senders = [FCMPlugin readJSONFile:@"senders.json"];
   BOOL found = NO;
   for(int i=0;i<senders.count;i++)
		{
		NSNumber * temp= (NSNumber *) [senders[i] id];
		if([id intValue]== [temp intValue]){
		Sender* s1=(Sender *) senders[i];
		s1.muted=[[NSNumber alloc] initWithBool:YES];
		found=YES;
		break;
		}
		
		}
		if(!found)
		{
		NSDictionary * dict=@{@"id":id,@"sound":@"default",@"muted":[[NSNumber alloc] initWithBool:YES],@"vibrate":[[NSNumber alloc] initWithBool:YES]};
		Sender * s=[[Sender alloc] initWithDict:dict];
		[senders addObject:s];
		}
		[FCMPlugin writeJSONFile:@"senders.json":senders];
   }];

}
- (void) unmute : (CDVInvokedUrlCommand*) command{
 

NSNumber* id=[command.arguments objectAtIndex:0];
 [self.commandDelegate runInBackground:^{
   NSMutableArray* senders = [FCMPlugin readJSONFile:@"senders.json"];
   BOOL found = NO;
   for(int i=0;i<senders.count;i++)
		{
	NSNumber * temp= (NSNumber *) [senders[i] id];
		if([id intValue]== [temp intValue]){
		Sender* s1=(Sender *) senders[i];
		s1.muted=[[NSNumber alloc] initWithBool:NO];
		found=YES;
		break;
		}
		
		}
		if(!found)
		{
		NSDictionary * dict=@{@"id":id,@"sound":@"default",@"muted":[[NSNumber alloc] initWithBool:NO],@"vibrate":[[NSNumber alloc] initWithBool:YES]};
		Sender * s=[[Sender alloc] initWithDict:dict];
		[senders addObject:s];
		}
		[FCMPlugin writeJSONFile:@"senders.json":senders];
   }];

}
- (void) vibrateon : (CDVInvokedUrlCommand*) command{

NSNumber* id=[command.arguments objectAtIndex:0];
 [self.commandDelegate runInBackground:^{
   NSMutableArray* senders = [FCMPlugin readJSONFile:@"senders.json"];
   BOOL found = NO;
   for(int i=0;i<senders.count;i++)
		{
NSNumber * temp= (NSNumber *) [senders[i] id];
		if([id intValue]== [temp intValue]){
		Sender* s1=(Sender *) senders[i];
		s1.vibrate=[[NSNumber alloc] initWithBool:YES];
		found=YES;
		break;
		}
		
		}
		if(!found)
		{
		NSDictionary * dict=@{@"id":id,@"sound":@"default",@"muted":[[NSNumber alloc] initWithBool:NO],@"vibrate":[[NSNumber alloc] initWithBool:YES]};
		Sender * s=[[Sender alloc] initWithDict:dict];
		[senders addObject:s];
		}
		[FCMPlugin writeJSONFile:@"senders.json":senders];
   }];

}
- (void) vibrateoff : (CDVInvokedUrlCommand*) command{

NSNumber* id=[command.arguments objectAtIndex:0];
 [self.commandDelegate runInBackground:^{
   NSMutableArray* senders = [FCMPlugin readJSONFile:@"senders.json"];
   BOOL found = NO;
   for(int i=0;i<senders.count;i++)
		{
NSNumber * temp= (NSNumber *) [senders[i] id];
		if([id intValue]== [temp intValue]){
		Sender* s1=(Sender *) senders[i];
		s1.vibrate=[[NSNumber alloc] initWithBool:NO];
		found=YES;
		break;
		}
		
		}
		if(!found)
		{
		NSDictionary * dict=@{@"id":id,@"sound":@"default",@"muted":[[NSNumber alloc] initWithBool:NO],@"vibrate":[[NSNumber alloc] initWithBool:NO]};
		Sender * s=[[Sender alloc] initWithDict:dict];
		[senders addObject:s];
		}
		[FCMPlugin writeJSONFile:@"senders.json":senders];
   }];

}
// GET TOKEN //
- (void) getToken:(CDVInvokedUrlCommand *)command 
{ 
    [self.commandDelegate runInBackground:^{
	
   
	
        NSString* token = [AppDelegate getLastToken];
		NSLog(@"got last token %@", token);
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// UN/SUBSCRIBE TOPIC //
- (void) subscribeToTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"subscribe To Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) unsubscribeFromTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"unsubscribe From Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) registerNotification:(CDVInvokedUrlCommand *)command
{
    NSLog(@"view registered for notifications");
    
    notificatorReceptorReady = YES;
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) notifyOfMessage:(NSData *)payload
{
    NSString *JSONString = [[NSString alloc] initWithBytes:[payload bytes] length:[payload length] encoding:NSUTF8StringEncoding];
    NSString * notifyJS = [NSString stringWithFormat:@"%@(%@);", notificationCallback, JSONString];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) notifyOfTokenRefresh:(NSString *)token
{
 
    NSString * notifyJS = [NSString stringWithFormat:@"%@('%@');", tokenRefreshCallback, token];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) appEnterBackground
{
    NSLog(@"Set state background");
    appInForeground = NO;
}

-(void) appEnterForeground
{
    NSLog(@"Set state foreground");
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    appInForeground = YES;
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
[marray addObject:[[Sender alloc]initWithDict:array[i]]];
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
+ (Sender*) getSender : (NSString *) id {
Sender * s;
NSMutableArray* senders = [FCMPlugin readJSONFile:@"senders.json"];
 if([id isKindOfClass:[NSNumber class]])
 {
 NSNumber * t = (NSNumber *) id;
     id= [t stringValue] ;
 }
   for(int i=0;i<senders.count;i++)
		{
		NSString * temp;
            if([[senders[i] id] isKindOfClass:[NSNumber class] ])
             {
             NSNumber * t2 = (NSNumber *) [senders[i] id];
                  temp= [t2 stringValue];
             }
            
		if([id isEqualToString:temp])
		{
		s=(Sender *) senders[i];
		
		break;
		}
		
		}
		return s;

}
- (void)callDidConnect:(nonnull TVOCall *)call{
NSLog(@"Connected succesfully");
 NSString * notifyJS = [NSString stringWithFormat:@"%@();", callConnectedCallBack];
  NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
 if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}
- (void)call:(nonnull TVOCall *)call didFailWithError:(nonnull NSError *)error
{
NSLog(@"call failed with error %@",error);
NSString * notifyJS = [NSString stringWithFormat:@"%@();", callDisconnectedCallBack];
  NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
 if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}
- (void)callDidDisconnect:(nonnull TVOCall *)call{
NSLog(@"call disconnected");
NSLog(@"call failed with error %@",error);
NSString * notifyJS = [NSString stringWithFormat:@"%@();", callDisconnectedCallBack];
  NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
 if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}
@end
