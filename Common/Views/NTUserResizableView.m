//
//  NTUserResizableView.m
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTUserResizableView.h"

@implementation NTUserResizableView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithItem:(NTNoteItem *)item {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _item = item;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.minHeight = 180.0f;
        self.minWidth = 180.0f;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
    if (_item) {

        // enlarged rect (for blue dots)
//        CGRect rect = CGRectInset([_item rect], -20.0f, -20.0f);
        CGRect rect = [_item rect];
        
        self.frame = rect;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    [super resizeUsingTouchLocation:touchPoint];
    [self setNeedsDisplay];
}

@end
