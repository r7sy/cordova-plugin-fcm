#import <Foundation/Foundation.h>

@interface Sender:NSObject

@property(nonatomic, readwrite) NSNumber * id;
@property(nonatomic, readwrite) NSString * sound;
@property(nonatomic, readwrite) NSNumber * muted;
@property(nonatomic, readwrite) NSNumber * vibrate;

-(NSDictionary *) getDict;
-(id) initWithDict :(NSDictionary *) dict ;
@end
