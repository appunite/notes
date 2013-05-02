//
//  NTNoteAudioView.m
//  Notes
//
//  Created by Piotr Bernad on 31.01.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTNoteAudioView.h"

@implementation NTNoteAudioView

- (id)initWithAudioItem:(NTNoteAudioItem *)audioItem
{
    self = [super initWithFrame:CGRectZero viewIsResizable:NO showDotsOnEdit:NO showFrameOnEdit:NO];
    if (self) {
        // Initialization code
        self.item =audioItem;
        
        [self setAlpha:0.0];
        [self setFrame:[self.item rect]];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _offsetFromParent = CGPointMake(113, 75);
        
        [self addDeleteButton];
        [_deleteButton removeFromSuperview];
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"audio_delete_icon"] forState:UIControlStateNormal];

        _timeView = [[NTAudioNoteTimeView alloc] initWithFrame:CGRectMake(158, 75, 0, 49)];
        [self addSubview:_timeView];
        
        _playItemEnabled = YES;
        _recordItemEnabled = YES;
        _stopItemEnabled = YES;
        
        UIImage* playImage = [UIImage imageNamed:@"play_button_icon"];
        UIImage* recordImage = [UIImage imageNamed:@"record_button_icon"];
        UIImage* stopImage = [UIImage imageNamed:@"stop_button_icon"];
        
        // create rosette items
        _playItem = [[AURosetteItem alloc] initWithNormalImage:playImage
                                              highlightedImage:nil
                                                        target:self
                                                        action:@selector(playButtonAction:)];
        
        _recordItem = [[AURosetteItem alloc] initWithNormalImage:recordImage
                                                highlightedImage:nil
                                                          target:self
                                                          action:@selector(recordButtonAction:)];
        
        _stopItem = [[AURosetteItem alloc] initWithNormalImage:stopImage
                                              highlightedImage:nil
                                                        target:self
                                                        action:@selector(stopButtonAction:)];
        
        // create rosette view
        _rosetteView = [[NTRosetteView alloc] initWithItems: @[_playItem, _recordItem, _stopItem]];
        [_rosetteView setCenter:CGPointMake(154.0f, 100.0f)];
        [self addSubview:_rosetteView];
        
        [_rosetteView setOn:YES animated:YES];

        UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(wheelButtonLongPress:)];
        [_rosetteView.wheelButton addGestureRecognizer:longPressRecognizer];
        
        [self prepareToPlay];
        
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentView:(UIView *)newContentView {
    [super setContentView:newContentView];
    [self hideEditingHandles];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    [_deleteButton removeFromSuperview];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
    
    CGRect rect = [self.item rect];
    self.frame = CGRectOffset(rect, - _offsetFromParent.x, -_offsetFromParent.y);
    
    [UIView animateWithDuration:0.2 animations:^{
        [self setAlpha:1.0];
    }];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
    
    NSLog(@"ended");
    
    // Notify the delegate we've ended our editing session.
    [self.resizableViewDelegate viewDidChangePosition:CGRectOffset(self.frame, _offsetFromParent.x, _offsetFromParent.y)];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)prepareToPlay{

    NSData * audioFile = [self itemContent];
   
    if (audioFile) {
        [self presentTimeViewForced:YES];
    }
    
    // update info about current audio note on timer
    audioPlayer = [[AVAudioPlayer alloc] initWithData:audioFile error:nil];
    [self updateTimeLeftWhenPlaying];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *)createPathForNewAudio{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *path = [formatter stringFromDate:date];
    path = [path stringByAppendingString:@".m4a"];

    return path;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentTimeView {
    [self presentTimeViewForced:NO];
}

- (void)presentTimeViewForced:(BOOL)forced {
    
    [_timeView setCurrentTime:_currentTime recording:_recording];
    
    CGRect newFrame = _timeView.frame;
    newFrame.origin.x = (_recording || audioRecorder) ? 53 : (forced || _playing) ? 23 : 148;
    newFrame.size.width = (_recording || audioRecorder) ? 90 : (forced || _playing) ? 130 : 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [_timeView setFrame:newFrame];
    }];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)recordButtonAction:(AURosetteItem*)sender{
   
    if (!_recordItemEnabled) return;
    
    _recording = !_recording;
    _playing = NO;
    
    if (audioPlayer) {
        [audioPlayer stop];
    }
    
    if (audioRecorder) {
        if (_recording) {
            [audioRecorder record];
        } else {
            [audioRecorder pause];
        }
        [self updateButtons];
        return;
    }
    
    // check if item has previous record if yes warn user that he will be overridden
    if(audioPlayer.data){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Alert title")
                                                        message:NSLocalizedString(@"Do you want to delete the current record and create a new one?", @"Override alert message")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert Cancel button title")
                                              otherButtonTitles:NSLocalizedString(@"Yes", @"Yes alert button title"), nil];
        [alert show];
        
    }
    else {
        [self recordAudioNote];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)wheelButtonLongPress:(UILongPressGestureRecognizer*)gesture {
    
    [_deleteButton removeFromSuperview];
    [_rosetteView addSubview:_deleteButton];
    [_deleteButton setFrame:CGRectIntegral(_rosetteView.wheelButton.frame)];
    [self bringSubviewToFront:_deleteButton];
 
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)playButtonAction:(AURosetteItem*)sender{
    
    if (!_playItemEnabled) return;
   
    _playing = !_playing;
    
    [self updateButtons];
    
    if (_playing) {
        [self playAudioNote];
    } else {
        [audioPlayer pause];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)stopButtonAction:(AURosetteItem*)sender{

    if (!_stopItemEnabled) return;
    
    if (audioPlayer) {
        [audioPlayer stop];
    }
    
    _playing = NO;
    _recording = NO;
    
    [self stopAudioNote];
    [self updateButtons];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateButtons {
    [self presentTimeView];
    
    BOOL pulse = (audioRecorder && !_recording);
    
    [_rosetteView updateImageAtIndex:0 image:[UIImage imageNamed:_playing ? @"pause_button_icon" : @"play_button_icon"]];
    [_rosetteView updateImageAtIndex:1 image:[UIImage imageNamed:_recording ? @"pause_record_button_icon" : @"record_button_icon"] pulse:pulse];
    [_rosetteView updateImageAtIndex:2 image:[UIImage imageNamed:audioRecorder || _recording ? @"stop_record_button_icon" :  @"stop_button_icon"]];
    
    if (pulse) {
        CABasicAnimation *opacityBlink = [CABasicAnimation animationWithKeyPath:@"opacity" ];
        opacityBlink.delegate = self;
        [opacityBlink setFromValue:[NSNumber numberWithFloat:0.0]];
        [opacityBlink setToValue:[NSNumber numberWithFloat:1.0]];
        [opacityBlink setDuration:0.5f];
        opacityBlink.repeatCount = CGFLOAT_MAX;
        opacityBlink.autoreverses = YES;
        [_timeView.timeLabel.layer addAnimation:opacityBlink forKey:@"opacity"];
    } else {
        [_timeView.timeLabel.layer removeAnimationForKey:@"opacity"];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    if(buttonIndex == 1){
        [self recordAudioNote];
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - AVAudioRecorder & AVAudioPlayer Actions

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)recordAudioNote
{
    [self updateButtons];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityHigh],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:kAudioFormatAppleLossless],
                                    AVFormatIDKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    
    NSError *error = nil;
    
    [self itemContent];
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.fileURL settings:recordSettings error:&error];
    [audioRecorder setDelegate:self];
    [audioRecorder prepareToRecord];
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        return;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
        return;
    }
    
    
    if (!audioRecorder.recording)
    {
        _playItemEnabled = NO;
        _stopItemEnabled = YES;

        [audioRecorder record];
        
        [myTimer invalidate];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(updateDurationTimeWhenRecording)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)stopAudioNote
{
    
    _stopItemEnabled = YES;
    _playItemEnabled = YES;
    _recordItemEnabled = YES;
    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    
    audioRecorder = nil;
    [myTimer invalidate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)playAudioNote
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];

    if (!audioRecorder.recording)
    {
        
    _stopItemEnabled = YES;
    _recordItemEnabled = YES;

    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:[self itemContent] error:&error];
    [audioPlayer prepareToPlay];
    audioPlayer.delegate = self;
        
    if (error) NSLog(@"Error: %@", [error localizedDescription]);
    else [audioPlayer play];
        
    [myTimer invalidate];
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(updateTimeLeftWhenPlaying)
                                                           userInfo:nil
                                                            repeats:YES];
    
    }
}

