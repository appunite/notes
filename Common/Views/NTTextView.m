//
//  NTTextView.m
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTTextView.h"

@implementation NTTextView {
    CGPoint _textViewOffset;
}

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
- (void)dealloc {
    // remove TextView
    [_textView removeFromSuperview];
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
- (void)updateTextView {
    // this method is called when user changes some text parameters, UITextView should reload
    [_textView setTextColor:[self.item color]];
    [_textView setFont:[self.item font]];
    [self recalculateFrame];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)allowUserTextEditing {
    //clear context
    [self setNeedsDisplay];
    
    //init UITextView with parameters as item properties
    _textViewOffset = CGPointMake(-4, -4);
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(_textViewOffset.x, _textViewOffset.y, self.item.rect.size.width, self.item.rect.size.height)];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setTextColor:[self.item color]];
    [_textView setFont:[self.item font]];
    [_textView setText:[self.item text]];
    [_textView setDelegate:self];
    [_textView setScrollEnabled:NO];
    [self addSubview:_textView];
    
#warning problem here - if we sendBack - cannot move; otherwise - cannot select text
//    [self sendSubviewToBack:_textView];
    
    //show keyboard
    [_textView becomeFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)getText {
    return _textView.text;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)recalculateFrame {
    _textView.contentOffset = CGPointZero;
    
    // get frame - consider minimal
    CGRect textFrame = _textView.frame;
    CGRect itemFrame = self.item.rect;
    
    // don't allow for: too small size
    textFrame.size.height = ([_textView contentSize].height < 50.0f) ? 50.0f : [_textView contentSize].height;
    textFrame.size.width = [_textView.text sizeWithFont:_textView.font constrainedToSize:CGSizeMake(CGRectGetWidth(_maxRect), CGRectGetHeight(_maxRect))].width + 30.0f;
    if (CGRectGetWidth(textFrame) < 80.0f) {
        textFrame.size.width = 80.0f;
    }
    
    // don't allow for: out of bounds
    if ((CGRectGetMaxX(_maxRect) - 5.0f) < CGRectGetMaxX(itemFrame)) { // width
        textFrame.size.width = CGRectGetMaxX(_maxRect) - CGRectGetMinX(itemFrame);
    }
    if ((CGRectGetMaxY(_maxRect) - 5.0f) < (CGRectGetMinY(itemFrame) + CGRectGetHeight(textFrame))) { // height
        textFrame.size.height = CGRectGetMaxY(_maxRect) - CGRectGetMinY(itemFrame);
    }
    
    // change frame on view & item
    _textView.frame = textFrame;
    [self.item setRect:CGRectMake(CGRectGetMinX(itemFrame), CGRectGetMinY(itemFrame), CGRectGetWidth(textFrame), CGRectGetHeight(textFrame))];
    
    // change frame border
    if ([_noteViewDelegate respondsToSelector:@selector(textViewDelegate:requestedRefreshingFrameOfItem:)]) {
        [_noteViewDelegate textViewDelegate:self requestedRefreshingFrameOfItem:self.item];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)resignFirstResponder {
    [_textView resignFirstResponder];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFirstResponder {
    return [_textView isFirstResponder];
}


#pragma mark - UITextView delegate

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChange:(UITextView *)textView {
    [self recalculateFrame];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
    
    // set item text from UITextView
    [self.item setText:_textView.text];
    
    // remove other things like frame etc
    if ([_noteViewDelegate respondsToSelector:@selector(textViewDelegate:requestedEndEditionOfItem:)]) {
        [_noteViewDelegate textViewDelegate:self requestedEndEditionOfItem:self.item];
    }
    
    // Draw context with new text
    [self setNeedsDisplay];
}


#pragma mark - TextView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectAll:(id)sender {
    [_textView selectAll:sender];
}


@end
