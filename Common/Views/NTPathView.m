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

- (id)initWithItem:(NTNoteItem *)item {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.item = item;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
          // get current context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        // draw item
    CGFloat verticalScale = rect.size.height/self.item.rect.size.height;
    CGFloat horizontalScale = rect.size.width/self.item.rect.size.width;
    CGContextTranslateCTM(ctx, -self.item.rect.origin.x * horizontalScale, -self.item.rect.origin.y * verticalScale);
    CGContextScaleCTM(ctx, horizontalScale, verticalScale);
    
    [NTNotePathItem drawItem:self.item rect:rect context:ctx];

}

#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NTNotePathItem *)item {
    return (NTNotePathItem *)[super item];
}

@end
