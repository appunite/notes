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
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized)];
        [self addGestureRecognizer:_longPressGestureRecognizer];

    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.minHeight = 180.0f;
        self.minWidth = 180.0f;
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized)];
        [self addGestureRecognizer:_longPressGestureRecognizer];

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
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
    [_resizableViewDelegate viewDidChangePosition:self.frame];
}
#pragma mark - long press

-(void)longPressRecognized{
    
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25.0f, 30.0f)];
    [_deleteButton setImage:[UIImage imageNamed:@"deleteNoteButton"] forState:UIControlStateNormal];
    [_deleteButton setBackgroundColor:[UIColor clearColor]];
    [_deleteButton setCenter:CGPointMake(CGRectGetWidth(self.frame)-10.0f, 8.0f)];
    [_deleteButton addTarget:self action:@selector(deleteTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
    [self bringSubviewToFront:_deleteButton];
    
}
-(void)deleteTapped{
    [self.interactionDelegate deleteItem:self.item];
}
@end
