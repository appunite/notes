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
    self = [super initWithFrame:CGRectZero viewIsResizable:NO showDotsOnEdit:NO showFrameOnEdit:YES];
    if (self) {
        self.minHeight = 180.0f;
        self.minWidth = 180.0f;
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"deleteNoteButton"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_deleteButton setFrame:CGRectMake(-10, -15, 26.0f, 30.0f)];
    [self bringSubviewToFront:_deleteButton];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
    if (_item) {
        CGRect rect = [_item rect];
        
        self.frame = rect;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    [super resizeUsingTouchLocation:touchPoint];
    [self setNeedsDisplay];
}

#pragma mark - Touches

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"cancelled");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"began");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"ended");
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
    [_resizableViewDelegate viewDidChangePosition:self.frame];
}

#pragma mark - Actions

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteTapped:(id)sender {
    [self.interactionDelegate deleteItem:self.item];
}

@end
