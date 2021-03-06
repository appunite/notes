//
//  NTNoteContentView.h
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <UIKit/UIKit.h>

//Items
#import "NTNoteTextItem.h"
#import "NTNoteImageItem.h"
#import "NTNotePathItem.h"
#import "NTNoteAudioItem.h"
#import "NTPathView.h"
//#import "NTDrawningView.h"

typedef NS_ENUM(NSUInteger, NTNoteContentMode) {
    NTNoteContentModeDrawing    = 0,
    NTNoteContentModeScrolling  = 1
};

@protocol NTNoteContentViewDelegate;

@interface NTNoteContentView : UIView<NTUserResizableViewDelegate>

// keep current content mode
@property (nonatomic, assign) NTNoteContentMode noteContentMode;

// note items delegate object
@property (nonatomic, weak) id<NTNoteContentViewDelegate> delegate;

//@property (nonatomic, strong) NTDrawningView *currentDrawningView;
@property (nonatomic, strong) NTNotePathItem *currentNotePathItem;
@end


@protocol NTNoteContentViewDelegate <NSObject>
// get items to draw
- (NSArray *)noteItemsForRect:(CGRect)rect;
// request for new path item
- (NTNotePathItem*)requestNewNotePathItem;
// save ContentView State
-(void)saveCurrentNoteItemPath;

// user requested delete of media
- (void) willDeleteNoteItem:(NTNoteItem *)item;
@end