//
//  NTTextView.h
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>

//Views
#import "NTUserResizableView.h"

//Items
#import "NTNoteTextItem.h"

@class NTTextView;

@protocol NTTextViewDelegate <NSObject>
- (void)textViewDelegate:(NTUserResizableView*)textView requestedRefreshingFrameOfItem:(NTNoteTextItem*)item;
- (void)textViewDelegate:(NTUserResizableView*)textView requestedEndEditionOfItem:(NTNoteTextItem*)item;
@end


@interface NTTextView : NTUserResizableView<UITextViewDelegate>{
    UITextView *_textView;
}

// redefine model object
- (NTNoteTextItem*)item;
-(void)allowUserTextEditing;
-(void)updateTextView;
-(void)selectAll:(id)sender;
-(void)recalculateFrame;
-(NSString*)getText;

@property (nonatomic, assign) CGRect maxRect;
@property (nonatomic, weak) id noteViewDelegate;

@end
