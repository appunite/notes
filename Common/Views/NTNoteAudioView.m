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
        
        [self setFrame:self.item.rect];
        [self setBackgroundColor:[UIColor redColor]];
        
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_playButton setBackgroundColor:[UIColor grayColor]];
        [_playButton addTarget:self action:@selector(playAudioNote) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setTitle:@">" forState:UIControlStateNormal];
        [self addSubview:_playButton];
        
        _stopButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 0, 60, 60)];
        [_stopButton setBackgroundColor:[UIColor grayColor]];
        [_stopButton addTarget:self action:@selector(stopAudioNote) forControlEvents:UIControlEventTouchUpInside];
        [_stopButton setTitle:@"[]" forState:UIControlStateNormal];
        [self addSubview:_stopButton];
        
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(120, 0, 60, 60)];
        [_recordButton setTitle:@"*" forState:UIControlStateNormal];
        [_recordButton addTarget:self action:@selector(recordAudioNote) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton setBackgroundColor:[UIColor grayColor]];
        [self addSubview:_recordButton];
        
        [self prepareViewToRecording];
        
    }
    return self;
}
-(void)prepareViewToRecording{
    
    NSLog(@"prepare: %@", [self.item localPath]);
    
    if(![[self.item localPath] isKindOfClass:[NSURL class]]){

        NSData *fileData = [NSData dataWithContentsOfURL:[self.item remotePath]]; //download remote data
        NSString *temporaryPath = [self createPathForNewAudio]; //create local path component
        NSURL *localURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        localURL = [localURL URLByAppendingPathComponent:temporaryPath]; // create new local url
        [fileData writeToURL:localURL atomically:YES]; //save to file
        [self.item setLocalPath:localURL]; // set item localURL
    
    }
    
    
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
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self.item localPath] settings:recordSettings error:&error];
    [audioRecorder setDelegate:self];
    [audioRecorder prepareToRecord];
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    }
    
}
-(NSString *)createPathForNewAudio{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *path = [formatter stringFromDate:date];
    path = [path stringByAppendingString:@".m4a"];

    return path;

}
-(void)recordAudioNote
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
//        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
//        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    
    if (!audioRecorder.recording)
    {
        _playButton.enabled = NO;
        _stopButton.enabled = YES;

        [audioRecorder record];
        [_recordButton setBackgroundColor:[UIColor redColor]];    
    }

}
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
-(void)playAudioNote
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [_playButton setBackgroundColor:[UIColor redColor]];
    if (!audioRecorder.recording)
    {
        
    _stopButton.enabled = YES;
    _recordButton.enabled = NO;

    NSError *error;
        
    NSData *data = [NSData dataWithContentsOfURL:[self.item localPath]];

    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    [audioPlayer prepareToPlay];
    audioPlayer.delegate = self;
    NSLog(@"%@", audioPlayer.data);
        
    if (error) NSLog(@"Error: %@", [error localizedDescription]);
    else [audioPlayer play];
        
    }
}

#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NTNoteAudioItem *)item {
    return (NTNoteAudioItem *)[super item];
}

#pragma mark - AudioRecorder Delegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _recordButton.enabled = YES;
    _stopButton.enabled = NO;
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
}

@end
