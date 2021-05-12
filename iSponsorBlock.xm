#import "iSponsorBlock.h"
#import "colorFunctions.h"
#import "SponsorBlockSettingsController.h"
#import "SponsorBlockRequest.h"
#import "SponsorBlockViewController.h"

%group Main
NSString *modifiedTimeString;

%hook YTPlayerViewController
%property (strong, nonatomic) NSMutableArray *skipSegments;
%property (nonatomic, assign) NSInteger currentSponsorSegment;
%property (strong, nonatomic) MBProgressHUD *hud;
%property (nonatomic, assign) NSInteger unskippedSegment;
%property (strong, nonatomic) NSMutableArray *userSkipSegments;
%property (strong, nonatomic) NSString *channelID;
-(void)singleVideo:(id)arg1 currentVideoTimeDidChange:(YTSingleVideoTime *)arg2 {
    %orig;
    id overlayView = self.view.overlayView;
    if(!self.channelID) {
        self.channelID = @"";
    }
    if(self.skipSegments.count > 0 && [overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)] && ![kWhitelistedChannels containsObject:self.channelID]){
        if(kShowModifiedTime){
            UILabel *durationLabel = self.view.overlayView.playerBar.durationLabel;
            if(![durationLabel.text containsString:modifiedTimeString]) durationLabel.text = [NSString stringWithFormat:@"%@ (%@)", durationLabel.text, modifiedTimeString];
            [durationLabel sizeToFit];
        }
        
        SponsorSegment *sponsorSegment = [[SponsorSegment alloc] initWithStartTime:-1 endTime:-1 category:nil UUID:nil];
        if(self.currentSponsorSegment <= self.skipSegments.count-1){
            sponsorSegment = self.skipSegments[self.currentSponsorSegment];
        }
        else if (self.unskippedSegment != self.currentSponsorSegment-1) {
            sponsorSegment = self.skipSegments[self.currentSponsorSegment-1];
        }
        
        if((lroundf(arg2.time) == ceil(sponsorSegment.startTime) && arg2.time >= sponsorSegment.startTime) || (lroundf(arg2.time) >= ceil(sponsorSegment.startTime) && arg2.time < sponsorSegment.endTime)) {

            if([[kCategorySettings objectForKey:sponsorSegment.category] intValue] == 3) {
                if(self.hud.superview != self.view) {
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    self.hud.mode = MBProgressHUDModeCustomView;
                    self.hud.label.text = [NSString stringWithFormat:@"Manually Skip %@ from %ld:%02ld to %ld:%02ld", sponsorSegment.category, lroundf(sponsorSegment.startTime)/60, lroundf(sponsorSegment.startTime)%60,lroundf(sponsorSegment.endTime)/60,lroundf(sponsorSegment.endTime)%60];
                    [self.hud.button setTitle:@"Skip" forState:UIControlStateNormal];
                    [self.hud.button addTarget:self action:@selector(manuallySkipSegment:) forControlEvents:UIControlEventTouchUpInside];
                    self.hud.offset = CGPointMake(self.view.frame.size.width, -MBProgressMaxOffset);
                    [self.hud hideAnimated:YES afterDelay:(sponsorSegment.endTime - sponsorSegment.startTime)];
                }
            }
            //edge case where segment end time is longer than the video
            else if(sponsorSegment.endTime > self.currentVideoTotalMediaTime) {
                [self scrubToTime:self.currentVideoTotalMediaTime];
                if(kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
            }
            else {
                [self scrubToTime:sponsorSegment.endTime];
                if(kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
            }
            if(self.hud.superview != self.view && kShowSkipNotice) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.hud.mode = MBProgressHUDModeCustomView;
                self.hud.label.text = @"Skipped Segment";
                [self.hud.button setTitle:@"Unskip Segment" forState:UIControlStateNormal];
                [self.hud.button addTarget:self action:@selector(unskipSegment:) forControlEvents:UIControlEventTouchUpInside];
                self.hud.offset = CGPointMake(self.view.frame.size.width, -MBProgressMaxOffset);
                [self.hud hideAnimated:YES afterDelay:kSkipNoticeDuration];
            }
                                                                                                         
            if(self.currentSponsorSegment <= self.skipSegments.count-1 && [[kCategorySettings objectForKey:sponsorSegment.category] intValue] != 3) self.currentSponsorSegment ++;
        }
        else if(lroundf(arg2.time) > sponsorSegment.startTime && self.currentSponsorSegment != self.skipSegments.count && self.currentSponsorSegment != self.skipSegments.count-1) {
            self.currentSponsorSegment ++;
        }
        else if(self.currentSponsorSegment == 0 && self.unskippedSegment != -1) {
            self.currentSponsorSegment ++;
        }
        else if(self.currentSponsorSegment > 0 && lroundf(arg2.time) < self.skipSegments[self.currentSponsorSegment-1].endTime) {
            if(self.MDXActive) {
        
            }
            else if(self.unskippedSegment != self.currentSponsorSegment-1) {
                self.currentSponsorSegment --;
            }
            else if(arg2.time < self.skipSegments[self.currentSponsorSegment-1].startTime-0.01) {
                self.unskippedSegment = -1;
            }
        }
    }
    if([overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]){
        YTPlayerBarSegmentedProgressView *segmentedProgressView = [self.view.overlayView.playerBar.playerBar valueForKey:@"_segmentedProgressView"];
        if(segmentedProgressView.playerViewController != self) segmentedProgressView.playerViewController = self;
        for(UIView *markerView in segmentedProgressView.subviews){
            if(![(NSArray *)[segmentedProgressView valueForKey:@"_markerViews"] containsObject:markerView] && [markerView isKindOfClass:%c(YTPlayerBarSegmentMarkerView)] && segmentedProgressView.skipSegments.count == 0) {
                [segmentedProgressView maybeCreateMarkerViews];
                return;
            }
        }
    }
}
-(void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3{
    %orig;
    if(!self.isPlayingAd && [self.view.overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]){
        [MBProgressHUD hideHUDForView:self.view animated:YES]; //fix manual skip popup not disappearing when changing videos

        self.skipSegments = [NSMutableArray array];
        self.userSkipSegments = [NSMutableArray array];
        [SponsorBlockRequest getSponsorTimes:self.currentVideoID completionTarget:self completionSelector:@selector(setSkipSegments:)];
        self.currentSponsorSegment = 0;
        self.unskippedSegment = -1;
        self.view.overlayView.controlsOverlayView.playerViewController = self;
        self.view.overlayView.controlsOverlayView.isDisplayingSponsorBlockViewController = NO;
        
        YTSingleVideoController *activeVideo = self.activeVideo;
        if([activeVideo isKindOfClass:%c(YTSingleVideoController)]) {
            if([self.activeVideo.singleVideo respondsToSelector:@selector(video)]) {
                self.channelID = self.activeVideo.singleVideo.video.videoDetails.channelId;
            }
            else {
                self.channelID = self.activeVideo.singleVideo.playbackData.video.videoDetails.channelId;
            }
        }
    }
}
-(void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)arg1 {
    %orig;
    NSInteger totalSavedTime = 0;
    for(SponsorSegment *segment in arg1) {
        totalSavedTime += lroundf(segment.endTime) - lroundf(segment.startTime);
    }
    if(arg1.count > 0) {
        NSInteger seconds = lroundf(self.currentVideoTotalMediaTime - totalSavedTime);
        NSInteger hours = seconds / 3600;
        NSInteger  minutes = (seconds - (hours * 3600)) / 60;
        seconds = seconds %60;
        
        if(hours >= 1) modifiedTimeString = [NSString stringWithFormat:@"%ld:%02ld:%02ld",hours, minutes, seconds];
        else modifiedTimeString = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
    }

    else {
        modifiedTimeString = nil;
    }
}
-(void)scrubToTime:(CGFloat)arg1 {
    %orig;
    //fixes visual glitch
    if(!self.isPlayingAd) {
        id overlayView = self.view.overlayView;
        if([overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]){
            YTPlayerBarSegmentedProgressView *segmentedProgressView = [self.view.overlayView.playerBar.playerBar valueForKey:@"_segmentedProgressView"];
            [segmentedProgressView maybeCreateMarkerViews];

        }
    }
}
%new
-(void)unskipSegment:(UIButton *)sender {
    if(self.currentSponsorSegment > 0){
        [self scrubToTime:self.skipSegments[self.currentSponsorSegment-1].startTime];
        self.unskippedSegment = self.currentSponsorSegment-1;
    }
    else {
        [self scrubToTime:self.skipSegments[self.currentSponsorSegment].startTime];
        self.unskippedSegment = self.currentSponsorSegment;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
%new
-(void)manuallySkipSegment:(UIButton *)sender {
    SponsorSegment *sponsorSegment = [[SponsorSegment alloc] initWithStartTime:-1 endTime:-1 category:nil UUID:nil];
    if(self.currentSponsorSegment <= self.skipSegments.count-1){
        sponsorSegment = self.skipSegments[self.currentSponsorSegment];
    }
    else if (self.unskippedSegment != self.currentSponsorSegment-1) {
        sponsorSegment = self.skipSegments[self.currentSponsorSegment-1];
    }
    
    if(sponsorSegment.endTime > self.currentVideoTotalMediaTime) {
        [self scrubToTime:self.currentVideoTotalMediaTime];
        if(kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
    }
    else {
        [self scrubToTime:sponsorSegment.endTime];
        if(kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.currentSponsorSegment++;
}
%end

%hook YTMainAppControlsOverlayView
%property (strong, nonatomic) YTQTMButton *sponsorBlockButton;
%property (strong, nonatomic) YTQTMButton *sponsorStartedEndedButton;
%property (strong, nonatomic) YTPlayerViewController *playerViewController;
%property (nonatomic, assign) BOOL isDisplayingSponsorBlockViewController;
-(NSArray *)topControls {
    NSArray <UIView *> *topControls = %orig;
    if(![topControls containsObject:self.sponsorBlockButton] && kShowButtonsInPlayer){
        NSMutableArray *mutableArray = topControls.mutableCopy;
        if(!self.sponsorBlockButton){
            self.sponsorBlockButton = [%c(YTQTMButton) iconButton];
            self.sponsorBlockButton.frame = CGRectMake(0, 0, 24, 36);
            [self.sponsorBlockButton setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/iSponsorBlock/PlayerInfoIconSponsorBlocker256px-20@2x.png"] forState:UIControlStateNormal];
            
            self.sponsorStartedEndedButton = [%c(YTQTMButton) iconButton];
            self.sponsorStartedEndedButton.frame = CGRectMake(0,0,24,36);
            if(self.playerViewController.userSkipSegments.lastObject.endTime != -1) [self.sponsorStartedEndedButton setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/iSponsorBlock/sponsorblockstart-20@2x.png"] forState:UIControlStateNormal];
            else [self.sponsorStartedEndedButton setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/iSponsorBlock/sponsorblockend-20@2x.png"] forState:UIControlStateNormal];

            if(topControls[0].superview == self){
                [self addSubview:self.sponsorBlockButton];
                [self addSubview:self.sponsorStartedEndedButton];
            }
            else {
                UIView *containerView = [self valueForKey:@"_topControlsAccessibilityContainerView"];
                [containerView addSubview:self.sponsorBlockButton];
                [containerView addSubview:self.sponsorStartedEndedButton];
            }

            [self.sponsorBlockButton addTarget:self action:@selector(sponsorBlockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.sponsorStartedEndedButton addTarget:self action:@selector(sponsorStartedEndedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [mutableArray insertObject:self.sponsorBlockButton atIndex:0];
        [mutableArray insertObject:self.sponsorStartedEndedButton atIndex:0];
        return mutableArray.copy;
    }
    return %orig;
}
-(void)setTopOverlayVisible:(BOOL)arg1 isAutonavCanceledState:(BOOL)arg2 {
    if(self.isDisplayingSponsorBlockViewController) {
        %orig(NO, arg2);
        self.sponsorBlockButton.imageView.hidden = YES;
        self.sponsorStartedEndedButton.imageView.hidden = YES;
        return;
    }
    BOOL overlayVisible;
    if([self respondsToSelector:@selector(isOverlayVisible)]) {
        overlayVisible = self.overlayVisible;
    }
    else {
        overlayVisible = [[self valueForKey:@"_isOverlayVisible"] boolValue];
    }
    self.sponsorBlockButton.hidden = !overlayVisible;
    self.sponsorStartedEndedButton.hidden = !overlayVisible;
    
    self.sponsorBlockButton.imageView.hidden = !overlayVisible;
    self.sponsorStartedEndedButton.imageView.hidden = !overlayVisible;
    %orig;
}

%new
-(void)sponsorBlockButtonPressed:(YTQTMButton *)sender {
    self.isDisplayingSponsorBlockViewController = YES;
    self.sponsorBlockButton.hidden = YES;
    self.sponsorStartedEndedButton.hidden = YES;
    if([self.playerViewController playerViewLayout] == 3){
        [self.playerViewController didPressToggleFullscreen];
    }
    [self presentSponsorBlockViewController];
}
%new
-(void)sponsorStartedEndedButtonPressed:(YTQTMButton *)sender {
    if(self.playerViewController.userSkipSegments.lastObject.endTime != -1) {
        [self.playerViewController.userSkipSegments addObject:[[SponsorSegment alloc] initWithStartTime:self.playerViewController.currentVideoMediaTime endTime:-1 category:nil UUID:nil]];
       [self.sponsorStartedEndedButton setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/iSponsorBlock/sponsorblockend-20@2x.png"] forState:UIControlStateNormal];
    }
    else {
        self.playerViewController.userSkipSegments.lastObject.endTime = self.playerViewController.currentVideoMediaTime;
        if(self.playerViewController.userSkipSegments.lastObject.endTime != self.playerViewController.currentVideoMediaTime) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"End Time That You Set Was Less Than the Start Time, Please Select a Time After %ld:%02ld",lroundf(self.playerViewController.userSkipSegments.lastObject.startTime)/60, lroundf(self.playerViewController.userSkipSegments.lastObject.startTime)%60] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [[[UIApplication sharedApplication] delegate].window.rootViewController  presentViewController:alert animated:YES completion:nil];
            return;
        }
        [self.sponsorStartedEndedButton setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/iSponsorBlock/sponsorblockstart-20@2x.png"] forState:UIControlStateNormal];
    }
}
%new
-(void)presentSponsorBlockViewController {
    SponsorBlockViewController *addSponsorViewController = [[SponsorBlockViewController alloc] init];
    addSponsorViewController.playerViewController = self.playerViewController;
    addSponsorViewController.previousParentViewController = self.playerViewController.parentViewController;
    addSponsorViewController.overlayView = self;
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:addSponsorViewController animated:YES completion:nil];
    self.isDisplayingSponsorBlockViewController = YES;
    [self setOverlayVisible:NO];

}
%end

%hook YTPlayerBarSegmentMarkerView
%property (nonatomic, assign) BOOL isSponsorMarker;
//fix crash when frame had an invalid rect
-(instancetype)initWithFrame:(CGRect)frame {
    if (CGRectIsEmpty(frame)) {
        return %orig(CGRectMake(0,0,0,0));
    }
    return %orig;
}
-(void)setFrame:(CGRect)frame {
    if (CGRectIsEmpty(frame)) {
        %orig(CGRectMake(0,0,0,0));
    }
    %orig;
}

-(UIColor *)colorForType:(NSInteger)type {
    switch (type) {
        case 100:
            return colorWithHexString([kCategorySettings objectForKey:@"sponsorColor"]);
        case 101:
            return colorWithHexString([kCategorySettings objectForKey:@"introColor"]);
        case 102:
            return colorWithHexString([kCategorySettings objectForKey:@"outroColor"]);
        case 103:
            return colorWithHexString([kCategorySettings objectForKey:@"interactionColor"]);
        case 104:
            return colorWithHexString([kCategorySettings objectForKey:@"selfpromoColor"]);
        case 105:
            return colorWithHexString([kCategorySettings objectForKey:@"music_offtopicColor"]);
    }
    return %orig;
}
%end

%hook YTPlayerBarSegmentedProgressView
%property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
%property (strong, nonatomic) NSMutableArray *skipSegments;
%property (strong, nonatomic) YTPlayerViewController *playerViewController;
-(void)maybeCreateMarkerViews {
    %orig;
    [self removeSponsorMarkers];
    self.skipSegments = self.skipSegments;
    for(YTPlayerBarSegmentMarkerView *markerView in self.sponsorMarkerViews){
        CGFloat beginX = (markerView.startTime * self.superview.frame.size.width) / self.totalTime;
        CGFloat endX = (markerView.endTime * self.superview.frame.size.width) / self.totalTime;
        if(endX >= beginX) markerView.width = endX - beginX;
        else markerView.width = 0;
        if(!markerView.superview) {
            [self addSubview:markerView];
        }
    }
    for(UIView *markerView in self.subviews){
        if(![(NSArray *)[self valueForKey:@"_markerViews"] containsObject:markerView] && [markerView isKindOfClass:%c(YTPlayerBarSegmentMarkerView)]) {
            [markerView removeFromSuperview];
        }
    }
}

-(void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)arg1 {
    %orig;
    if([kWhitelistedChannels containsObject:self.playerViewController.channelID]) {
        return;
    }
    NSMutableArray <YTPlayerBarSegmentMarkerView *> *markerViews = [self valueForKey:@"_markerViews"];
    [markerViews removeObjectsInArray:self.sponsorMarkerViews];
     [self setValue:markerViews forKey:@"_markerViews"];
    [self removeSponsorMarkers];
    self.sponsorMarkerViews = [NSMutableArray array];
    for(SponsorSegment *segment in arg1) {
        CGFloat startTime = segment.startTime;
        CGFloat endTime = segment.endTime;
        CGFloat beginX = (startTime * self.frame.size.width) / self.totalTime;
        CGFloat endX = (endTime * self.frame.size.width) / self.totalTime;
        CGFloat markerWidth;
        if(endX >= beginX) markerWidth = endX - beginX;
            else markerWidth = 0;
        
        NSInteger type;
        if([segment.category isEqualToString:@"sponsor"]) type = 100;
        else if([segment.category isEqualToString:@"intro"]) type = 101;
        else if([segment.category isEqualToString:@"outro"]) type = 102;
        else if([segment.category isEqualToString:@"interaction"]) type = 103;
        else if([segment.category isEqualToString:@"selfpromo"]) type = 104;
        else if([segment.category isEqualToString:@"music_offtopic"]) type = 105;

        if([self respondsToSelector:@selector(createAndAddMarker:type:width:)]){
            [self createAndAddMarker:startTime type:type width:markerWidth];
        }
        else if ([self respondsToSelector:@selector(createAndAddMarker:type:clusterType:width:)]){
            [self createAndAddMarker:startTime type:type clusterType:0 width:markerWidth];
        }
        else if ([self respondsToSelector:@selector(addMarkerViewToClosestSegmentView:)]) {
            YTPlayerBarSegmentMarkerView *markerView = [[%c(YTPlayerBarSegmentMarkerView) alloc] init];
            markerView.startTime = startTime;
            markerView.endTime = endTime;
            markerView.width = markerWidth;
            markerView.type = type;
            NSMutableArray *markerViews = [self valueForKey:@"_markerViews"];
            [markerViews addObject:markerView];
            [self addMarkerViewToClosestSegmentView:markerView];
        }
        else {
            return;
        }
        markerViews = [self valueForKey:@"_markerViews"];
        [self.sponsorMarkerViews addObject:markerViews.lastObject];
        markerViews.lastObject.isSponsorMarker = YES;
    }
}
-(void)setAnchorPoint:(id)arg1 {
    %orig;
    //fixes visual glitch with player bar
    NSMutableArray <UIView *> *segmentViews = [self segmentViews];
    if(segmentViews.count == 1){
        segmentViews[0].frame = CGRectMake(0, segmentViews[0].frame.origin.y, segmentViews[0].frame.size.width, segmentViews[0].frame.size.height);
    }
}
%new
-(void)removeSponsorMarkers {
    NSMutableArray *markerViews = [self valueForKey:@"_markerViews"];
    [markerViews removeObjectsInArray:self.sponsorMarkerViews];
     [self setValue:markerViews forKey:@"_markerViews"];
    for(YTPlayerBarSegmentMarkerView *markerView in [self valueForKey:@"_markerViews"]) {
        if(markerView.isSponsorMarker){
            [markerView removeFromSuperview];
        }
    }
    self.sponsorMarkerViews = [NSMutableArray array];
}
%end

%hook YTInlinePlayerBarContainerView
-(instancetype)initWithScrubbedTimeLabelsDisplayBelowStoryboard:(BOOL)arg1 enableSegmentedProgressView:(BOOL)arg2 {
    return %orig(arg1, YES);
}
//does the same thing as the method above on youtube v. 16.0x
-(instancetype)initWithEnableSegmentedProgressView:(BOOL)arg1 {
    return %orig(YES);
}

-(void)setPeekableViewVisible:(BOOL)arg1 {
    %orig;
    if(kShowModifiedTime && modifiedTimeString && ![self.durationLabel.text containsString:modifiedTimeString]){
        NSString *text = [NSString stringWithFormat:@"%@ (%@)", self.durationLabel.text, modifiedTimeString];
        self.durationLabel.text = text;
        [self.durationLabel sizeToFit];
    }
}
%end

%hook YTNGWatchLayerViewController
-(void)didCompleteFullscreenDismissAnimation {
    %orig;
    if(!self.playerViewController.isPlayingAd && self.playerViewController.view.overlayView.controlsOverlayView.isDisplayingSponsorBlockViewController && [self.playerViewController.view.overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        [self.playerViewController.view.overlayView.controlsOverlayView presentSponsorBlockViewController];
    }
}
%end

%hook YTPlayerView
//https://stackoverflow.com/questions/11770743/capturing-touches-on-a-subview-outside-the-frame-of-its-superview-using-hittest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.clipsToBounds || self.hidden || self.alpha == 0) {
        return nil;
    }
    
    for (UIView *subview in self.subviews.reverseObjectEnumerator) {
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        UIView *result = [subview hitTest:subPoint withEvent:event];
        if (result) return result;
    }
    return nil;
}
%end
%end

%group Cercube
//ew global variables
NSArray <SponsorSegment *> *skipSegments;
AVQueuePlayer *queuePlayer;

%hook CADownloadObject
+ (id)modelWithMetadata:(id)arg1 format:(id)arg2 context:(id)arg3 type:(id)arg4 audioOnly:(_Bool)arg5 directory:(id)arg6 {
    CADownloadObject *downloadObject = %orig;
    [SponsorBlockRequest getSponsorTimes:downloadObject.videoId completionTarget:downloadObject completionSelector:@selector(setSkipSegments:)];
    return downloadObject;
}

%new
-(void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)skipSegments {
    NSString *path = [self.filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[[self.fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"]];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    NSMutableArray *segments = [NSMutableArray array];
    for(SponsorSegment *segment in skipSegments) {
        [segments addObject:@{
            @"startTime" : @(segment.startTime),
            @"endTime" : @(segment.endTime),
            @"category" : segment.category,
            @"UUID" : segment.UUID
        }];
    }
    NSDictionary *dict = @{
        @"skipSegments" : segments
    };
    [dict writeToURL:[NSURL fileURLWithPath:path isDirectory:NO] error:nil];
}
%end
%hook AVPlayerViewController
-(void)viewDidLoad {
    %orig;
    [(AVQueuePlayer *)self.player setPlayerViewController:self];
}
%end

%hook AVScrubber
//this is bad but i don't feel like finding a better way
-(void)layoutSubviews {
    %orig;
    [queuePlayer updateMarkerViews];
}
%end

%hook AVQueuePlayer
%property (strong, nonatomic) NSMutableArray *skipSegments;
%property (nonatomic, assign) NSInteger currentSponsorSegment;
%property (strong, nonatomic) MBProgressHUD *hud;
%property (nonatomic, assign) NSInteger unskippedSegment;
%property (nonatomic, assign) BOOL isSeeking;
%property (nonatomic, assign) NSInteger currentPlayerItem;
%property (strong, nonatomic) id timeObserver;
%property (strong, nonatomic) AVPlayerViewController *playerViewController;
%property (strong, nonatomic) NSMutableArray *markerViews;
-(instancetype)initWithItems:(NSArray<AVPlayerItem *> *)items {
    self.currentPlayerItem = 0;
    queuePlayer = self;
    return %orig;
}
-(void)seekToTime:(CMTime)time {
    %orig;
    self.isSeeking = YES;
     [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:NO block:^(NSTimer *timer) {
        self.isSeeking = NO;
    }];
}
-(void)_itemIsReadyToPlay:(id)arg1 {
    %orig;
    self.isSeeking = NO;
    [self sponsorBlockSetup];
}
-(void)_advanceCurrentItemAccordingToFigPlaybackItem:(id)arg1 {
    %orig;
    if(self.currentPlayerItem + 1 < [self items].count) self.currentPlayerItem ++;
}
-(void)_removeItem:(id)arg1 {
    %orig;
    [self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
    if(self.currentPlayerItem != 0) self.currentPlayerItem --;
    [self sponsorBlockSetup];
}
%new
-(void)updateMarkerViews {
    if(self.skipSegments.count > 0) {
        CGFloat totalTime = [@([self items][self.currentPlayerItem].duration.value) floatValue] / [self items][self.currentPlayerItem].duration.timescale;
        for(UIView *markerView in self.markerViews) {
            AVScrubber *scrubber = self.playerViewController.contentView.playbackControlsView.scrubber;
            CGFloat startTime = self.skipSegments[[self.markerViews indexOfObject:markerView]].startTime;
            CGFloat endTime = self.skipSegments[[self.markerViews indexOfObject:markerView]].endTime;
            CGFloat beginX = (startTime * scrubber.frame.size.width) / totalTime;
            CGFloat endX = (endTime * scrubber.frame.size.width) / totalTime;
            CGFloat markerWidth = endX - beginX;
            markerView.frame = CGRectMake(beginX, scrubber.frame.size.height/2-2, markerWidth, 5);
        }
    }
}
%new
-(void)sponsorBlockSetup {
    if([self items].count <= 0) return;
    NSString *path = [[[[self items][self.currentPlayerItem] _URL].path stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
    NSDictionary *segmentsDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *segments = [segmentsDict objectForKey:@"skipSegments"];
    self.skipSegments = [NSMutableArray array];
    CGFloat totalTime = [@([self items][self.currentPlayerItem].duration.value) floatValue] / [self items][self.currentPlayerItem].duration.timescale;
    for(UIView *markerView in self.markerViews) {
        [markerView removeFromSuperview];
    }
    self.markerViews = [NSMutableArray array];
    for(NSDictionary *dict in segments) {
        SponsorSegment *segment = [[SponsorSegment alloc] initWithStartTime:[[dict objectForKey:@"startTime"] floatValue] endTime:[[dict objectForKey:@"endTime"] floatValue] category:[dict objectForKey:@"category"] UUID:[dict objectForKey:@"UUID"]];
        [self.skipSegments addObject:segment];
        AVScrubber *scrubber = self.playerViewController.contentView.playbackControlsView.scrubber;
        CGFloat startTime = segment.startTime;
        CGFloat endTime = segment.endTime;
        CGFloat beginX = (startTime * scrubber.frame.size.width) / totalTime;
        CGFloat endX = (endTime * scrubber.frame.size.width) / totalTime;
        CGFloat markerWidth = endX - beginX;
        UIView *markerView = [[UIView alloc] initWithFrame:CGRectMake(beginX, 2, markerWidth, 5)];

        if([segment.category isEqualToString:@"sponsor"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"sponsorColor"]);
        else if([segment.category isEqualToString:@"intro"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"introColor"]);
        else if([segment.category isEqualToString:@"outro"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"outroColor"]);
        else if([segment.category isEqualToString:@"interaction"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"interactionColor"]);
        else if([segment.category isEqualToString:@"selfpromo"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"selfpromoColor"]);
        else if([segment.category isEqualToString:@"music_offtopic"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"music_offtopicColor"]);
        [scrubber addSubview:markerView];
        [self.markerViews addObject:markerView];
    }
    skipSegments = self.skipSegments;
    self.currentSponsorSegment = 0;
    self.unskippedSegment = -1;
    CMTime timeInterval = CMTimeMake(1,10);
    __weak AVQueuePlayer *weakSelf = self;
    [self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;

    self.timeObserver = [self addPeriodicTimeObserverForInterval:timeInterval queue:nil usingBlock:^(CMTime time) {
        CGFloat timeFloat = [@(time.value) floatValue] / time.timescale;
        if(weakSelf.skipSegments.count > 0) {
            SponsorSegment *sponsorSegment = [[SponsorSegment alloc] initWithStartTime:-1 endTime:-1 category:nil UUID:nil];
            if(weakSelf.currentSponsorSegment <= weakSelf.skipSegments.count-1) {
                sponsorSegment = weakSelf.skipSegments[weakSelf.currentSponsorSegment];
            }
            else if (weakSelf.unskippedSegment != weakSelf.currentSponsorSegment-1) {
                sponsorSegment = weakSelf.skipSegments[weakSelf.currentSponsorSegment-1];
            }
            
            if((lroundf(timeFloat) == ceil(sponsorSegment.startTime) && timeFloat >= sponsorSegment.startTime) || (lroundf(timeFloat) >= ceil(sponsorSegment.startTime) && timeFloat < sponsorSegment.endTime)) {
                if([[kCategorySettings objectForKey:sponsorSegment.category] intValue] == 3) {
                    if(weakSelf.hud.superview != weakSelf.playerViewController.view) {
                        weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.playerViewController.view animated:YES];
                        weakSelf.hud.mode = MBProgressHUDModeCustomView;
                        weakSelf.hud.label.text = [NSString stringWithFormat:@"Manually Skip %@ from %ld:%02ld to %ld:%02ld", sponsorSegment.category, lroundf(sponsorSegment.startTime)/60, lroundf(sponsorSegment.startTime)%60,lroundf(sponsorSegment.endTime)/60,lroundf(sponsorSegment.endTime)%60];
                        [weakSelf.hud.button setTitle:@"Skip" forState:UIControlStateNormal];
                        [weakSelf.hud.button addTarget:weakSelf action:@selector(manuallySkipSegment:) forControlEvents:UIControlEventTouchUpInside];
                        weakSelf.hud.offset = CGPointMake(weakSelf.playerViewController.view.frame.size.width, -MBProgressMaxOffset);
                        [weakSelf.hud hideAnimated:YES afterDelay:(sponsorSegment.endTime - sponsorSegment.startTime)];
                    }
                }
                
                else if (sponsorSegment.endTime > totalTime) {
                    [weakSelf seekToTime:CMTimeMake(totalTime,1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                }
                else {
                    [weakSelf seekToTime:CMTimeMake(sponsorSegment.endTime,1)];
                }
                
                if(weakSelf.hud.superview != weakSelf.playerViewController.view && kShowSkipNotice) {
                    [MBProgressHUD hideHUDForView:weakSelf.playerViewController.view animated:YES];
                    weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.playerViewController.view animated:YES];
                    weakSelf.hud.mode = MBProgressHUDModeCustomView;
                    weakSelf.hud.label.text = @"Skipped Segment";
                    [weakSelf.hud.button setTitle:@"Unskip Segment" forState:UIControlStateNormal];
                    [weakSelf.hud.button addTarget:weakSelf action:@selector(unskipSegment:) forControlEvents:UIControlEventTouchUpInside];
                    weakSelf.hud.offset = CGPointMake(weakSelf.playerViewController.view.frame.size.width, -MBProgressMaxOffset);
                    [weakSelf.hud hideAnimated:YES afterDelay:kSkipNoticeDuration];
                }
                
                if(weakSelf.currentSponsorSegment <= weakSelf.skipSegments.count-1) weakSelf.currentSponsorSegment ++;
            }
            else if(lroundf(timeFloat) > sponsorSegment.startTime && weakSelf.currentSponsorSegment < weakSelf.skipSegments.count-1) {
                weakSelf.currentSponsorSegment ++;
            }
            else if(weakSelf.currentSponsorSegment == 0 && weakSelf.unskippedSegment != -1) {
                weakSelf.currentSponsorSegment ++;
            }
            else if(weakSelf.currentSponsorSegment > 0 && lroundf(timeFloat) < weakSelf.skipSegments[weakSelf.currentSponsorSegment-1].endTime) {
                if(weakSelf.unskippedSegment != weakSelf.currentSponsorSegment-1) {
                    weakSelf.currentSponsorSegment --;
                }
                else if(timeFloat < weakSelf.skipSegments[weakSelf.currentSponsorSegment-1].startTime-0.01) {
                    weakSelf.unskippedSegment = -1;
                }
            }
        }
    }];
}
%new
-(void)unskipSegment:(UIButton *)sender {
    if(self.currentSponsorSegment > 0){
        [self seekToTime:CMTimeMake(self.skipSegments[self.currentSponsorSegment-1].startTime,1)];
        self.unskippedSegment = self.currentSponsorSegment-1;
    }
    else {
        [self seekToTime:CMTimeMake(self.skipSegments[self.currentSponsorSegment].startTime,1)];
        self.unskippedSegment = self.currentSponsorSegment;
    }
    [MBProgressHUD hideHUDForView:self.playerViewController.view animated:YES];
}
%end
%end

%group JustSettings
NSInteger pageStyle = 0;
%hook YTRightNavigationButtons
%property (strong, nonatomic) YTQTMButton *sponsorBlockButton;
-(NSMutableArray *)buttons {
    NSMutableArray *retVal = %orig.mutableCopy;
    [self.sponsorBlockButton removeFromSuperview];
    [self addSubview:self.sponsorBlockButton];
    if(!self.sponsorBlockButton || pageStyle != [%c(YTPageStyleController) pageStyle]) {
        self.sponsorBlockButton = [%c(YTQTMButton) iconButton];
        self.sponsorBlockButton.frame = CGRectMake(0, 0, 40, 40);
        
        if([%c(YTPageStyleController) pageStyle]) { //dark mode
            [self.sponsorBlockButton setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/iSponsorBlock/sponsorblocksettings-20@2x.png"] forState:UIControlStateNormal];
        }
        else { //light mode
            UIImage *image = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/iSponsorBlock/sponsorblocksettings-20@2x.png"];
            image = [image imageWithTintColor:UIColor.blackColor renderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.sponsorBlockButton setImage:image forState:UIControlStateNormal];
            [self.sponsorBlockButton setTintColor:UIColor.blackColor];
        }
        pageStyle = [%c(YTPageStyleController) pageStyle];
        
        [self.sponsorBlockButton addTarget:self action:@selector(sponsorBlockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [retVal insertObject:self.sponsorBlockButton atIndex:0];
    }
    return retVal;
}
-(NSMutableArray *)visibleButtons {
    NSMutableArray *retVal = %orig.mutableCopy;
    
    //fixes button overlapping yt logo on smaller devices
    [self setLeadingPadding:-10];
    if(self.sponsorBlockButton) {
        [self.sponsorBlockButton removeFromSuperview];
        [self addSubview:self.sponsorBlockButton];
        [retVal insertObject:self.sponsorBlockButton atIndex:0];
    }
    return retVal;
}
%new
-(void)sponsorBlockButtonPressed:(UIButton *)sender {
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:[[SponsorBlockSettingsController alloc] init] animated:YES completion:nil];
}
%end
%end

static void loadPrefs() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    kIsEnabled = [settings objectForKey:@"enabled"] ? [[settings objectForKey:@"enabled"] boolValue] : YES;
    kUserID = [settings objectForKey:@"userID"] ? [settings objectForKey:@"userID"] : [[NSUUID UUID] UUIDString];
    kCategorySettings = [settings objectForKey:@"categorySettings"] ? [settings objectForKey:@"categorySettings"] : @{
        @"sponsor" : @1,
        @"sponsorColor" : hexFromUIColor(UIColor.greenColor),
        @"intro" : @0,
        @"introColor" : hexFromUIColor(UIColor.systemTealColor),
        @"outro" : @0,
        @"outroColor" : hexFromUIColor(UIColor.blueColor),
        @"interaction" : @0,
        @"interactionColor" : hexFromUIColor(UIColor.systemPinkColor),
        @"selfpromo" : @0,
        @"selfpromoColor" : hexFromUIColor(UIColor.yellowColor),
        @"music_offtopic" : @0,
        @"music_offtopicColor" : hexFromUIColor(UIColor.orangeColor)
    };
    kMinimumDuration = [settings objectForKey:@"minimumDuration"] ? [[settings objectForKey:@"minimumDuration"] floatValue] : 0.0f;
    kShowSkipNotice = [settings objectForKey:@"showSkipNotice"] ? [[settings objectForKey:@"showSkipNotice"] boolValue] : YES;
    kShowButtonsInPlayer = [settings objectForKey:@"showButtonsInPlayer"] ? [[settings objectForKey:@"showButtonsInPlayer"] boolValue] : YES;
    kShowModifiedTime = [settings objectForKey:@"showModifiedTime"] ? [[settings objectForKey:@"showModifiedTime"] boolValue] : YES;
    kEnableSkipCountTracking = [settings objectForKey:@"enableSkipCountTracking"] ? [[settings objectForKey:@"enableSkipCountTracking"] boolValue] : YES;
    kSkipNoticeDuration = [settings objectForKey:@"skipNoticeDuration"] ? [[settings objectForKey:@"skipNoticeDuration"] floatValue] : 3.0f;
    kWhitelistedChannels = [settings objectForKey:@"whitelistedChannels"] ? [(NSArray *)[settings objectForKey:@"whitelistedChannels"] mutableCopy] : [NSMutableArray array];
    
    NSDictionary *newSettings = @{
      @"enabled" : @(kIsEnabled),
      @"userID" : kUserID,
      @"categorySettings" : kCategorySettings,
      @"minimumDuration" : @(kMinimumDuration),
      @"showSkipNotice" : @(kShowSkipNotice),
      @"showButtonsInPlayer" : @(kShowButtonsInPlayer),
      @"showModifiedTime" : @(kShowModifiedTime),
      @"enableSkipCountTracking" : @(kEnableSkipCountTracking),
      @"skipNoticeDuration" : @(kSkipNoticeDuration),
      @"whitelistedChannels" : kWhitelistedChannels
    };
    if(![newSettings isEqualToDictionary:settings]) {
        [newSettings writeToURL:[NSURL fileURLWithPath:path isDirectory:NO] error:nil];
    }

}

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
}

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.galacticdev.isponsorblockprefs.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    if(kIsEnabled) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        if(dlopen("/Library/MobileSubstrate/DynamicLibraries/Cercube.dylib", RTLD_LAZY)) {
            %init(Cercube)
            NSString *downloadsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Carida_Files"];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadsDirectory error:nil];
            for(NSString *path in files) {
                if([path.pathExtension isEqualToString:@"plist"]) {
                    NSString *mp4Path = [downloadsDirectory stringByAppendingPathComponent:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"]];
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mp4Path];
                    if(!fileExists) {
                        [[NSFileManager defaultManager] removeItemAtPath:[downloadsDirectory stringByAppendingPathComponent:path] error:nil];
                    }
                }
            }
        }
        %init(Main);
    }
    %init(JustSettings);
}

%dtor {
    if(dlopen("/Library/MobileSubstrate/DynamicLibraries/Cercube.dylib", RTLD_LAZY)) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *downloadsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Carida_Files"];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadsDirectory error:nil];
        for(NSString *path in files) {
            if([path.pathExtension isEqualToString:@"plist"]) {
                NSString *mp4Path = [downloadsDirectory stringByAppendingPathComponent:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"]];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mp4Path];
                if(!fileExists) {
                    [[NSFileManager defaultManager] removeItemAtPath:[downloadsDirectory stringByAppendingPathComponent:path] error:nil];
                }
            }
        }
    }
}
