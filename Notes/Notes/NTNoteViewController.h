//
//  NTNoteViewController.h
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <UIKit/UIKit.h>

//Views
#import "NTNoteContentView.h"
#import "NTUserResizableView.h"

@interface NTNoteViewController : UIViewController <NTNoteContentViewDelegate, NTUserResizableViewDelegate>

// keep all drawing item objects
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic) CGRect contentViewFrame;
// load JSON file and fill items array
- (BOOL)loadNoteItemsFromFile:(NSString *)file error:(NSError **)error;
// init with scroll view frame
-(id)initWithContentViewFrame:(CGRect)frame;

@end
