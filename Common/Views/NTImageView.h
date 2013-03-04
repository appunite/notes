//
//  NTImageView.h
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>

//Views
#import "NTUserResizableView.h"

//Items
#import "NTNoteImageItem.h"

@interface NTImageView : NTUserResizableView

// redefine model object
- (NTNoteImageItem *)item;
@end
