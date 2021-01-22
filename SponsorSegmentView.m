#import "SponsorSegmentView.h"
#include "RemoteLog.h"
@implementation SponsorSegmentView
-(instancetype)initWithFrame:(CGRect)frame sponsorSegment:(SponsorSegment *)segment editable:(BOOL)editable {
    self = [super initWithFrame:frame];
    if(self){
        self.sponsorSegment = segment;
        self.editable = editable;
        
        NSString *category;
        if([segment.category isEqualToString:@"sponsor"]){
            category = @"Sponsor";
        }
        else if([segment.category isEqualToString:@"intro"]) {
            category = @"Intermission";
        }
        else if([segment.category isEqualToString:@"outro"]) {
            category = @"Outro";
        }
        else if([segment.category isEqualToString:@"interaction"]) {
            category = @"Interaction";
        }
        else if([segment.category isEqualToString:@"selfpromo"]) {
            category = @"Self Promo";
        }
        else if([segment.category isEqualToString:@"music_offtopic"]) {
            category = @"Non-Music";
        }
        self.categoryLabel = [[UILabel alloc] initWithFrame:self.frame];
        self.segmentLabel = [[UILabel alloc] initWithFrame:self.frame];
        self.categoryLabel.text = category;
        self.segmentLabel.text = [NSString stringWithFormat:@"%ld:%02ld to %ld:%02ld",lroundf(segment.startTime)/60, lroundf(segment.startTime)%60,lroundf(segment.endTime)/60,lroundf(segment.endTime)%60];
        
        [self addSubview:self.categoryLabel];
        self.categoryLabel.adjustsFontSizeToFitWidth = YES;
        self.categoryLabel.font = [UIFont systemFontOfSize:12];
        self.categoryLabel.textAlignment = NSTextAlignmentCenter;
        self.categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.segmentLabel];
        self.segmentLabel.adjustsFontSizeToFitWidth = YES;
        self.segmentLabel.font = [UIFont systemFontOfSize:12];
        self.segmentLabel.textAlignment = NSTextAlignmentCenter;
        self.segmentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.segmentLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
        [self.segmentLabel.heightAnchor constraintEqualToConstant:self.frame.size.height/2].active = YES;
        
        [self.categoryLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
        [self.categoryLabel.heightAnchor constraintEqualToConstant:self.frame.size.height/2].active = YES;
        [self.categoryLabel.topAnchor constraintEqualToAnchor:self.segmentLabel.bottomAnchor].active = YES;
        
        self.backgroundColor = UIColor.systemGray4Color;
        self.layer.cornerRadius = 10;
        self.segmentLabel.layer.cornerRadius = 10;
        self.categoryLabel.layer.cornerRadius = 10;
    }
    return self;
}
@end
