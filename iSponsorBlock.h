@interface MLHAMPlayer
-(void)availableCaptionTracksDidChange:(id)arg1;
-(void)seekToTime:(CGFloat)arg1;
-(void)skipFirstSponsor:(NSDictionary *)data;
-(void)skipSecondSponsor:(NSDictionary *)data;
-(id)initWithVideo:(id)arg1 playerConfig:(id)arg2 playerView:(id)arg3 frameSourceDelegate:(id)arg4;
@end

@interface MLNerdStatsPlaybackData
-(id)initWithPlayer:(id)arg1 videoID:(id)arg2 CPN:(id)arg3;
-(id)videoID;
@end

@interface YTWatchController
-(id)initWithWatchFlowController:(id)arg1 parentResponder:(id)arg2;
-(CGFloat)activeVideoMediaTime;
@end

@interface YTMainWindow : UIView
-(id)initWithFrame:(CGRect)arg1;
-(void)skipFirstSponsor:(NSDictionary *)data;
-(void)skipSecondSponsor:(NSDictionary *)data;
@end

@interface YTDoubleTapToSeekController
-(BOOL)attemptSeekByInterval:(CGFloat)arg1;
-(id)initWithDelegate:(id)arg1 parentResponder:(id)arg2;
-(void)endDoubleTapToSeek;
@end
