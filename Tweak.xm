#import "iSponsorBlock.h"
#import "sponsorTimes.h"

MLNerdStatsPlaybackData *MLNerdStatsPlaybackDataInstance;
MLHAMPlayer *MLHAMPlayerInstance;

%hook MLHAMPlayer
-(id)initWithVideo:(id)arg1 playerConfig:(id)arg2 stickySettings:(id)arg3 playerView:(id)arg4 frameSourceDelegate:(id)arg5 {
	MLHAMPlayerInstance = self;
	return %orig;
}
%end

%hook MLNerdStatsPlaybackData
-(id)initWithPlayer:(id)arg1 videoID:(id)arg2 CPN:(id)arg3 {
	MLNerdStatsPlaybackDataInstance = self;
	return %orig;
}
%end 

%hook YTInlinePlayerBarView
-(void)setTotalTime:(CGFloat)arg1 {
	%orig;
	NSString *videoID = [MLNerdStatsPlaybackDataInstance videoID];
	[%c(sponsorTimes) getSponsorTimes:videoID completionTarget:self completionSelector:@selector(skipSponsor:)];
}
-(CGFloat)mediaTime {
	CGFloat orig = %orig;
	return orig;
}
%new
-(void)skipSponsor:(NSArray *)data {
	if(data != nil) {	
		int cnt = [data count];
		if(cnt == 2) {
			NSArray *firstSponsorship = data[0];
			NSArray *secondSponsorship = data[1];
			float videoTime = lroundf([self mediaTime]);

			if(videoTime == lroundf([firstSponsorship[0] floatValue])){
				dispatch_queue_t queue = dispatch_queue_create("com.galacticdev.firstSponsorQueue", NULL);
				dispatch_async(queue, ^{
					[MLHAMPlayerInstance seekToTime:[firstSponsorship[1] floatValue]];
					[NSThread sleepForTimeInterval:1.0f];
					[self skipSponsor:data];				
				});
			}
			else if(videoTime == lroundf([secondSponsorship[0] floatValue])){
				dispatch_queue_t queue = dispatch_queue_create("com.galacticdev.secondSponsorQueue", NULL);
				dispatch_async(queue, ^{
					[MLHAMPlayerInstance seekToTime:[secondSponsorship[1] floatValue]];
				});
			}
			else {
				dispatch_queue_t queue = dispatch_queue_create("com.galacticdev.skipSponsorQueue", NULL);
				dispatch_async(queue, ^{
				[NSThread sleepForTimeInterval:1.0f];
				[self skipSponsor:data];
			});
			}
		}
		if(cnt == 1){
			NSArray *firstSponsorship = data[0];
			float videoTime = lroundf([self mediaTime]);

			if(videoTime == lroundf([firstSponsorship[0] floatValue])){
				dispatch_queue_t queue = dispatch_queue_create("com.galacticdev.firstSponsorQueue", NULL);
				dispatch_async(queue, ^ {
					[MLHAMPlayerInstance seekToTime:[firstSponsorship[1] floatValue]];
				});
			}
			else{
				dispatch_queue_t queue = dispatch_queue_create("com.galacticdev.firstSponsorQueue", NULL);
				dispatch_async(queue, ^ {
					[NSThread sleepForTimeInterval:1.0f];
					[self skipSponsor:data];
				});
			}
			
		}
	}
}
%end