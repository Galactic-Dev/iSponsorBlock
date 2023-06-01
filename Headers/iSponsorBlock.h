#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <dlfcn.h>
#import "YouTubeHeader/YTInlinePlayerBarView.h"
#import "YouTubeHeader/YTMainAppControlsOverlayView.h"
#import "YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "YouTubeHeader/YTRightNavigationButtons.h"
#import "YouTubeHeader/YTPageStyleController.h"
#import "YouTubeHeader/YTPlayerView.h"
#import "YouTubeHeader/YTPlayerViewController.h"
#import "YouTubeHeader/YTPlayerBarSegmentMarkerView.h"
#import "YouTubeHeader/YTPlayerBarSegmentedProgressView.h"
#import "YouTubeHeader/YTSegmentableInlinePlayerBarView.h"
#import "YouTubeHeader/YTSingleVideoTime.h"
#import "YouTubeHeader/YTNGWatchLayerViewController.h"
#import "YouTubeHeader/YTWatchLayerViewController.h"
#import "YouTubeHeader/YTIChapterRenderer.h"
#import "MBProgressHUD.h"
#import "SponsorSegment.h"
#include <math.h>

// prefs
BOOL kIsEnabled;
NSString *kUserID;
NSString *kAPIInstance;
NSDictionary *kCategorySettings;
CGFloat kMinimumDuration;
BOOL kShowSkipNotice;
BOOL kShowButtonsInPlayer;
BOOL kHideStartEndButtonInPlayer;
BOOL kShowModifiedTime;
BOOL kSkipAudioNotification;
BOOL kEnableSkipCountTracking;
CGFloat kSkipNoticeDuration;
NSMutableArray <NSString *> *kWhitelistedChannels;

@interface YTPlayerViewController (iSB)
@property (strong, nonatomic) NSMutableArray <SponsorSegment *> *skipSegments;
@property (nonatomic, assign) NSInteger currentSponsorSegment;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, assign) NSInteger unskippedSegment;
@property (strong, nonatomic) NSMutableArray <SponsorSegment *> *userSkipSegments;
@property (nonatomic, assign) BOOL hudDisplayed;
- (void)isb_scrubToTime:(CGFloat)time;
- (void)isb_fixVisualGlitch;
@end

@interface YTMainAppControlsOverlayView (iSB)
- (void)sponsorBlockButtonPressed:(YTQTMButton *)sender;
- (void)sponsorStartedButtonPressed:(YTQTMButton *)sender;
- (void)sponsorEndedButtonPressed:(YTQTMButton *)sender;
- (void)presentSponsorBlockViewController;
@property (retain, nonatomic) YTQTMButton *sponsorBlockButton;
@property (retain, nonatomic) YTQTMButton *sponsorStartedEndedButton;
@property (nonatomic, assign) BOOL isDisplayingSponsorBlockViewController;
@end

// Old class
@interface YTIChapterRendererWrapper : NSObject
- (instancetype)initWithStartTime:(CGFloat)arg1 endTime:(CGFloat)arg2 title:(NSString *)arg3;
+ (instancetype)chapterRendererWrapperWithRenderer:(YTIChapterRenderer *)arg1;
@property (nonatomic, assign) CGFloat endTime;
@end

@interface YTPlayerBarSegmentedProgressView (iSB)
@property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
@property (nonatomic, retain) NSMutableArray <SponsorSegment *> *skipSegments;
- (void)removeSponsorMarkers;
@end

@interface YTPlayerBarSegmentMarkerView (iSB)
@property (nonatomic, assign) BOOL isSponsorMarker;
@end

@interface YTRightNavigationButtons (iSB)
@property (strong, nonatomic) YTQTMButton *sponsorBlockButton;
@end

@interface YTInlinePlayerBarView (iSB)
@property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
@property (strong, nonatomic) NSMutableArray *skipSegments;
- (void)removeSponsorMarkers;
- (void)maybeCreateMarkerViewsISB;
@end

@interface YTSegmentableInlinePlayerBarView (iSB)
@property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
@property (strong, nonatomic) NSMutableArray *skipSegments;
- (void)removeSponsorMarkers;
- (void)maybeCreateMarkerViewsISB;
@end

// Cercube
@interface CADownloadObject : NSObject
@property(readonly, nonatomic) NSString *filePath;
@property(copy, nonatomic) NSString *fileName; // @dynamic fileName;
@property(copy, nonatomic) NSString *videoId;
@end

@interface CADownloadObject_CADownloadObject_ : CADownloadObject
@end

@interface AVPlayerItem (Private)
- (NSURL *)_URL;
@end

@interface AVQueuePlayer (iSB)
@property (strong, nonatomic) NSMutableArray <SponsorSegment *> *skipSegments;
@property (nonatomic, assign) NSInteger currentSponsorSegment;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, assign) NSInteger unskippedSegment;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) NSInteger currentPlayerItem;
@property (strong, nonatomic) id timeObserver;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@property (strong, nonatomic) NSMutableArray *markerViews;
@property (nonatomic, assign) BOOL hudDisplayed;
- (void)sponsorBlockSetup;
- (void)updateMarkerViews;
@end

@interface AVScrubber : UIView
@end

@interface AVPlaybackControlsView : UIView
@property (strong, nonatomic) AVScrubber *scrubber;
@end

@interface AVPlayerViewControllerContentView : UIView
@property (strong, nonatomic) AVPlaybackControlsView *playbackControlsView;
@end

@interface AVPlayerViewController ()
@property (strong, nonatomic) AVPlayerViewControllerContentView *contentView;
@end

@interface AVContentOverlayView : UIView
@end
