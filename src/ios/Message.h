#import <Foundation/Foundation.h>

@interface Message:NSObject

@property(nonatomic, readwrite) NSString * id;
@property(nonatomic, readwrite) NSString * title;
@property(nonatomic, readwrite) NSString * body;
@property(nonatomic, readwrite) NSString * senderId;
@property(nonatomic, readwrite) NSString * thumbnail_url;
@property(nonatomic, readwrite) NSString * thumbnail_hash;
@property(nonatomic, readwrite) NSString * senderName;
@property(nonatomic, readwrite) NSNumber * muted;
-(NSDictionary *) getDict;
-(id) initWithDict :(NSDictionary *) dict ;
@end
