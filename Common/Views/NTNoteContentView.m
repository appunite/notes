//
//  NTNoteContentView.m
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteContentView.h"

//Views
#import "NTTextView.h"
#import "NTImageView.h"

static const CGFloat kPointMinDistance = 5;
static const CGFloat kPointMinDistanceSquared = 10;

@implementation NTNoteContentView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    return [self initWithFrame:CGRectZero];
    [self setBackgroundColor:[UIColor clearColor]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _noteContentMode = NTNoteContentModeScrolling;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
    NSArray* items = nil;
    
    // load items array
    if ([_delegate respondsToSelector:@selector(noteItemsForRect:)]) {
        items = [_delegate noteItemsForRect:rect];
    }
    
    // if has any items
    if ([items count] > 0) {
        // get current context
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // change background color
        CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
        CGContextFillRect(ctx, rect);
        
        // iterate all items
        for (id item in items) {
            
            // do not draw edited views
            if ([item editingMode]) continue;
            
            // save context state
            CGContextSaveGState(ctx);
            
            // draw text item
            if ([item isKindOfClass:[NTNoteTextItem class]]) {
                // get item rect
                CGRect rect = [item rect];
                
                // draw item
                [NTNoteTextItem drawItem:item rect:rect context:ctx color:[item color] font:[item font]];
            }
            
            // draw image item
            else if ([item isKindOfClass:[NTNoteImageItem class]]) {
                // get item rect
                CGRect rect = [item rect];
                
                // draw item
                [NTNoteImageItem drawItem:item rect:rect context:ctx];
                
            }
            
            // draw path item
            else if ([item isKindOfClass:[NTNotePathItem class]]) {
                // get item rect
                CGRect rect = [item rect];
                
                // draw item
                [NTNotePathItem drawItem:item rect:rect context:ctx];
            }
            else if ([item isKindOfClass:[NTNoteAudioItem class]]) {
                // get item rect
                CGRect rect = [item rect];
                
                //draw item
                [NTNoteAudioItem drawItem:item rect:rect context:ctx];
            }
            
            
            // restore context state
            CGContextRestoreGState(ctx);
        }
    }

}

-(void)setNoteContentMode:(NTNoteContentMode)noteContentMode{
    _noteContentMode=noteContentMode;
    if(_noteContentMode == NTNoteContentModeDrawing){
        _currentNotePathItem = [_delegate requestNewNotePathItem];
        [_currentNotePathItem setRect:self.frame];
        _currentDrawningView = [[NTDrawningView alloc] initWithItem:_currentNotePathItem];
        [self addSubview:_currentDrawningView];
    }
    else
    {
        [_currentDrawningView removeFromSuperview];
        _currentDrawningView = nil;
    }
}



@end
