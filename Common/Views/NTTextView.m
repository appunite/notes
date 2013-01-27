//
//  NTTextView.m
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTTextView.h"

@implementation NTTextView

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
    [NTNoteTextItem drawItem:[self item] rect:rect context:ctx color:[self.item color] font:[self.item font]];
}


#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NTNoteTextItem *)item {
    return (NTNoteTextItem *)[super item];
}

@end
