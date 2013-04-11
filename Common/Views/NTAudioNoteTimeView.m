//
//  NTAudioNoteTimeView.m
//  Notes
//
//  Created by Piotrek on 05.04.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NTAudioNoteTimeView.h"

@implementation NTAudioNoteTimeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setImage:[[UIImage imageNamed:@"time_box_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)]];
        
        _recording = NO;
        
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextColor:[self colorForCurrentState]];
        [_timeLabel setShadowColor:[UIColor whiteColor]];
        [_timeLabel setShadowOffset:CGSizeMake(0, 1)];
        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_timeLabel];
        
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowRadius:5.0];
        [self.layer setShadowOffset:CGSizeMake(1, 1)];
        [self.layer setShadowOpacity:1.0];
    }
    return self;
}

- (UIColor*)colorForCurrentState {
    return _recording ? [UIColor colorWithRed:101.0/255.0 green:101.0/255.0 blue:101.0/255.0 alpha:1] : [UIColor colorWithRed:217.0/255.0 green:25.0/255.0 blue:33.0/255.0 alpha:1];
}

- (void)layoutSubviews {
    [_timeLabel setFrame:CGRectOffset(CGRectInset(self.bounds, 5, 0), -9, 0)];
}

- (void)setCurrentTime:(NSString *)time recording:(BOOL)recording {
    [_timeLabel setText:time];
    [_timeLabel setTextColor:[self colorForCurrentState]];
}

@end
