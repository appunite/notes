//
//  NTNoteAudioView.h
//  Notes
//
//  Created by Piotr Bernad on 31.01.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NTNoteAudioItem.h"

#import "NTUserResizableView.h"

@interface NTNoteAudioView : NTUserResizableView <AVAudioPlayerDelegate, AVAudioRecorderDelegate>{
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    UIView *myView;
}
@property UIButton *playButton;
@property UIButton *recordButton;
@property UIButton *stopButton;
@property UISegmentedControl *playerControl;

// redefine model object
-(NTNoteAudioItem *)item;

- (id)initWithAudioItem:(NTNoteAudioItem *)audioItem;

-(void)playAudioNote;
-(void)recordAudioNote;
-(void)stopAudioNote;
@end
