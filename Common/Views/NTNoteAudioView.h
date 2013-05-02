//
//  NTNoteAudioView.h
//  Notes
//
//  Created by Piotr Bernad on 31.01.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "NTRosetteView.h"

#import "NTNoteAudioItem.h"
#import "NTSelfDownloadingView.h"
#import "NTAudioNoteTimeView.h"

@class SPGripViewBorderView;

@protocol NTUserResizableViewDelegate;

@interface NTNoteAudioView : NTSelfDownloadingView <AVAudioPlayerDelegate, AVAudioRecorderDelegate, UIAlertViewDelegate>{
    
    NTRosetteView * _rosetteView;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    UIView *myView;
    UILabel *_currentTime;
    NSTimer * myTimer;
    CGPoint _offsetFromParent;
    
    NTAudioNoteTimeView * _timeView;
    
    AURosetteItem* _playItem;
    AURosetteItem* _recordItem;
    AURosetteItem* _stopItem;
    
    BOOL _playItemEnabled;
    BOOL _recordItemEnabled;
    BOOL _stopItemEnabled;
    
    BOOL _playing;
    BOOL _recording;
}

@property UISegmentedControl *playerControl;

// redefine model object
-(NTNoteAudioItem *)item;

- (id)initWithAudioItem:(NTNoteAudioItem *)audioItem;

-(void)playAudioNote;
-(void)recordAudioNote;
-(void)stopAudioNote;
@end
