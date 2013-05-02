//
//  NTNoteImageItem.m
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteImageItem.h"

@implementation NTNoteImageItem

#pragma mark - Draw

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)drawItem:(NTNoteImageItem *)item image:(NSData *)image rect:(CGRect)rect context:(CGContextRef)ctx {
    
    // set clear background color
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, rect);
    
    // new draw rect
    CGRect boundsInsetRect = CGRectInset(rect, 16.0f, 16.0f);
    
    // rounded corners path
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:boundsInsetRect cornerRadius:8.0f];
    
    // draw outer shadow
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, CGSizeMake(2.0f, 3.0f), 8.0f, [[UIColor blackColor] colorWithAlphaComponent:0.75f].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    [path fill];
    CGContextRestoreGState(ctx);
    
    // draw stroke
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    path.lineWidth = 8.0f;
    [path stroke];
    
    // draw white background color
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // get resource
    UIImage* contentImage = image ? [UIImage imageWithData:image] : [UIImage imageNamed:@"image.png"];
    
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
