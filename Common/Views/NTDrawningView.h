//
//  NTDrawningView.h
//  Notes
//
//  Created by Piotr Bernad on 24.02.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>
// Model
#import "NTNotePathItem.h"
@interface NTDrawningView : UIView
@property (strong, nonatomic) NTNotePathItem* item;
- (id)initWithItem:(NTNotePathItem *)item;
@end
