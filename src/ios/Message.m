#import "Message.h"
@implementation Message


-(id)init
{
   self = [super init];
   
}

-(id) initWithDict :(NSDictionary *) dict withDate:(NSDate *)date
{
self=[super init];
if(self)
{
self.id=dict[@"id"];
self.title=dict[@"title"];
self.body=dict[@"body"];
self.senderId=dict[@"senderId"];
self.thumbnail_url=dict[@"thumbnail_url"];
self.thumbnail_hash=dict[@"thumbnail_hash"];
self.senderName=dict[@"senderName"];
self.arrivalTime = date;
if(self.arrivalTime)
{
self.arrivalTime=[[NSDate alloc] init];
}

}
return self;
}
-(NSDictionary *) getDict
{
 NSDictionary *dict = @{@"id": self.id,@"title":self.title,@"body":self.body,@"senderId":self.senderId
 ,@"thumbnail_url":self.thumbnail_url,@"thumbnail_hash":self.thumbnail_hash,@"senderName":self.senderName,@"arrivalTime":[[NSNumber alloc] initWithDouble:[self.arrivalTime timeIntervalSince1970]]};
   return dict;
}

@end
