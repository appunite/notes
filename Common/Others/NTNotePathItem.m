//
//  NTNotePathItem.m
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNotePathItem.h"

#define DEFAULT_COLOR [UIColor blackColor]
#define DEFAULT_WIDTH 5.0f

@implementation NTNotePathItem

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        // set defalts
        _lineWidth = DEFAULT_WIDTH;
        _lineColor = DEFAULT_COLOR;
        
        // create new mutable path
        _path = CGPathCreateMutable();
    }
    return self;
}


#pragma mark - Draw

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)drawItem:(NTNotePathItem *)item rect:(CGRect)rect context:(CGContextRef)ctx {
    [[UIColor clearColor] set];
    UIRectFill(rect);

	CGContextAddPath(ctx, item.path);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, item.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, item.lineColor.CGColor);
    CGContextStrokePath(ctx);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
	CGPathRelease(_path);
}

@end
