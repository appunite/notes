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

@protocol NTUserResizableViewDelegate <NSObject>

-(void)viewDidChangePosition:(CGRect)frame;

@end

@interface NTUserResizableView : SPUserResizableView
// keep model object
@property (nonatomic, weak) NTNoteItem* item;
@property id<NTUserResizableViewDelegate> resizableViewDelegate;
- (id)initWithItem:(NTNoteItem *)item;
@end
