//
//  NTNoteScrollView.h
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTNoteScrollView : UIScrollView <UIScrollViewDelegate>

// keep zoomed view
@property (nonatomic, strong) UIView* notesView;

// default YES, default max zoom sacale 3.0f
@property (nonatomic, assign, getter = isZoomEnabled) BOOL zoomEnabled;
@end


@interface NTNoteScrollView (Zoom)

/*
 * Return rect with chosen scale and center point
 */
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center;

/*
 * Return center point of tiled view
 */
- (CGPoint)pointToCenterAfterRotation;

/*
 * Returns the zoom scale to attempt to restore after rotation.
 */
- (CGFloat)scaleToRestoreAfterRotation;

/*
 * Adjusts content offset and scale to try to preserve the old zoomscale and center
 */
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;

@end
