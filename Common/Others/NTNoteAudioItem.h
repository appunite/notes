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
#import "NTNoteDownloadableItem.h"

@interface NTNoteAudioItem : NTNoteDownloadableItem
@end

@interface NTNoteAudioItem (Draw)
+ (void)drawItem:(NTNoteAudioItem *)item rect:(CGRect)rect context:(CGContextRef)ctx;
@end
