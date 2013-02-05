//
//  NTNoteAudioItem.m
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteAudioItem.h"

@implementation NTNoteAudioItem

#pragma mark - Draw

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)drawItem:(NTNoteAudioItem *)item rect:(CGRect)rect context:(CGContextRef)ctx {
    
    // set clear background color
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, rect);
    
    // new draw rect
    CGRect boundsInsetRect = rect;
    
    // get contetn image
    UIImage* contentImage = [UIImage imageNamed:@"audio_note_image"];
    
    // draw content image
    if (contentImage) {
        
        CGRect imageRect = CGRectInset(boundsInsetRect, 8.0f, 8.0f);
        CGContextSaveGState(ctx);
        
        // change CTM
        CGContextTranslateCTM(ctx, 0, CGRectGetMaxY(imageRect));
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        // draw image
        CGContextDrawImage(ctx, CGRectMake(CGRectGetMinX(imageRect), 0, CGRectGetWidth(imageRect), CGRectGetHeight(imageRect)), contentImage.CGImage);
        CGContextRestoreGState(ctx);
    }
}

@end
