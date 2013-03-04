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



@interface NTNoteAudioView : NTUserResizableView <AVAudioPlayerDelegate, AVAudioRecorderDelegate, UIAlertViewDelegate>{
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    UIView *myView;
    UILabel *_currentTime;
    NSTimer * myTimer;
    
}
@property UIButton *playButton;
@property UIButton *recordButton;
@property UIButton *stopButton;
@property UISegmentedControl *playerControl;
@property NSURL *fileURL;

// redefine model object
-(NTNoteAudioItem *)item;

- (id)initWithAudioItem:(NTNoteAudioItem *)audioItem;

-(void)playAudioNote;
-(void)recordAudioNote;
-(void)stopAudioNote;
@end
