#import "Sender.h"
@implementation Sender


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
self.sound=dict[@"sound"];
self.muted=dict[@"muted"];
self.vibrate=dict[@"vibrate"];

}
return self;
}
-(NSDictionary *) getDict
{
 NSDictionary *dict = @{@"id": self.id,@"sound":self.sound,@"muted":self.muted,@"vibrate":self.vibrate};
   return dict;
}

@end
