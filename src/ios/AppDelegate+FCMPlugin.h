//
//  AppDelegate+FCMPlugin.h
//  TestApp
//
//  Created by felipe on 12/06/16.
//
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>

@interface AppDelegate (FCMPlugin)

+ (NSData*)getLastPush;
+ (NSString*)getLastToken;
+ (void)writeFile:(NSString*)name : (NSString*)data : (BOOL) append;
+ (NSString *)readFile:(NSString*)name ;
+ (NSMutableArray *)readJSONFile:(NSString*)name ;
+ (void)writeJSONFile:(NSString*)name : (NSMutableArray *)data ;
+ (NSString*)postData: (NSString*) url : (NSMutableArray*) keys : (NSMutableArray*) values; 
+ (void) deleteData;
+(void) showNotification:(NSDictionary *) dict ;
@end
