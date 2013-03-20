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
       
    if(_textView){
    CGContextClearRect(ctx, rect);
    }
    else{
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

-(void)updateTextView{
    // this method is called when user changes some text parameters, UITextView should reload
    [_textView setTextColor:[self.item color]];
    [_textView setFont:[self.item font]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)allowUserTextEditing{
    
    //clear context
    [self setNeedsDisplay];
    
    //init UITextView with parameters as item properties
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.item.rect.size.width, self.item.rect.size.height)];
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
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    // set item text from UITextView
    [self.item setText:_textView.text];
    
    // remove TextView
    [_textView removeFromSuperview];
    
    // Draw context with new text
    [self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectAll:(id)sender {
    [_textView selectAll:sender];
}

@end
