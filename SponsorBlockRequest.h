#import <UIKit/UIKit.h>
#import "iSponsorBlock.h"
@interface SponsorBlockRequest : NSObject
+(void)getSponsorTimes:(NSString *)videoID completionTarget:(id)target completionSelector:(SEL)sel;
+(void)postSponsorTimes:(NSString *)videoID sponsorSegments:(NSArray <SponsorSegment *> *)segments userID:(NSString *)userID withViewController:(UIViewController *)viewController;
+(void)normalVoteForSegment:(SponsorSegment *)segment userID:(NSString *)userID type:(BOOL)type;
+(void)categoryVoteForSegment:(SponsorSegment *)segment userID:(NSString *)userID category:(NSString *)category;
+(void)viewedVideoSponsorTime:(SponsorSegment *)segment;
@end
