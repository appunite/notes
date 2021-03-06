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
#import "NTTextView.h"
#import "NTNoteAudioView.h"

@protocol NTNoteDelegate <NSObject>

-(void)editingModeIsOn;
-(NSDictionary *)getBrushAtributes;
-(void)willDeleteNoteItem:(NTNoteItem *)noteItem;
-(void)willUpdateNoteItem:(NTNoteItem *)noteItem;

@end

@protocol NTTextViewDelegate;

@interface NTNoteViewController : UIViewController <NTNoteContentViewDelegate, NTUserResizableViewDelegate, NTInteractionDelegate, NTTextViewDelegate, NoteAudioViewDelegate> {
    UIView * _draggedItem;
    NSData * _fileContents;
}

// keep all drawing item objects
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic) CGRect contentViewFrame;
@property (nonatomic, strong) NTUserResizableView *currentNoteView;
@property id <NTNoteDelegate> delegate;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSData *fileContents;
@property (nonatomic, assign) BOOL automaticStop;
@property (nonatomic, assign) NSTimeInterval automaticStopInterval;

// setFilePath
- (void)setFilePath:(NSString *)filePath saveCurrent:(BOOL)saveCurrent;
// load JSON file and fill items array
- (BOOL)loadNoteItemsFromFile:(NSString *)file error:(NSError **)error;
// init with scroll view frame
-(id)initWithContentViewFrame:(CGRect)frame;

/** If frame is CGRectZero, new textNote is saved to default frame **/
-(void)requestNewNoteTextItemWithFrame:(CGRect)frame selectText:(BOOL)selectText;
-(void)updateCurrentNoteView;
-(void)requestNewNoteImageItemWithPath:(NSString *)path;
-(void)requestNewNoteAudioItem;
-(void)setContentViewMode:(NSUInteger)mode;
-(void)deleteCurrentPath;
-(void)clearContent;
-(void)saveNoteItems;
-(NSArray*)textNotesArray;

// Flags getters
-(BOOL)hasPicture;
-(BOOL)hasSound;
-(BOOL)hasCalendar;

@end
