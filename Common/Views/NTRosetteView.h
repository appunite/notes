//
//  NTRosetteView.h
//  Notes
//
//  Created by Piotrek on 05.04.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "AURosetteView.h"

@interface NTRosetteView : AURosetteView
- (void)updateImageAtIndex:(NSUInteger)index image:(UIImage*)image;
- (void)updateImageAtIndex:(NSUInteger)index image:(UIImage *)image pulse:(BOOL)pulse;
@end
