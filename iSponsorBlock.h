#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#include <RemoteLog.h>
#import <dlfcn.h>
#import "MBProgressHUD.h"
#import "SponsorSegment.h"
#include <math.h>


//prefs
BOOL kIsEnabled;
NSString *kUserID;
NSDictionary *kCategorySettings;
CGFloat kMinimumDuration;
BOOL kShowSkipNotice;
BOOL kShowButtonsInPlayer;
BOOL kShowModifiedTime;
BOOL kEnableSkipCountTracking;
CGFloat kSkipNoticeDuration;
NSMutableArray <NSString *> *kWhitelistedChannels;

@interface YTInlinePlayerBarView : UIView
@end

@interface YTSegmentableInlinePlayerBarView : UIView
@end

@interface YTInlinePlayerBarContainerView : UIView
-(void)setChapters:(NSArray *)arg1;
@property (strong, nonatomic) NSArray *chaptersArray;
@property (strong, nonatomic) YTInlinePlayerBarView *playerBar;
@property (strong, nonatomic) YTInlinePlayerBarView *segmentablePlayerBar;
@property (strong, nonatomic) UILabel *durationLabel;
@end

@interface YTQTMButton : UIButton
+(instancetype)iconButton;
@property (strong, nonatomic) UIImageView *imageView;
@end

@interface YTMainAppControlsOverlayView : UIView
@end

@interface YTMainAppVideoPlayerOverlayView : UIView
@property (strong, nonatomic) YTInlinePlayerBarContainerView *playerBar;
@property (strong, nonatomic) YTMainAppControlsOverlayView *controlsOverlayView;
@end

@interface YTPlayerView : UIView
@property (strong, nonatomic) YTMainAppVideoPlayerOverlayView *overlayView;
@end

@interface YTIVideoDetails : NSObject
@property (nonatomic, copy, readwrite) NSString *channelId;
@end

@interface MLVideo : NSObject
- (YTIVideoDetails *)videoDetails;
@end

@interface YTPlaybackData : NSObject
@property (strong, nonatomic) MLVideo *video;
@end

@interface YTSingleVideo : NSObject
@property (strong, nonatomic) MLVideo *video;
@property (strong, nonatomic) YTPlaybackData *playbackData;
@end

@interface YTSingleVideoController : NSObject
@property (strong, nonatomic) YTSingleVideo *singleVideo;
@end

@interface YTPlayerViewController : UIViewController
@property (strong, nonatomic) YTPlayerView *view;
-(instancetype)initWithParentResponder:(id)arg1 overlayFactory:(id)arg2;
-(void)scrubToTime:(CGFloat)arg1;
-(void)isb_scrubToTime:(CGFloat)arg1;
-(void)seekToTime:(CGFloat)arg1;
-(void)isb_fixVisualGlitch;
-(NSInteger)playerViewLayout;
-(void)didPressToggleFullscreen;
-(void)setPlayerViewLayout:(NSInteger)arg1;
@property (strong, nonatomic) NSString *currentVideoID;
@property (nonatomic, assign) CGFloat currentVideoMediaTime;
@property (nonatomic, assign) CGFloat currentVideoTotalMediaTime;
@property (nonatomic, assign) BOOL isPlayingAd;
@property (strong, nonatomic) NSMutableArray <SponsorSegment *> *skipSegments;
@property (nonatomic, assign) NSInteger currentSponsorSegment;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, assign) NSInteger unskippedSegment;
@property (strong, nonatomic) NSMutableArray <SponsorSegment *> *userSkipSegments;
@property (strong, nonatomic) YTSingleVideoController *activeVideo;
@property (strong, nonatomic) NSString *channelID;
@property (nonatomic, assign, getter=isMDXActive) BOOL MDXActive;
@end

//ik i'm redefining it im just lazy and dont feel like fixing this header
@interface YTMainAppControlsOverlayView ()
-(void)sponsorBlockButtonPressed:(YTQTMButton *)sender;
-(void)sponsorStartedButtonPressed:(YTQTMButton *)sender;
-(void)sponsorEndedButtonPressed:(YTQTMButton *)sender;
-(void)setOverlayVisible:(BOOL)arg1;
-(void)presentSponsorBlockViewController;
-(NSArray *)topControls;
- (void)setOverlayVisible:(BOOL)arg1;
@property (retain, nonatomic) YTQTMButton *sponsorBlockButton;
@property (retain, nonatomic) YTQTMButton *sponsorStartedEndedButton;
@property (retain, nonatomic) YTPlayerViewController *playerViewController;
@property (nonatomic, assign) BOOL isDisplayingSponsorBlockViewController;
@property (nonatomic, assign, getter=isOverlayVisible) BOOL overlayVisible;
@end

