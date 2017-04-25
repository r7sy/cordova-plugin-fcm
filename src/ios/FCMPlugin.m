#include <sys/types.h>
#include <sys/sysctl.h>

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
	
    [self.commandDelegate runInBackground:^{
	 NSDictionary *dict = @{@"id": @"1",@"title":@"some title",@"body":@"some body",@"senderId":@"1"
 ,@"thumbnail_url":@"logo.png",@"thumbnail_hash":@"aawdawdaw",@"senderName":@"rdwan"};
 NSDictionary *dict2 = @{@"id": @"2",@"title":@"some title",@"body":@"some other body",@"senderId":@"2"
 ,@"thumbnail_url":@"logo.png",@"thumbnail_hash":@"aawdawdaw",@"senderName":@"rdwan"};
    NSLog(@"get Token");
	Message* m = [[Message alloc] initWithDict:dict withDate:nil];
	Message* m1 = [[Message alloc] initWithDict:dict2 withDate:nil];
	NSMutableArray* arr=[[NSMutableArray alloc] init];
	[arr addObject:m];
	[arr addObject:m1];
	
	[AppDelegate writeFile:@"test.txt":@"hello my test":YES];
	[AppDelegate writeFile:@"test.txt":@"hello my test":YES];
	[AppDelegate writeFile:@"test.txt":@"hello my test":YES];
	NSLog(@"test.txt %@",[AppDelegate readFile:@"test.txt"]	);
	[AppDelegate writeJSONFile:@"test.json":arr];
	NSLog(@"test.txt %@",[AppDelegate readFile:@"test.json"]);
	NSMutableArray* newar=[AppDelegate readJSONFile:@"test.json"];
	for(int i=0;i<[newar count];i++)
	{
	NSLog(@"%@",[newar[i] body]);
	
	}
        NSString* token = [AppDelegate getLastToken];
		token =@"hello";
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
[marray addObject:[[Message alloc]initWithDict:array[i]]];
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
@end
