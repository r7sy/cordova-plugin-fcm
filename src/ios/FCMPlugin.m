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
	NSError* error;
	  NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",@"username",@"password"];
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]]; 
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
  [request setURL:[NSURL URLWithString:@"http://www.ultranotify.com/app/api.php?mobileNumber=0991530597&access_token=1564&confirmRecieve&id=1"]]; 
  [request setHTTPMethod:@"POST"]; 
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"]; 
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];
  //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
 NSURLResponse *response = nil;
NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
if(!error &&responseData)
{
NSLog(@"response %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding])
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


@end
