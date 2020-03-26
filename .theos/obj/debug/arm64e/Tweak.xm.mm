#line 1 "Tweak.xm"
#import "iSponsorBlock.h"
#import "sponsorTimes.h"

YTWatchController *YTWatchControllerInstance;
MLNerdStatsPlaybackData *MLNerdStatsPlaybackDataInstance;
BOOL didVideoChange = FALSE;


dispatch_queue_t queue;
static __attribute__((constructor)) void _logosLocalCtor_03738126(int __unused argc, char __unused **argv, char __unused **envp) {
	queue = dispatch_queue_create("com.galacticdev.skipSponsorQueue", NULL);
}


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class MLNerdStatsPlaybackData; @class YTWatchController; @class MLHAMPlayer; @class sponsorTimes; 
static YTWatchController* (*_logos_orig$_ungrouped$YTWatchController$initWithWatchFlowController$parentResponder$)(_LOGOS_SELF_TYPE_INIT YTWatchController*, SEL, id, id) _LOGOS_RETURN_RETAINED; static YTWatchController* _logos_method$_ungrouped$YTWatchController$initWithWatchFlowController$parentResponder$(_LOGOS_SELF_TYPE_INIT YTWatchController*, SEL, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$MLHAMPlayer$availableCaptionTracksDidChange$)(_LOGOS_SELF_TYPE_NORMAL MLHAMPlayer* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$MLHAMPlayer$availableCaptionTracksDidChange$(_LOGOS_SELF_TYPE_NORMAL MLHAMPlayer* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$MLHAMPlayer$skipFirstSponsor$(_LOGOS_SELF_TYPE_NORMAL MLHAMPlayer* _LOGOS_SELF_CONST, SEL, NSArray *); static void _logos_method$_ungrouped$MLHAMPlayer$skipSecondSponsor$(_LOGOS_SELF_TYPE_NORMAL MLHAMPlayer* _LOGOS_SELF_CONST, SEL, NSArray *); static MLNerdStatsPlaybackData* (*_logos_orig$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$)(_LOGOS_SELF_TYPE_INIT MLNerdStatsPlaybackData*, SEL, id, id, id) _LOGOS_RETURN_RETAINED; static MLNerdStatsPlaybackData* _logos_method$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$(_LOGOS_SELF_TYPE_INIT MLNerdStatsPlaybackData*, SEL, id, id, id) _LOGOS_RETURN_RETAINED; 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$sponsorTimes(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("sponsorTimes"); } return _klass; }
#line 14 "Tweak.xm"

static YTWatchController* _logos_method$_ungrouped$YTWatchController$initWithWatchFlowController$parentResponder$(_LOGOS_SELF_TYPE_INIT YTWatchController* __unused self, SEL __unused _cmd, id arg1, id arg2) _LOGOS_RETURN_RETAINED {
	YTWatchControllerInstance = self;
	return _logos_orig$_ungrouped$YTWatchController$initWithWatchFlowController$parentResponder$(self, _cmd, arg1, arg2);
}





static void _logos_method$_ungrouped$MLHAMPlayer$availableCaptionTracksDidChange$(_LOGOS_SELF_TYPE_NORMAL MLHAMPlayer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
	_logos_orig$_ungrouped$MLHAMPlayer$availableCaptionTracksDidChange$(self, _cmd, arg1);
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		didVideoChange = TRUE;
		[NSThread sleepForTimeInterval:0.5f]; 
		NSString *videoID = [MLNerdStatsPlaybackDataInstance videoID];
		[_logos_static_class_lookup$sponsorTimes() getSponsorTimes:videoID completionTarget:self completionSelector:@selector(skipFirstSponsor:)];
	});
	
}

static void _logos_method$_ungrouped$MLHAMPlayer$skipFirstSponsor$(_LOGOS_SELF_TYPE_NORMAL MLHAMPlayer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSArray * data) {
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
 
static void _logos_method$_ungrouped$MLHAMPlayer$skipSecondSponsor$(_LOGOS_SELF_TYPE_NORMAL MLHAMPlayer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSArray * data) {
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



static MLNerdStatsPlaybackData* _logos_method$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$(_LOGOS_SELF_TYPE_INIT MLNerdStatsPlaybackData* __unused self, SEL __unused _cmd, id arg1, id arg2, id arg3) _LOGOS_RETURN_RETAINED {
	MLNerdStatsPlaybackDataInstance = self;
	return _logos_orig$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$(self, _cmd, arg1, arg2, arg3);
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$YTWatchController = objc_getClass("YTWatchController"); MSHookMessageEx(_logos_class$_ungrouped$YTWatchController, @selector(initWithWatchFlowController:parentResponder:), (IMP)&_logos_method$_ungrouped$YTWatchController$initWithWatchFlowController$parentResponder$, (IMP*)&_logos_orig$_ungrouped$YTWatchController$initWithWatchFlowController$parentResponder$);Class _logos_class$_ungrouped$MLHAMPlayer = objc_getClass("MLHAMPlayer"); MSHookMessageEx(_logos_class$_ungrouped$MLHAMPlayer, @selector(availableCaptionTracksDidChange:), (IMP)&_logos_method$_ungrouped$MLHAMPlayer$availableCaptionTracksDidChange$, (IMP*)&_logos_orig$_ungrouped$MLHAMPlayer$availableCaptionTracksDidChange$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$MLHAMPlayer, @selector(skipFirstSponsor:), (IMP)&_logos_method$_ungrouped$MLHAMPlayer$skipFirstSponsor$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$MLHAMPlayer, @selector(skipSecondSponsor:), (IMP)&_logos_method$_ungrouped$MLHAMPlayer$skipSecondSponsor$, _typeEncoding); }Class _logos_class$_ungrouped$MLNerdStatsPlaybackData = objc_getClass("MLNerdStatsPlaybackData"); MSHookMessageEx(_logos_class$_ungrouped$MLNerdStatsPlaybackData, @selector(initWithPlayer:videoID:CPN:), (IMP)&_logos_method$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$, (IMP*)&_logos_orig$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$);} }
#line 105 "Tweak.xm"
