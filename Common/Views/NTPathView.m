//
//  NTPathView.m
//  Notes
//
//  Created by Piotr Bernad on 16.02.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTPathView.h"
#import "NTNotePathItem.h"


static const CGFloat kPointMinDistance = 5;
static const CGFloat kPointMinDistanceSquared = 10;

@implementation NTPathView

- (id)initWithItem:(NTNotePathItem *)item {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.item = item;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setDelegate:self];
    }
    return self;
}

- (NTNotePathItem *)noteItem {
    return (NTNotePathItem *) self.item;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NTNotePathItem *item = self.noteItem;

    CGContextSaveGState(ctx);
    CGAffineTransform transform = [self getAffineTransformForRect:self.frame];
    CGContextTranslateCTM(ctx, -self.frame.origin.x , -self.frame.origin.y);
    CGContextConcatCTM(ctx, transform);
    
   
    [NTNotePathItem drawItem:item rect:rect context:ctx];
    
    CGContextRestoreGState(ctx);
   
}
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView{
    _previousFrame = userResizableView.frame;
}

- (CGAffineTransform) getAffineTransformForRect: (CGRect) rect {
    
    NTNotePathItem *item = self.noteItem;
    CGRect itemRect = item.rect;
    
    float sx = rect.size.width / itemRect.size.width;
    float sy = rect.size.height / itemRect.size.height;
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    translateTransform = CGAffineTransformTranslate(translateTransform, rect.origin.x, rect.origin.y );

    translateTransform = CGAffineTransformScale(translateTransform, sx, sy);
    translateTransform = CGAffineTransformTranslate(translateTransform, -itemRect.origin.x, -itemRect.origin.y);
    return translateTransform;
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView{
    CGRect nextFrame = userResizableView.frame;
    CGAffineTransform transform = [self getAffineTransformForRect:nextFrame];
    
    NTNotePathItem *item = self.noteItem;

    CGPathRef newPath = CGPathCreateMutableCopyByTransformingPath(item.path, &transform);
    CGMutablePathRef mutable = CGPathCreateMutableCopy(newPath);
    CGPathRelease(newPath);
    CGPathRelease(item.path);

    item.path = mutable;
    CGRect rect = CGPathGetBoundingBox(mutable);
    [item setRect:rect];
    [self setFrame:rect];
    
}


@end
