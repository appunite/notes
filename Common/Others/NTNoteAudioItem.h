//
//  NTNoteAudioItem.h
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>

//Others
#import "NTNoteItem.h"

@interface NTNoteAudioItem : NTNoteItem

@property (nonatomic, strong) NSURL *localPath;

@property (nonatomic, strong) NSURL *remotePath;

@end

@interface NTNoteAudioItem (Draw)

+ (void)drawItem:(NTNoteAudioItem *)item rect:(CGRect)rect context:(CGContextRef)ctx;

@end
