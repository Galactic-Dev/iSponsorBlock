#import "iSponsorBlock.h"
#import "sponsorTimes.h"

YTDoubleTapToSeekController *YTDoubleTapToSeekControllerInstance;
MLHAMPlayer *MLHAMPlayerInstance;
YTWatchController *YTWatchControllerInstance;
MLNerdStatsPlaybackData *MLNerdStatsPlaybackDataInstance;

int secondVersionPart;
NSString *currentVideoID = nil;

dispatch_queue_t queue;

%group greaterthan08

%hook YTDoubleTapToSeekController
-(id)initWithDelegate:(id)arg1 parentResponder:(id)arg2 {
	YTDoubleTapToSeekControllerInstance = self;
	return %orig;
}
%end

%hook YTMainWindow
-(id)initWithFrame:(CGRect)arg1 {
	dispatch_async(queue, ^ {
		[NSThread sleepForTimeInterval:1.0f];
		currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
		[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
	});
	return %orig;
}

%new
-(void)skipFirstSponsor:(NSDictionary *)data {
	currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
	if([data objectForKey:@"sponsorTimes"] != nil) {
		NSString *videoID = [data objectForKey:@"videoID"];
		if(currentVideoID == videoID) {
			int cnt = [[data objectForKey:@"sponsorTimes"]count];
			if(cnt > 1) {
				NSArray *firstSponsorship = [data objectForKey:@"sponsorTimes"][0];
				NSArray *secondSponsorship = [data objectForKey:@"sponsorTimes"][1];
				float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

				if(videoTime == ceil([firstSponsorship[0] floatValue])){
					CGFloat timeToSkip = [firstSponsorship[1] floatValue] - [firstSponsorship[0] floatValue];
					[YTDoubleTapToSeekControllerInstance attemptSeekByInterval:timeToSkip];
					//fixes issue with player bar not going away after sponsorship is skipped
					[YTDoubleTapToSeekControllerInstance endDoubleTapToSeek];

					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						[self skipSecondSponsor:data];
					});
				}

				else if (videoTime < ceil([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						[self skipFirstSponsor:data];
					});
				}
				else if (videoTime > ceil([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^{
						[NSThread sleepForTimeInterval:0.5f];
						currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
						[self skipSecondSponsor:data];
					});
				}
				else if (videoTime > ceil([secondSponsorship[0] floatValue])) {
					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
						[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
					});
				}
			}

			if(cnt == 1) {
				NSArray *firstSponsorship = [data objectForKey:@"sponsorTimes"][0];
				float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

				if(videoTime == ceil([firstSponsorship[0] floatValue])){
					CGFloat timeToSkip = [firstSponsorship[1] floatValue] - [firstSponsorship[0] floatValue];
					[YTDoubleTapToSeekControllerInstance attemptSeekByInterval:timeToSkip];
					[YTDoubleTapToSeekControllerInstance endDoubleTapToSeek];
					dispatch_async(queue, ^ {
							[self skipFirstSponsor:nil];
					});
				}

				else if (videoTime < ceil([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						[self skipFirstSponsor:data];
					});
				}

				else if(videoTime > ceil([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
						[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
					});
				}

			}
		}

		else {
			dispatch_async(queue, ^ {
				[NSThread sleepForTimeInterval:0.5f];
				currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
				[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
			});
		}

	}

	else {
		dispatch_async(queue, ^{
			currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
			[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
		});
	}

}

%new
-(void)skipSecondSponsor:(NSDictionary *)data {
	if([data objectForKey:@"sponsorTimes"] != nil) {
		NSString *videoID = [data objectForKey:@"videoID"];
		if(currentVideoID == videoID) {
			NSArray *secondSponsorship = [data objectForKey:@"sponsorTimes"][1];
			float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

			if(videoTime == ceil([secondSponsorship[0] floatValue])){

				CGFloat timeToSkip = [secondSponsorship[1] floatValue] - [secondSponsorship[0] floatValue];
				[YTDoubleTapToSeekControllerInstance attemptSeekByInterval:timeToSkip];
				[YTDoubleTapToSeekControllerInstance endDoubleTapToSeek];
				dispatch_async(queue, ^{
					[self skipFirstSponsor:nil];
				});
			}
			else if(videoTime < ceil([secondSponsorship[0] floatValue])){
				dispatch_async(queue, ^{
					[NSThread sleepForTimeInterval:0.5f];
					[self skipSecondSponsor:data];
				});
			}
			else if(videoTime > ceil([secondSponsorship[0] floatValue])) {
				dispatch_async(queue, ^{
					[NSThread sleepForTimeInterval:0.5f];
					[self skipFirstSponsor:nil];
				});
			}
		}
		else {
			dispatch_async(queue, ^ {
				currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
				[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
			});
		}
	}
}
%end

%hook YTWatchController
-(id)initWithWatchFlowController:(id)arg1 parentResponder:(id)arg2 {
	YTWatchControllerInstance = self;
	return %orig;
}
%end

%hook MLNerdStatsPlaybackData
-(id)initWithPlayer:(id)arg1 videoID:(id)arg2 CPN:(id)arg3 {
	MLNerdStatsPlaybackDataInstance = self;
	return %orig;
}

%end
%end


%group lowerthan06;
%hook MLHAMPlayer
-(id)initWithVideo:(id)arg1 playerConfig:(id)arg2 stickySettings:(id)arg3 playerView:(id)arg4 frameSourceDelegate:(id)arg5 {
	MLHAMPlayerInstance = self;
	return %orig;
}
%end

%hook YTMainWindow
-(id)initWithFrame:(CGRect)arg1 {
	dispatch_async(queue, ^ {
		[NSThread sleepForTimeInterval:1.0f];
		currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
		[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
	});
	return %orig;
}

%new
-(void)skipFirstSponsor:(NSDictionary *)data {
	currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
	if([data objectForKey:@"sponsorTimes"] != nil) {
		NSString *videoID = [data objectForKey:@"videoID"];
		if(currentVideoID == videoID) {
			int cnt = [[data objectForKey:@"sponsorTimes"]count];
			if(cnt > 1) {
				NSArray *firstSponsorship = [data objectForKey:@"sponsorTimes"][0];
				float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

				if(videoTime == lroundf([firstSponsorship[0] floatValue])){
					dispatch_async(queue, ^ {
						[MLHAMPlayerInstance seekToTime:[firstSponsorship[1] floatValue]];
						[NSThread sleepForTimeInterval:0.5f];
						[self skipSecondSponsor:data];
					});
				}

				else if (videoTime < lroundf([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						[self skipFirstSponsor:data];
					});
				}
				else if (videoTime > lroundf([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^{
						[NSThread sleepForTimeInterval:0.5f];
						currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
						[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
					});
				}
			}

			if(cnt == 1) {
				NSArray *firstSponsorship = [data objectForKey:@"sponsorTimes"][0];
				float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

				if(videoTime == lroundf([firstSponsorship[0] floatValue])){
					dispatch_async(queue, ^ {
						[MLHAMPlayerInstance seekToTime:[firstSponsorship[1] floatValue]];
						[self skipFirstSponsor:nil];
					});
				}

				else if (videoTime < lroundf([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						[self skipFirstSponsor:data];
					});
				}

				else if(videoTime > lroundf([firstSponsorship[0] floatValue])) {
					dispatch_async(queue, ^ {
						[NSThread sleepForTimeInterval:0.5f];
						currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
						[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
					});
				}

			}
		}

		else {
			dispatch_async(queue, ^ {
				[NSThread sleepForTimeInterval:0.5f];
				currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
				[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
			});
		}

	}

	else {
		dispatch_async(queue, ^{
			currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
			[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
		});
	}

}

%new
-(void)skipSecondSponsor:(NSDictionary *)data {
	if([data objectForKey:@"sponsorTimes"] != nil) {
		NSString *videoID = [data objectForKey:@"videoID"];
		if(currentVideoID == videoID) {
			NSArray *secondSponsorship = [data objectForKey:@"sponsorTimes"][1];
			float videoTime = lroundf([YTWatchControllerInstance activeVideoMediaTime]);

			if(videoTime == lroundf([secondSponsorship[0] floatValue])){
				dispatch_async(queue, ^{
					[MLHAMPlayerInstance seekToTime:[secondSponsorship[1] floatValue]];
					[self skipFirstSponsor:nil];
				});
			}
			else if(videoTime < lroundf([secondSponsorship[0] floatValue])){
				dispatch_async(queue, ^{
					[NSThread sleepForTimeInterval:0.5f];
					[self skipSecondSponsor:data];
				});
			}
		}
		else {
			dispatch_async(queue, ^ {
				currentVideoID = [MLNerdStatsPlaybackDataInstance videoID];
				[%c(sponsorTimes) getSponsorTimes:currentVideoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
			});
		}
	}
}
%end

%hook YTWatchController
-(id)initWithWatchFlowController:(id)arg1 parentResponder:(id)arg2 {
	YTWatchControllerInstance = self;
	return %orig;
}
%end

%hook MLNerdStatsPlaybackData
-(id)initWithPlayer:(id)arg1 videoID:(id)arg2 CPN:(id)arg3 {
	MLNerdStatsPlaybackDataInstance = self;
	return %orig;
}
%end
%end

%ctor {
	queue = dispatch_queue_create("com.galacticdev.skipSponsorQueue", NULL);

	NSArray *version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] componentsSeparatedByString:@"."];
	secondVersionPart = [version[1] intValue];

	if(secondVersionPart <= 8){
		%init(lowerthan06);
	} else {
		%init(greaterthan08);
	}

}
