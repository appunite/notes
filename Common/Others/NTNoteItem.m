//
//  NTNoteItem.m
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteItem.h"

@implementation NTNoteItem

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        _rect = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
        _editingMode = NO;
        _zPosition = 0;
    }
    return self;
}

@end
