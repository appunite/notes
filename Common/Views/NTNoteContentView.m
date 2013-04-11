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

static const CGFloat kInsetBox = 20.0f;

@implementation NTNoteContentView{
    // points used for drawing mode
    CGPoint _currentPoint;
    CGPoint _previousPoint1;
    CGPoint _previousPoint2;
    
}


CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    if(_noteContentMode == NTNoteContentModeDrawing){

        _currentNotePathItem = [_delegate requestNewNotePathItem];
        
        UITouch *touch = [touches anyObject];
        
        _previousPoint1 = [touch previousLocationInView:self];
        _previousPoint2 = [touch previousLocationInView:self];
        _currentPoint = [touch locationInView:self];
        
        [self touchesMoved:touches withEvent:event];
    } else if ([_delegate respondsToSelector:@selector(touchesBegan:withEvent:)]) {
        [_delegate performSelector:@selector(touchesBegan:withEvent:) withObject:touches withObject:event];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_noteContentMode != NTNoteContentModeDrawing && ([_delegate respondsToSelector:@selector(touchesMoved:withEvent:)])) {
        [_delegate performSelector:@selector(touchesMoved:withEvent:) withObject:touches withObject:event];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    /* check if the point is farther than min dist from previous */
    CGFloat dx = point.x - _currentPoint.x;
    CGFloat dy = point.y - _currentPoint.y;
    
    if ((dx * dx + dy * dy) < kPointMinDistanceSquared) {
        return;
    }
    
    
    _previousPoint2 = _previousPoint1;
    _previousPoint1 = [touch previousLocationInView:self];
    _currentPoint = [touch locationInView:self];
    
    CGPoint mid1 = midPoint(_previousPoint1, _previousPoint2);
    CGPoint mid2 = midPoint(_currentPoint, _previousPoint1);
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, _previousPoint1.x, _previousPoint1.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
    
    CGPathAddPath(_currentNotePathItem.path, NULL, subpath);
    CGPathRelease(subpath);
    
    CGRect drawBox = bounds;
    drawBox.origin.x -= _currentNotePathItem.lineWidth * 2.0;
    drawBox.origin.y -= _currentNotePathItem.lineWidth * 2.0;
    drawBox.size.width += _currentNotePathItem.lineWidth * 4.0;
    drawBox.size.height += _currentNotePathItem.lineWidth * 4.0;
    
    [self setNeedsDisplayInRect:drawBox];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (_noteContentMode != NTNoteContentModeDrawing && ([_delegate respondsToSelector:@selector(touchesEnded:withEvent:)])) {
        [_delegate performSelector:@selector(touchesEnded:withEvent:) withObject:touches withObject:event];
        return;
    }
  
    // get rect from current note path
    CGRect rect = CGPathGetBoundingBox(_currentNotePathItem.path);

    // save rect to item
    [_currentNotePathItem setRect:CGRectInset(rect, -kInsetBox, -kInsetBox)];
    
    // save content view state
    [_delegate saveCurrentNoteItemPath];
}



@end
