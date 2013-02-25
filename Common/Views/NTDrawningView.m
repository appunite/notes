//
//  NTDrawningView.m
//  Notes
//
//  Created by Piotr Bernad on 24.02.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTDrawningView.h"

@implementation NTDrawningView{
    // points used for drawing mode
    CGPoint _currentPoint;
    CGPoint _previousPoint1;
    CGPoint _previousPoint2;
    
}
static const CGFloat kPointMinDistance = 5;
static const CGFloat kPointMinDistanceSquared = 10;

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (id)initWithItem:(NTNotePathItem *)item{
    _item = item;
    self = [super initWithFrame:_item.rect];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

        UITouch *touch = [touches anyObject];
        
        _previousPoint1 = [touch previousLocationInView:self];
        _previousPoint2 = [touch previousLocationInView:self];
        _currentPoint = [touch locationInView:self];
        
        [self touchesMoved:touches withEvent:event];

}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    
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
        
        CGPathAddPath(_item.path, NULL, subpath);
        CGPathRelease(subpath);
        
        CGRect drawBox = bounds;
        drawBox.origin.x -= _item.lineWidth * 2.0;
        drawBox.origin.y -= _item.lineWidth * 2.0;
        drawBox.size.width += _item.lineWidth * 4.0;
        drawBox.size.height += _item.lineWidth * 4.0;
        
        [self setNeedsDisplayInRect:drawBox];
    
}
- (void)drawRect:(CGRect)rect {
    // get current context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // change background color
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, rect);
    
    // draw item
    [NTNotePathItem drawItem:_item rect:rect context:ctx];
    
    CGRect itemRect = CGPathGetBoundingBox(_item.path);
    [_item setRect:itemRect];
    
}
@end
