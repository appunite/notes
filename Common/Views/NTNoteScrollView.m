//
//  NTNoteScrollView.m
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteScrollView.h"

@implementation NTNoteScrollView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // set defaults
        _zoomEnabled = YES;
        
        // setup scroll view
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self setDecelerationRate:UIScrollViewDecelerationRateFast];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setMinimumZoomScale:1.0];
        [self setMaximumZoomScale:1.0f];
        [self setDelegate:self];
    }
    return self;
}


#pragma mark - UIScrollView Delegate

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self isZoomEnabled] ? _notesView : nil;
}


#pragma mark - Setters & getters

//////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)contentSize {
    return self.bounds.size;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setNotesView:(UIView *)notesView {
    // remove old view
    [_notesView removeFromSuperview];
    
    // assign view
    _notesView = notesView;
    
    // add view to super view
    [self addSubview:notesView];
    
    // setup new view
    [_notesView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    _notesView.frame = self.bounds;
}

@end


@implementation NTNoteScrollView (Zoom)

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)pointToCenterAfterRotation {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return [self convertPoint:boundsCenter toView:_notesView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)scaleToRestoreAfterRotation {
    CGFloat contentScale = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
        contentScale = 0;
    
    return contentScale;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale {
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
    
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:_notesView];
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

@end
