#import "sponsorTimes.h"

@implementation sponsorTimes

+ (void)getSponsorTimes:(NSString *)videoID completionTarget:(id)target completionSelector:(SEL)sel {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];

    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.sponsor.ajay.app/api/getVideoSponsorTimes?videoID=%@", videoID]]];

    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"data = %@", data);
        if (data != nil && error == nil){
            id jsonData = [[NSJSONSerialization JSONObjectWithData:data options:0 error:&error] objectForKey:@"sponsorTimes"];
            if(jsonData != nil) {
                NSDictionary *result = @{
                @"sponsorTimes" : jsonData, 
                @"videoID" : videoID
            };
            [target performSelectorOnMainThread:sel withObject:result waitUntilDone:NO];
            }

            else {
                [target performSelectorOnMainThread:sel withObject:nil waitUntilDone:NO]; 
            }
            

            
        }
      
           

        
       

    }];
}

@end
