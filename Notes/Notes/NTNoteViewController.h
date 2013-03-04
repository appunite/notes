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

//temp
#import "NTTextView.h"

@protocol NTNoteDelegate

-(void)editingModeIsOn;
-(NSDictionary *)getBrushAtributes;
@end

@interface NTNoteViewController : UIViewController <NTNoteContentViewDelegate, NTUserResizableViewDelegate, NTInteractionDelegate>

// keep all drawing item objects
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic) CGRect contentViewFrame;
@property (nonatomic, strong) NTUserResizableView *currentNoteView;
@property id <NTNoteDelegate> delegate;
@property (strong, nonatomic) NSString *filePath;

// load JSON file and fill items array
- (BOOL)loadNoteItemsFromFile:(NSString *)file error:(NSError **)error;
// init with scroll view frame
-(id)initWithContentViewFrame:(CGRect)frame;

-(void)updateCurrentNoteView;
-(void)requestNewNoteImageItemWithPath:(NSString *)path;
-(void)requestNewNoteTextItem;
-(void)requestNewNoteAudioItem;
-(void)setContentViewMode:(NSUInteger)mode;
-(void)deleteCurrentPath;

// Flags getters
-(BOOL)hasPicture;
-(BOOL)hasSound;
-(BOOL)hasCalendar;

@end
