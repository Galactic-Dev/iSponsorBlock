@interface MLHAMPlayer
-(void)seekToTime:(CGFloat)arg1;
-(id)initWithVideo:(id)arg1 playerConfig:(id)arg2 stickySettings:(id)arg3 playerView:(id)arg4 frameSourceDelegate:(id)arg5;
@end

@interface MLNerdStatsPlaybackData
-(id)initWithPlayer:(id)arg1 videoID:(id)arg2 CPN:(id)arg3;
-(id)videoID;
@end

@interface YTInlinePlayerBarView : NSObject
-(CGFloat)mediaTime;
-(void)setTotalTime:(CGFloat)arg1;
-(void)skipSponsor:(NSArray *)data;
@property(nonatomic, assign) CGFloat mediaTime;
@end
