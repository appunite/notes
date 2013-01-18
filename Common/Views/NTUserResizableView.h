//
//  NTUserResizableView.h
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "SPUserResizableView.h"

//Items
#import "NTNoteItem.h"

@interface NTUserResizableView : SPUserResizableView
// keep model object
@property (nonatomic, weak, readonly) NTNoteItem* item;

- (id)initWithItem:(NTNoteItem *)item;
@end
