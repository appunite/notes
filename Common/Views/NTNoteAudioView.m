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
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code

        self.item =audioItem;
        
        [self setFrame:[self.item rect]];
        [self setBackgroundColor:[UIColor clearColor]];
        [self bringSubviewToFront:borderView];

        
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 60, 40)];
        [_playButton setBackgroundColor:[UIColor grayColor]];
        [_playButton addTarget:self action:@selector(playAudioNote) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"play_button_icon"] forState:UIControlStateNormal];
        [self addSubview:_playButton];

        
        _stopButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 30, 60, 40)];
        [_stopButton setBackgroundColor:[UIColor grayColor]];
        [_stopButton addTarget:self action:@selector(stopAudioNote) forControlEvents:UIControlEventTouchUpInside];
        [_stopButton setImage:[UIImage imageNamed:@"stop_button_icon"] forState:UIControlStateNormal];
        [self addSubview:_stopButton];
        
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 30, 60, 40)];
        [_recordButton setImage:[UIImage imageNamed:@"record_button_icon"] forState:UIControlStateNormal];
        [_recordButton addTarget:self action:@selector(recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton setBackgroundColor:[UIColor grayColor]];
        [self addSubview:_recordButton];
        
        _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
        [_currentTime setBackgroundColor:[UIColor grayColor]];
        [_currentTime setText:@"no audio item"];
        [_currentTime setTextColor:[UIColor blackColor]];
        [self addSubview:_currentTime];
        
        [self prepareToPlay];
        
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)prepareToPlay{
    
    if([self.item localPath]){
        
        // create NSURL from item localPath
        _fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _fileURL = [_fileURL URLByAppendingPathComponent:[self.item localPath]];
        
    }
    
    //check if resource is reachable 
    if (!_fileURL || [_fileURL checkResourceIsReachableAndReturnError:nil] == NO){
        
        // download remote data
        NSData *fileData = [NSData dataWithContentsOfURL:[self.item remotePath]];
        
        // create local path component
        NSString *temporaryPath = [self createPathForNewAudio];
        
        // create new local url
        _fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _fileURL = [_fileURL URLByAppendingPathComponent:temporaryPath];
        
        // save new localPath to item
        [self.item setLocalPath:temporaryPath];
        
        if(fileData){
            // save downloaded data to file
            [fileData writeToURL:_fileURL atomically:YES];
        }
        
    }
    
    // update info about current audio note on timer
    audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfURL:_fileURL] error:nil];
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

-(void)recordButtonTapped{
    
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
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:_fileURL settings:recordSettings error:&error];
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
        _playButton.enabled = NO;
        _stopButton.enabled = YES;

        [audioRecorder record];
        [_recordButton setBackgroundColor:[UIColor redColor]];
        
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
    
    _stopButton.enabled = NO;
    _playButton.enabled = YES;
    _recordButton.enabled = YES;
    
    [_recordButton setBackgroundColor:[UIColor grayColor]];
    [_playButton setBackgroundColor:[UIColor grayColor]];
    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)playAudioNote
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [_playButton setBackgroundColor:[UIColor redColor]];
    if (!audioRecorder.recording)
    {
        
    _stopButton.enabled = YES;
    _recordButton.enabled = NO;

        
    NSData *data = [NSData dataWithContentsOfURL:_fileURL];
        
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
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

    [_currentTime setText:[NSString stringWithFormat:@"%d:%02d / %d:%02d", minutes, seconds, endMinutes, endSeconds]];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateDurationTimeWhenRecording{
    
    NSInteger endMinutes = floor(audioRecorder.currentTime/60);
    NSInteger endSeconds = round(audioRecorder.currentTime - endMinutes * 60);
    
    [_currentTime setText:[NSString stringWithFormat:@"%d:%02d", endMinutes, endSeconds]];
    
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
    _recordButton.enabled = YES;
    _stopButton.enabled = NO;
    [_playButton setBackgroundColor:[UIColor grayColor]];
}



@end
