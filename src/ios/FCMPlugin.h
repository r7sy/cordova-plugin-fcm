#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface FCMPlugin : CDVPlugin
{
    //NSString *notificationCallBack;
}

+ (FCMPlugin *) fcmPlugin;
- (void)ready:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)subscribeToTopic:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand*)command;
- (void)registerNotification:(CDVInvokedUrlCommand*)command;
- (void)notifyOfMessage:(NSData*) payload;
- (void)notifyOfTokenRefresh:(NSString*) token;
- (void)appEnterBackground;
- (void)appEnterForeground;
- (void) mute : (CDVInvokedUrlCommand*) command;
- (void) unmute : (CDVInvokedUrlCommand*) command;

- (void) vibrateon : (CDVInvokedUrlCommand*) command;
- (void) vibrateoff : (CDVInvokedUrlCommand*) command;
+ (NSMutableArray *)readJSONFile:(NSString*)name ;
+ (void)writeJSONFile:(NSString*)name : (NSMutableArray *)data ;
@end
