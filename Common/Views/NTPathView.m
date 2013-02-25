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
- (void)drawRect:(CGRect)rect {
          // get current context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        // draw item
    _verticalScale = rect.size.height/self.item.rect.size.height;
    _horizontalScale = rect.size.width/self.item.rect.size.width;
    CGContextTranslateCTM(ctx, -self.item.rect.origin.x * _horizontalScale, -self.item.rect.origin.y * _verticalScale);
    CGContextScaleCTM(ctx, _horizontalScale, _verticalScale);

   
    [NTNotePathItem drawItem:self.item rect:rect context:ctx];
   
}
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView{
   
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(_horizontalScale, _verticalScale);
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(-CGRectGetMidX(self.frame), -CGRectGetMidY(self.frame));
    CGAffineTransform finalTransform = CGAffineTransformConcat(scaleTransform, translateTransform);

    CGPathRef newPath = CGPathCreateMutableCopyByTransformingPath(self.item.path, &finalTransform);
    
    self.item.path = newPath;
    [self.item setRect:userResizableView.frame];
    
}
#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NTNotePathItem *)item {
    return (NTNotePathItem *)[super item];
}

@end
