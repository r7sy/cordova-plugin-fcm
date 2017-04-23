#import "Message.h"
@implementation Message


-(id)init
{
   self = [super init];
   
}

-(id) initWithDict :(NSDictionary *) dict
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


}
return self;
}
-(NSDictionary *) getDict
{
 NSDictionary *dict = @{@"id": self.id,@"title":self.title,@"body":self.body,@"senderId":self.senderId
 ,@"thumbnail_url":self.thumbnail_url,@"thumbnail_hash":self.thumbnail_hash,@"senderName":self.senderName};
   return dict;
}

@end
