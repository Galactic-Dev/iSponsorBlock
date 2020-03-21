#line 1 "Tweak.xm"
#import "iSponsorBlock.h"
#import "sponsorTimes.h"

MLNerdStatsPlaybackData *MLNerdStatsPlaybackDataInstance;
MLHAMPlayer *MLHAMPlayerInstance;


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

@class MLHAMPlayer; @class sponsorTimes; @class MLNerdStatsPlaybackData; @class YTInlinePlayerBarView; 
static MLHAMPlayer* (*_logos_orig$_ungrouped$MLHAMPlayer$initWithVideo$playerConfig$stickySettings$playerView$frameSourceDelegate$)(_LOGOS_SELF_TYPE_INIT MLHAMPlayer*, SEL, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static MLHAMPlayer* _logos_method$_ungrouped$MLHAMPlayer$initWithVideo$playerConfig$stickySettings$playerView$frameSourceDelegate$(_LOGOS_SELF_TYPE_INIT MLHAMPlayer*, SEL, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static MLNerdStatsPlaybackData* (*_logos_orig$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$)(_LOGOS_SELF_TYPE_INIT MLNerdStatsPlaybackData*, SEL, id, id, id) _LOGOS_RETURN_RETAINED; static MLNerdStatsPlaybackData* _logos_method$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$(_LOGOS_SELF_TYPE_INIT MLNerdStatsPlaybackData*, SEL, id, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$YTInlinePlayerBarView$setTotalTime$)(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST, SEL, CGFloat); static void _logos_method$_ungrouped$YTInlinePlayerBarView$setTotalTime$(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST, SEL, CGFloat); static CGFloat (*_logos_orig$_ungrouped$YTInlinePlayerBarView$mediaTime)(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST, SEL); static CGFloat _logos_method$_ungrouped$YTInlinePlayerBarView$mediaTime(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$YTInlinePlayerBarView$skipSponsor$(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST, SEL, NSArray *); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$sponsorTimes(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("sponsorTimes"); } return _klass; }
#line 7 "Tweak.xm"

static MLHAMPlayer* _logos_method$_ungrouped$MLHAMPlayer$initWithVideo$playerConfig$stickySettings$playerView$frameSourceDelegate$(_LOGOS_SELF_TYPE_INIT MLHAMPlayer* __unused self, SEL __unused _cmd, id arg1, id arg2, id arg3, id arg4, id arg5) _LOGOS_RETURN_RETAINED {
	MLHAMPlayerInstance = self;
	return _logos_orig$_ungrouped$MLHAMPlayer$initWithVideo$playerConfig$stickySettings$playerView$frameSourceDelegate$(self, _cmd, arg1, arg2, arg3, arg4, arg5);
}



static MLNerdStatsPlaybackData* _logos_method$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$(_LOGOS_SELF_TYPE_INIT MLNerdStatsPlaybackData* __unused self, SEL __unused _cmd, id arg1, id arg2, id arg3) _LOGOS_RETURN_RETAINED {
	MLNerdStatsPlaybackDataInstance = self;
	return _logos_orig$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$(self, _cmd, arg1, arg2, arg3);
}
 


static void _logos_method$_ungrouped$YTInlinePlayerBarView$setTotalTime$(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGFloat arg1) {
	_logos_orig$_ungrouped$YTInlinePlayerBarView$setTotalTime$(self, _cmd, arg1);
	NSString *videoID = [MLNerdStatsPlaybackDataInstance videoID];
	[_logos_static_class_lookup$sponsorTimes() getSponsorTimes:videoID completionTarget:self completionSelector:@selector(skipSponsor:)];
}
static CGFloat _logos_method$_ungrouped$YTInlinePlayerBarView$mediaTime(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	CGFloat orig = _logos_orig$_ungrouped$YTInlinePlayerBarView$mediaTime(self, _cmd);
	return orig;
}

static void _logos_method$_ungrouped$YTInlinePlayerBarView$skipSponsor$(_LOGOS_SELF_TYPE_NORMAL YTInlinePlayerBarView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSArray * data) {
	if(data != nil) {	
		int cnt = [data count];
		if(cnt == 2) {
			NSArray *firstSponsorship = data[0];
			NSArray *secondSponsorship = data[1];
			float videoTime = lroundf([self mediaTime]);

			if(videoTime == lroundf([firstSponsorship[0] floatValue])){
				dispatch_queue_t queue = dispatch_queue_create("com.galacticdev.firstSponsorQueue", NULL);
				dispatch_async(queue, ^{
					[MLHAMPlayerInstance seekToTime:lroundf([firstSponsorship[1] floatValue])];
					[NSThread sleepForTimeInterval:1.0f];
					[self skipSponsor:data];				
				});
			}
			else if(videoTime == lroundf([secondSponsorship[0] floatValue])){
				dispatch_queue_t queue = dispatch_queue_create("com.galacticdev.secondSponsorQueue", NULL);
				dispatch_async(queue, ^{
					[MLHAMPlayerInstance seekToTime:lroundf([secondSponsorship[1] floatValue])];
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

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$MLHAMPlayer = objc_getClass("MLHAMPlayer"); MSHookMessageEx(_logos_class$_ungrouped$MLHAMPlayer, @selector(initWithVideo:playerConfig:stickySettings:playerView:frameSourceDelegate:), (IMP)&_logos_method$_ungrouped$MLHAMPlayer$initWithVideo$playerConfig$stickySettings$playerView$frameSourceDelegate$, (IMP*)&_logos_orig$_ungrouped$MLHAMPlayer$initWithVideo$playerConfig$stickySettings$playerView$frameSourceDelegate$);Class _logos_class$_ungrouped$MLNerdStatsPlaybackData = objc_getClass("MLNerdStatsPlaybackData"); MSHookMessageEx(_logos_class$_ungrouped$MLNerdStatsPlaybackData, @selector(initWithPlayer:videoID:CPN:), (IMP)&_logos_method$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$, (IMP*)&_logos_orig$_ungrouped$MLNerdStatsPlaybackData$initWithPlayer$videoID$CPN$);Class _logos_class$_ungrouped$YTInlinePlayerBarView = objc_getClass("YTInlinePlayerBarView"); MSHookMessageEx(_logos_class$_ungrouped$YTInlinePlayerBarView, @selector(setTotalTime:), (IMP)&_logos_method$_ungrouped$YTInlinePlayerBarView$setTotalTime$, (IMP*)&_logos_orig$_ungrouped$YTInlinePlayerBarView$setTotalTime$);MSHookMessageEx(_logos_class$_ungrouped$YTInlinePlayerBarView, @selector(mediaTime), (IMP)&_logos_method$_ungrouped$YTInlinePlayerBarView$mediaTime, (IMP*)&_logos_orig$_ungrouped$YTInlinePlayerBarView$mediaTime);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$YTInlinePlayerBarView, @selector(skipSponsor:), (IMP)&_logos_method$_ungrouped$YTInlinePlayerBarView$skipSponsor$, _typeEncoding); }} }
#line 84 "Tweak.xm"
