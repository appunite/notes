//
//  NTAudioNoteTimeView.h
//  Notes
//
//  Created by Piotrek on 05.04.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTAudioNoteTimeView : UIImageView {
    UILabel * _timeLabel;
    BOOL _recording;
}

@property (nonatomic, readonly) UILabel * timeLabel;
- (void)setCurrentTime:(NSString*)time recording:(BOOL)recording;
@end
