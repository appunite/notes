//
//  NTSelfDownloadingView.m
//  Notes
//
//  Created by Piotrek on 30.04.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTSelfDownloadingView.h"
#import "NTNoteDownloadableItem.h"

@implementation NTSelfDownloadingView


- (NSData *)itemContent {
     
    if([(NTNoteDownloadableItem*)self.item localPath]){
        
        // create NSURL from item localPath
        _fileURL = [NSURL fileURLWithPath:[(NTNoteDownloadableItem*)self.item localPath]];
    }
    
    NSError * error;
    
    //check if resource is reachable
    if (!_fileURL || ![_fileURL checkResourceIsReachableAndReturnError:&error]) {
        
        // download remote data
        NSData *fileData = [NSData dataWithContentsOfURL:[(NTNoteDownloadableItem*)self.item remotePath]];
        
        // create local path component
        NSURL *remotePath = [(NTNoteDownloadableItem*)self.item remotePath];
        NSString *temporaryPath = remotePath ? [[[remotePath absoluteString] componentsSeparatedByString:@"/"] lastObject] : [self createPath];
        
        // create new local url
        _fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _fileURL = [_fileURL URLByAppendingPathComponent:temporaryPath];
        
        if ([self.item isKindOfClass:[NTNoteAudioItem class]]) {
            [(NTNoteDownloadableItem*)self.item setLocalPath:[_fileURL path]];
        }
        
        if(fileData){
            // save downloaded data to file
            [(NTNoteDownloadableItem*)self.item setLocalPath:[_fileURL path]];
            
            [fileData writeToURL:_fileURL atomically:YES];
            return fileData;
        }
    } else {
        return [NSData dataWithContentsOfURL:_fileURL];
    }
    
    return nil;
}

-(NSString *)createPath{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *path = [formatter stringFromDate:date];
    path = [path stringByAppendingString:[self.item isKindOfClass:[NTNoteAudioItem class]] ? @".m4a" : @".jpg"];
    
    return path;
}

@end
