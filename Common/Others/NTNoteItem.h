//
//  NTNoteItem.h
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTNoteItem : NSObject

// rect of item
@property (nonatomic, assign) CGRect rect;

// Z-axis position
@property (nonatomic, assign) NSUInteger zPosition;

// unique identifier of item
@property (nonatomic, strong) NSString* uid;

// additional dict of options
@property (nonatomic, strong) NSDictionary* options;

// YES if view containig item is in editing mode
@property (nonatomic, assign) BOOL editingMode;
@end
