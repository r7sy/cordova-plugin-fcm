#include <sys/types.h>
#include <sys/sysctl.h>

#import "AppDelegate+FCMPlugin.h"
#import "Message.h"
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

// GET TOKEN //
- (void) getToken:(CDVInvokedUrlCommand *)command 
{
	 NSDictionary *dict = @{@"id": @"1",@"title":@"some title",@"body":@"some body",@"senderId":@"1"
 ,@"thumbnail_url":@"logo.png",@"thumbnail_hash":@"aawdawdaw",@"senderName":@"rdwan"};
    NSLog(@"get Token");
	Message* m = [[Message alloc] initWithDict:dict withDate:nil];
	NSLog(@"got message dict %s",[m getDict]);
	if ([NSJSONSerialization isValidJSONObject:[m getDict]])
{
  // Serialize the dictionary
 NSError *error;
  NSData *json = [NSJSONSerialization dataWithJSONObject:[m getDict] options:NSJSONWritingPrettyPrinted error:&error];
  NSLog(@"serilized dict");
  // If no errors, let's view the JSON
  if (json != nil && error == nil)
  {
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/NoCloud/messages.json"];

    NSLog(@"JSON: %@", jsonString);
	[jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
         
  }
}
    [self.commandDelegate runInBackground:^{
        NSString* token = [AppDelegate getLastToken];
		token =@"hello";
		NSLog(@"got last token %@", token);
NSError *error;		
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/NoCloud/messages.json"];
//[token writeToFile:path atomically:YES];
token = [NSString stringWithFormat: @"%@\n", token];
NSFileManager *fileManager = [NSFileManager defaultManager];
/*if(![fileManager fileExistsAtPath:path])
{  NSLog(@"file doesn't exist");

  [token writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}
else
{NSLog(@"file doesn't exists");
  NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:path];
  [myHandle seekToEndOfFile];
 [myHandle writeData:[token dataUsingEncoding:NSUTF8StringEncoding]];
}*/

NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
NSLog(@"file content %@",content);
/*content=[content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSArray *array = [content componentsSeparatedByString:@"\n"];
  //NSLog(@"file array last object %@",[array lastObject]);
  int i;
 for (i = 0; i < [array count]; i++) {
   NSString* arrayElem = [array objectAtIndex:i];
  NSLog(@"file array %d object %@",i,arrayElem);
 }*/
 NSData * jsonData = [NSData dataWithContentsOfFile:path];
 id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
  if ([object isKindOfClass:[NSDictionary class]] && error == nil)
{
  NSLog(@"dictionary: %@", object);
  Message* m2 = [[Message alloc] initWithDict:object withDate:[[NSDate alloc] initWithTimeIntervalSince1970:object[@"arrivalTime"]]];
	NSLog(@"message: %@", [m2 body]);
  
  
  }
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

@end
