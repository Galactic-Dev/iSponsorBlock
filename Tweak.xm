#import "iSponsorBlock.h"
#import "sponsorTimes.h"

YTWatchController *YTWatchControllerInstance;
MLNerdStatsPlaybackData *MLNerdStatsPlaybackDataInstance;
BOOL didVideoChange = FALSE;

//create dispatch queue to perform asynchronous tasks in.
dispatch_queue_t queue;
%ctor {
	queue = dispatch_queue_create("com.galacticdev.skipSponsorQueue", NULL);
}

%hook YTWatchController
-(id)initWithWatchFlowController:(id)arg1 parentResponder:(id)arg2 {
	YTWatchControllerInstance = self;
	return %orig;
}
%end

%hook MLHAMPlayer

//This method is called every time the video changes, so that is why I chose it. 
-(void)availableCaptionTracksDidChange:(id)arg1 {
	%orig;
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		didVideoChange = TRUE;
		[NSThread sleepForTimeInterval:0.5f]; 
		NSString *videoID = [MLNerdStatsPlaybackDataInstance videoID];
		[%c(sponsorTimes) getSponsorTimes:videoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
	});
	
}
%new
-(void)skipFirstSponsor:(NSArray *)data {
	didVideoChange = FALSE;
	if(data != nil) {	
		int cnt = [data count];
		if(cnt == 2) {
			NSArray *firstSponsorship = data[0];
			float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

			if(videoTime == lroundf([firstSponsorship[0] floatValue])){
				dispatch_async(queue, ^{
					[self seekToTime:[firstSponsorship[1] floatValue]];
					[NSThread sleepForTimeInterval:0.5f];
					[self skipSecondSponsor:data];	
				});
			}
			else if (videoTime < lroundf([firstSponsorship[0] floatValue])){
				dispatch_async(queue, ^ {
					[NSThread sleepForTimeInterval:0.5f];
					[self skipFirstSponsor:data];
				});
			}

		}
		if(cnt == 1){
			NSArray *firstSponsorship = data[0];
			float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

			if(videoTime == lroundf([firstSponsorship[0] floatValue])){
				dispatch_async(queue, ^ {
					[self seekToTime:[firstSponsorship[1] floatValue]];
				});
			}
			else if (videoTime < lroundf([firstSponsorship[0] floatValue])){
				dispatch_async(queue, ^ {
					[NSThread sleepForTimeInterval:0.5f];
					[self skipFirstSponsor:data];
				});
			}
			
		}
	}
}
%new 
-(void)skipSecondSponsor:(NSArray *)data {
	if(didVideoChange == FALSE) {
		NSArray *secondSponsorship = data[1];
		float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

		if(videoTime == lroundf([secondSponsorship[0] floatValue])){
					dispatch_async(queue, ^{
						[self seekToTime:[secondSponsorship[1] floatValue]];
					});
				}
		else if (videoTime < lroundf([secondSponsorship[0] floatValue])){
				dispatch_async(queue, ^{
					[NSThread sleepForTimeInterval:0.5f];
					[self skipSecondSponsor:data];
				});
				}
		}
}
%end

%hook MLNerdStatsPlaybackData
-(id)initWithPlayer:(id)arg1 videoID:(id)arg2 CPN:(id)arg3 {
	MLNerdStatsPlaybackDataInstance = self;
	return %orig;
}
%end

