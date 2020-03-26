@interface MLHAMPlayer
-(void)availableCaptionTracksDidChange:(id)arg1;
-(void)seekToTime:(CGFloat)arg1;
-(void)skipFirstSponsor:(NSArray *)data;
-(void)skipSecondSponsor:(NSArray *)data;
@end

@interface MLNerdStatsPlaybackData
-(id)initWithPlayer:(id)arg1 videoID:(id)arg2 CPN:(id)arg3;
-(id)videoID;
@end

@interface YTWatchController
-(id)initWithWatchFlowController:(id)arg1 parentResponder:(id)arg2;
-(CGFloat)activeVideoMediaTime;
@end
