//
//  NTNoteViewController.m
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteViewController.h"

//Views
#import "NTNoteScrollView.h"
#import "NTImageView.h"
#import "NTTextView.h"
#import "NTImageView.h"

//Items
#import "NTNoteTextItem.h"
#import "NTNoteImageItem.h"

@interface NTNoteViewController ()
//mapping items
- (void)mapNoteItems:(NSArray *)jsonItems;

// actions
- (void)tapGestureAction:(UITapGestureRecognizer *)gestureRecognizer;

// editing
- (void)enterEditModeOfItem:(NTNoteItem *)item;
- (void)exitEditMode;
@end

@implementation NTNoteViewController {
    // Views
    __weak NTNoteContentView* _contentView;
    NTUserResizableView* _currentNoteView;

    // Gestures
    UITapGestureRecognizer* _tapGestureRecognizer;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        // create items mutable array
        _items = [NSMutableArray new];
        
        // create tap gestire recognizer, attached to note content view
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(tapGestureAction:)];

    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    // get application frame
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    // create main view
    NTNoteScrollView* view = [[NTNoteScrollView alloc] initWithFrame:rect];
    
    // create main note view (take care of drawings)
    NTNoteContentView* contentView = [[NTNoteContentView alloc] init];
    [contentView setDelegate:self];
    
    // add notes view
    [view setNotesView:contentView];

    // add tap gesture recognizer to content view
    [contentView addGestureRecognizer:_tapGestureRecognizer];
    
    // save weak referance
    _contentView = contentView;

    // assign controller's view
    self.view = view;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NTImageView* view = [[NTImageView alloc] initWithFrame:CGRectMake(40, 40, 420, 360)];
//    [_noteView addSubview:view];
    
    NSError* error = nil;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    [self loadNoteItemsFromFile:path error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
}


#pragma mark - Class methods

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadNoteItemsFromFile:(NSString *)file error:(NSError **)error {

    // load data from file
    NSData* data = [[NSData alloc] initWithContentsOfFile:file options:NSDataReadingUncached error:error];
    
    // exit, problem with loading data
//    if (!data || error) {
//        return NO;
//    }

    // serialize JSON
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
    // exit, problem with JSON serialization
//    if (!json || error) {
//        return  NO;
//    }
    
    // get items array
    NSArray* elements = [json objectForKey:@"elements"];
    
    // map notes
    [self mapNoteItems:elements];
    
    return YES;
}


#pragma mark - NTNoteContentView Delegate

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)noteItemsForRect:(CGRect)rect {
    return _items;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NTNotePathItem*)requestNewNotePathItem {
    // create new path item
    NTNotePathItem* item = [[NTNotePathItem alloc] init];
    // add to list
    [_items addObject:item];
    
    return item;
}

#pragma mark - Private

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapNoteItems:(NSArray *)jsonItems {

    // iterate all items
    for (NSDictionary* item in jsonItems) {
        
        // get type of item
        NSString* type = [item objectForKey:@"type"];
        
        // get origin
        CGFloat x = [[item objectForKey:@"x"] floatValue];
        CGFloat y = [[item objectForKey:@"y"] floatValue];

        // create image note item
        if ([type isEqualToString:@"image"]) {
            NTNoteImageItem* image = [[NTNoteImageItem alloc] init];
            
            // get height
            CGFloat width = [[item objectForKey:@"width"] floatValue];
            CGFloat height = [[item objectForKey:@"height"] floatValue];
            
            // change frame
            CGRect rect = CGRectMake(x, y, width, height);
            [image setRect:rect];

            // change resource path
            NSString* url = [item objectForKey:@"url"];
            [image setResourcePath:url];
            
            // add item to array
            [_items addObject:image];
        }
        
        // create text note item
        else if ([type isEqualToString:@"html"]) {
            NTNoteTextItem* text = [[NTNoteTextItem alloc] init];
                        
            // get height
            CGFloat width = [[item objectForKey:@"width"] floatValue];
            CGFloat height = [[item objectForKey:@"height"] floatValue];
            
            // change frame
            CGRect rect = CGRectMake(x, y, width, height);
            [text setRect:rect];

            // change resource path
            NSString* html = [item objectForKey:@"html"];
            [text setText:html];

            // change font name and size
            NSString* fontName = [item objectForKey:@"font"];
            CGFloat size = [[item objectForKey:@"size"] floatValue];
            [text setFont:[UIFont fontWithName:fontName size:size]];
            
            // add item to array
            [_items addObject:text];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)enterEditModeOfItem:(NTNoteItem *)item {
    // exit editing mode
    [self exitEditMode];

    if ([item isKindOfClass:[NTNoteTextItem class]]) {

        // create text item view
        _currentNoteView = [[NTTextView alloc] initWithItem:item];
    }
    
    else if ([item isKindOfClass:[NTNoteImageItem class]]) {

        // create image item view
        _currentNoteView = [[NTImageView alloc] initWithItem:item];
    }

    // move to editing mode
    [item setEditingMode:YES];
    
    // show blue dots
    [_currentNoteView showEditingHandles];

    // add subview
    [_contentView addSubview:_currentNoteView];
    [_contentView setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)exitEditMode {

    // exit editing mode
    [[_currentNoteView item] setEditingMode:NO];

    // hide blue dots
    [_currentNoteView hideEditingHandles];
    
    // remove view
    [_currentNoteView removeFromSuperview];
    _currentNoteView = nil;

    // redraw view
    [_contentView setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tapGestureAction:(UITapGestureRecognizer *)gestureRecognizer {
    // get touch point
    CGPoint point = [gestureRecognizer locationInView:_contentView];
    
    // enumerate all items
    [_items enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NTNoteItem* item, NSUInteger idx, BOOL *stop) {

        // check if rect of item contain touch point
        if (!item.editingMode &&  CGRectContainsPoint(item.rect, point)) {

            // enter editimg mode with selected item
            [self enterEditModeOfItem:item];

            // yeap, we found
            *stop = YES;
        }
        
        // if last object
        else if (idx == [_items count] -1) {

            // egit edit mode
            [self exitEditMode];
        }
    }];
}

@end