@interface YTSingleVideoTime : NSObject
@property (nonatomic, assign) CGFloat time;
@end

@interface YTIFormattedString : NSObject
+(instancetype)formattedStringWithString:(NSString *)arg1;
@end

@interface YTIChapterRenderer : NSObject
@property (strong, nonatomic) YTIFormattedString *title;
@property (nonatomic, assign) NSInteger timeRangeStartMillis;
@end

@interface YTIChapterRendererWrapper : NSObject
-(instancetype)initWithStartTime:(CGFloat)arg1 endTime:(CGFloat)arg2 title:(NSString *)arg3;
+(instancetype)chapterRendererWrapperWithRenderer:(YTIChapterRenderer *)arg1;
@property (nonatomic, assign) CGFloat endTime;
@end

@interface YTPlayerBarSegmentedProgressView : UIView
-(void)setChapters:(NSArray *)arg1;
@property (nonatomic, assign) CGFloat totalTime;
@property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
@property (nonatomic, assign) NSInteger playerViewLayout;
@property (nonatomic, retain) NSMutableArray <SponsorSegment *> *skipSegments;
@property (strong, nonatomic) YTPlayerViewController *playerViewController;
-(void)createAndAddMarker:(CGFloat)arg1 type:(NSInteger)arg2 width:(CGFloat)arg3;
-(void)createAndAddMarker:(CGFloat)arg1 type:(NSInteger)arg2 clusterType:(NSInteger)arg3 width:(CGFloat)arg4;
-(void)addMarkerViewToClosestSegmentView:(id)arg1;
-(void)maybeCreateMarkerViews;
-(void)removeSponsorMarkers;
-(NSMutableArray *)segmentViews;
@end

@interface YTPlayerBarSegmentMarkerView : UIView
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) BOOL isSponsorMarker;
@property (nonatomic, assign) NSInteger type;
@end

@interface YTNGWatchLayerViewController
@property (strong, nonatomic) YTPlayerViewController *playerViewController;
@end

@interface YTWatchLayerViewController
@property (strong, nonatomic) YTPlayerViewController *playerViewController;
@end

@interface YTRightNavigationButtons : UIView
@property (retain, nonatomic) YTQTMButton *sponsorBlockButton;
-(void)setLeadingPadding:(CGFloat)arg1;
@end

@interface YTPageStyleController
+(NSInteger)pageStyle;
@end


//redefinition
@interface YTInlinePlayerBarView ()
@property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
@property (strong, nonatomic) NSMutableArray *skipSegments;
@property (strong, nonatomic) YTPlayerViewController *playerViewController;
-(void)removeSponsorMarkers;
-(void)maybeCreateMarkerViewsISB;
@property (nonatomic, assign) CGFloat totalTime;
@end

//redefinition
@interface YTSegmentableInlinePlayerBarView ()
@property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
@property (strong, nonatomic) NSMutableArray *skipSegments;
@property (strong, nonatomic) YTPlayerViewController *playerViewController;
-(void)removeSponsorMarkers;
-(void)maybeCreateMarkerViewsISB;
@property (nonatomic, assign) CGFloat totalTime;
@end

//Cercube
@interface CADownloadObject : NSObject
@property(readonly, nonatomic) NSString *filePath;
@property(copy, nonatomic) NSString *fileName; // @dynamic fileName;
@property(copy, nonatomic) NSString *videoId;
@end

@interface CADownloadObject_CADownloadObject_ : CADownloadObject
@end

@interface AVPlayerItem ()
-(NSURL *)_URL;
@end

@interface AVQueuePlayer ()
@property (strong, nonatomic) NSMutableArray <SponsorSegment *> *skipSegments;
@property (nonatomic, assign) NSInteger currentSponsorSegment;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, assign) NSInteger unskippedSegment;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) NSInteger currentPlayerItem;
@property (strong, nonatomic) id timeObserver;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@property (strong, nonatomic) NSMutableArray *markerViews;
-(void)sponsorBlockSetup;
-(void)updateMarkerViews;
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
