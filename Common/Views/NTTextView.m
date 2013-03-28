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
       
    if(_textView) {
        CGContextClearRect(ctx, rect);
    } else {
        // draw note item
        [NTNoteTextItem drawItem:[self item] rect:rect context:ctx color:[self.item color] font:[self.item font]];
    }
}


#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NTNoteTextItem *)item {
    return (NTNoteTextItem *)[super item];
}

#pragma mark - Text Editing

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateTextView{
    // this method is called when user changes some text parameters, UITextView should reload
    [_textView setTextColor:[self.item color]];
    [_textView setFont:[self.item font]];
    [self recalculateFrame];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)allowUserTextEditing{
    
    //clear context
    [self setNeedsDisplay];
    
    //init UITextView with parameters as item properties
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.item.rect.size.width - 5.0f, self.item.rect.size.height - 5.0f)];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setTextColor:[self.item color]];
    [_textView setFont:[self.item font]];
    [_textView setText:[self.item text]];
    [_textView setDelegate:self];
    [self addSubview:_textView];
    
    //send UITextView to back to allow view resizing and moving
    [self sendSubviewToBack:_textView];
    
    //show keyboard
    [_textView becomeFirstResponder];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)recalculateFrame {
    // get frame - consider minimal
    CGRect frame = _textView.frame;
    frame.size.height = ([_textView contentSize].height < 50.0f) ? 50.0f : [_textView contentSize].height;
    frame.size.width = [_textView.text sizeWithFont:_textView.font constrainedToSize:CGSizeMake(CGRectGetWidth(_maxRect), CGRectGetHeight(_maxRect))].width + 30.0f;
    if (CGRectGetWidth(frame) < 80.0f) {
        frame.size.width = 80.0f;
    }
    CGRect oldFrame = self.item.rect;
    
    // don't allow for: out of bounds
    if (CGRectGetMaxX(_maxRect) < CGRectGetMaxX(oldFrame)) { // width
        frame.size.width = CGRectGetMaxX(_maxRect) - CGRectGetMinX(oldFrame);
    }
    if (CGRectGetMaxY(_maxRect) < CGRectGetMaxY(oldFrame)) { // height
        frame.size.height = CGRectGetMaxY(_maxRect) - CGRectGetMinY(oldFrame);
    }
    
    // change frame on view
    _textView.frame = frame;
    
    // change frame of item
    [self.item setRect:CGRectMake(CGRectGetMinX(oldFrame), CGRectGetMinY(oldFrame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    
    // change frame border
    if ([_noteViewDelegate respondsToSelector:@selector(textViewDelegate:requestedRefreshingFrameOfItem:)]) {
        [_noteViewDelegate textViewDelegate:self requestedRefreshingFrameOfItem:self.item];
    }
}

#pragma mark - UITextView delegate

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChange:(UITextView *)textView {
    [self recalculateFrame];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    // set item text from UITextView
    [self.item setText:_textView.text];
    
    // remove TextView
    [_textView removeFromSuperview];
    
    // Draw context with new text
    [self setNeedsDisplay];
}

#pragma mark - TextView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectAll:(id)sender {
    [_textView selectAll:sender];
}

@end
