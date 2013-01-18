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

@interface NTNoteViewController : UIViewController <NTNoteContentViewDelegate>

// keep all drawing item objects
@property (nonatomic, strong) NSMutableArray* items;

// load JSON file and fill items array
- (BOOL)loadNoteItemsFromFile:(NSString *)file error:(NSError **)error;
@end
