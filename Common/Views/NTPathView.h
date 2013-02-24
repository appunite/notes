//
//  NTPathView.h
//  Notes
//
//  Created by Piotr Bernad on 16.02.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTUserResizableView.h"

//Items
#import "NTNoteTextItem.h"

// Model
#import "NTNotePathItem.h"


@interface NTPathView : NTUserResizableView
- (NTNotePathItem*)item;
@end
