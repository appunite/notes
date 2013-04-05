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

//Protocols
#import "NTInteractionDelegate.h"

@protocol NTUserResizableViewDelegate <NSObject>
-(void)viewDidChangePosition:(CGRect)frame;
@end

@interface NTUserResizableView : SPUserResizableView{
    UIButton *_deleteButton;
}
// keep model object
@property (nonatomic, weak) NTNoteItem* item;
@property (weak) id<NTUserResizableViewDelegate> resizableViewDelegate;
@property id <NTInteractionDelegate> interactionDelegate;
- (id)initWithItem:(NTNoteItem *)item;
- (void)addDeleteButton;
@end
