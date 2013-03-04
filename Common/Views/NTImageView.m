//
//  NTImageView.m
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTImageView.h"

@implementation NTImageView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    return [self initWithFrame:CGRectZero];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
    // get current context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
//    // change CTM
//    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(rect));
//    CGContextScaleCTM(ctx, 1.0, -1.0);

    // draw note item
    [NTNoteImageItem drawItem:[self item] rect:rect context:ctx];
}


#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NTNoteImageItem *)item {
    return (NTNoteImageItem *)[super item];
}
@end