#pragma mark - audio playing / recording time

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateTimeLeftWhenPlaying{
    
    NSInteger minutes = floor(audioPlayer.currentTime/60);
    NSInteger seconds = round(audioPlayer.currentTime - minutes * 60);
    
    NSInteger endMinutes = floor(audioPlayer.duration/60);
    NSInteger endSeconds = round(audioPlayer.duration - endMinutes * 60);

    NSString * currentTime = [NSString stringWithFormat:@"%d:%02d / %d:%02d", minutes, seconds, endMinutes, endSeconds];
    [_timeView setCurrentTime:currentTime recording:_recording];
 
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateDurationTimeWhenRecording{
    
    NSInteger endMinutes = floor(audioRecorder.currentTime/60);
    NSInteger endSeconds = round(audioRecorder.currentTime - endMinutes * 60);
    
    NSString * currentTime = [NSString stringWithFormat:@"%d:%02d", endMinutes, endSeconds];
    [_timeView setCurrentTime:currentTime recording:_recording];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NTNoteAudioItem *)item {
    return (NTNoteAudioItem *)[super item];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - AudioRecorder Delegate

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _recordItemEnabled = YES;
    _stopItemEnabled = NO;
    _playing = NO;
    _recording = NO;
    
    [self updateButtons];
}



@end
