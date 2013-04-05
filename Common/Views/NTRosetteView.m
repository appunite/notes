//
//  NTRosetteView.m
//  Notes
//
//  Created by Piotrek on 05.04.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTRosetteView.h"

#define kOnImageName @"audio_note_image"

@implementation NTRosetteView

- (void)addLeaves {
    [super addLeaves];
    
    [_leavesLayers enumerateObjectsUsingBlock:^(CALayer * layer, NSUInteger idx, BOOL *stop) {
        [layer setShadowColor:[UIColor blackColor].CGColor];
        [layer setShadowRadius:5.0];
        [layer setShadowOffset:CGSizeMake(1, 1)];
        [layer setShadowOpacity:1.0];
    }];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [super setOn:on animated:animated];
    [self.wheelButton setImage:[UIImage imageNamed:kOnImageName] forState:UIControlStateNormal];
    [self.wheelButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.wheelButton.layer setShadowRadius:5.0];
    [self.wheelButton.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.wheelButton.layer setShadowOpacity:1.0];
}

- (void)updateImageAtIndex:(NSUInteger)index image:(UIImage *)image pulse:(BOOL)pulse {
    
    CALayer * layer = [_imagesLayers objectAtIndex:index];
    [layer setContents:image.CGImage];
    
    if (pulse) {
        
        [layer setShadowColor:[UIColor redColor].CGColor];
        [layer setShadowOffset:CGSizeMake(0, 0)];
        [layer setShadowOpacity:1.0];
        
        CABasicAnimation *shadowGrow = [CABasicAnimation animationWithKeyPath:@"shadowRadius" ];
        shadowGrow.delegate = self;
        [shadowGrow setFromValue:[NSNumber numberWithFloat:2.0]];
        [shadowGrow setToValue:[NSNumber numberWithFloat:8.0]];
        [shadowGrow setDuration:1.0f];
        shadowGrow.repeatCount = CGFLOAT_MAX;
        shadowGrow.autoreverses = YES;

        [layer addAnimation:shadowGrow forKey:@"shadowRadius"];
    } else {
        [layer setShadowOpacity:0.0];
        [layer removeAnimationForKey:@"shadowRadius"];
    }
}

- (void)updateImageAtIndex:(NSUInteger)index image:(UIImage*)image {
    [self updateImageAtIndex:index image:image pulse:NO];
}

@end
