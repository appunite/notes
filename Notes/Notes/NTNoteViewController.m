//
//  NTNoteViewController.m
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteViewController.h"
#import <Foundation/Foundation.h>
//Views
#import "NTNoteScrollView.h"
#import "NTImageView.h"
#import "NTTextView.h"
#import "NTImageView.h"
#import "NTPathView.h"
#import "NTUserResizableView.h"

//Items
#import "NTNoteTextItem.h"
#import "NTNoteImageItem.h"

//Categories
#import "UIColor+Additions.h"
#import "NSString+Additions.h"

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
    // Gestures
    UITapGestureRecognizer* _tapGestureRecognizer;
    BOOL hasSound;
    BOOL hasPicture;
    BOOL hasCalendar;
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
- (void)setContentViewFrame:(CGRect)contentViewFrame {
    _contentViewFrame = contentViewFrame;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithContentViewFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        // create items mutable array
        _items = [NSMutableArray new];

        _contentViewFrame = frame;
        
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
    NTNoteScrollView* view = [[NTNoteScrollView alloc] initWithFrame:_contentViewFrame];
    [view setBackgroundColor:[UIColor clearColor]];
    // create main note view (take care of drawings)
    NTNoteContentView* contentView = [[NTNoteContentView alloc] initWithFrame:_contentViewFrame];
    [contentView setDelegate:self];
    [contentView setBackgroundColor:[UIColor clearColor]];
    // add notes view
    [view setNotesView:contentView];
    [view.notesView setBackgroundColor:[UIColor clearColor]];
    // add tap gesture recognizer to content view
    [contentView addGestureRecognizer:_tapGestureRecognizer];
    
    // save weak referance
    _contentView = contentView;

    // assign controller's view
    self.view = view;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFilePath:(NSString *)filePath {
    [self setFilePath:filePath saveCurrent:(_filePath && ![_filePath isEqualToString:@""])];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFilePath:(NSString *)filePath saveCurrent:(BOOL)saveCurrent {
    // if it is refresh not init
    if (saveCurrent) {
        // exit&save any edited file
        [self exitEditMode];
    }
    // remove old notes
    [_items removeAllObjects];
    // reload view
    [_contentView setNeedsDisplay];
    
    _filePath = filePath;
    NSError* error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentFilePath = [documentsDirectory stringByAppendingPathComponent:_filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentFilePath]) {
        [self loadNoteItemsFromFile:documentFilePath error:&error];
    }
    
    if (error) {
        NSLog(@"%@", error);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFileContents:(NSData *)fileContents {
    _fileContents = fileContents;
    
    NSError *error = nil;
    
    // serialize JSON
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:_fileContents options:0 error:&error];
    
    // exit, problem with JSON serialization
    //    if (!json || error) {
    //        return  NO;
    //    }
    
    // get items array
    NSArray* elements = [json objectForKey:@"elements"];
    
    // remove old items
    [_items removeAllObjects];
    
    // map notes
    [self mapNoteItems:elements];
    
    // reload view
    [_contentView setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData *)fileContents {
    [self exitEditMode];
    
    return _fileContents;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
    [self exitEditMode];
    
    [super viewWillDisappear:animated];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // reload content view
    [_contentView setNeedsDisplay];
}


#pragma mark - Class methods

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadNoteItemsFromFile:(NSString *)file error:(NSError **)error {

    // load data from file
    _fileContents = [[NSData alloc] initWithContentsOfFile:file options:NSDataReadingUncached error:error];

    // exit, problem with loading data
//    if (!data || error) {
//        NSLog(@"%@", error);
//        return NO;
//    }

    // serialize JSON
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.fileContents options:0 error:error];
    
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

    // Get Brush Atrributes from Delegate
    NSDictionary *brushAtr= [[NSDictionary alloc] initWithDictionary:[_delegate getBrushAtributes]];
    
    // create new path item
    NTNotePathItem* item = [[NTNotePathItem alloc] initWithBrushAttributes:brushAtr];

    // add to list
    [_items addObject:item];
    
    return item;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestNewNoteImageItemWithPath:(NSString *)path {
    
    NTNoteImageItem* image = [[NTNoteImageItem alloc] init];
    
    // get height
    CGFloat width = 200;
    CGFloat height = 200;
    
    // change frame
    CGRect rect = CGRectMake(10.0f, 10.0f, width, height);
    [image setRect:rect];
    
    // change resource path
    [image setLocalPath:path];
    
    // add item to array
    [_items addObject:image];

    // inform controller that photo was added
    [self updateDownloadableItem:image];
    
    // reload content view
    [_contentView setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestNewNoteTextItemWithFrame:(CGRect)frame selectText:(BOOL)selectText {
    
    NTNoteTextItem *item = [[NTNoteTextItem alloc] init];
    
    // set temporary text
    [item setText:@""];
    
    //set default font
    [item setFont:[UIFont systemFontOfSize:20]];
    
    // Set default color
    // Get Brush Atrributes from Delegate
    NSDictionary *brushAtr= [[NSDictionary alloc] initWithDictionary:[_delegate getBrushAtributes]];
    // Get color
    [item setColor:[brushAtr objectForKey:@"color"] ?: [UIColor blackColor]];
    
    // calculate rect
    CGRect rect;
    CGSize size = [item.text sizeWithFont:item.font constrainedToSize:CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    size.width += 30.0f; size.height += 30.0f;
    if (CGRectEqualToRect(frame, CGRectZero)) {
        rect = CGRectMake(5.0f, 10.0f, size.width, size.height);
    } else {
        rect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), size.width, size.height);
    }
    
    //set rect
    [item setRect:rect];
    
    // add item to array
    [_items addObject:item];
    
    // reload content view
    [_contentView setNeedsDisplay];
    
    // select item
    [self enterEditModeOfItem:item];
    // set frame to match text size
    [(NTTextView*)_currentNoteView recalculateFrame];
    // set frame to match lines
    [self viewDidChangePosition:rect];
    // select text
    if (selectText) [_currentNoteView selectAll:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestNewNoteAudioItem {
    
    NTNoteAudioItem *item = [[NTNoteAudioItem alloc] init];
    
    CGFloat width = 60.0f;
    CGFloat height = 60.0f;
    
    CGRect rect = CGRectMake(100.0f, 100.0f, width, height);
    
    [item setRect:rect];
    
    [_items addObject:item];
    
    [_contentView setNeedsDisplay];
    
    [self saveNoteItems];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteCurrentPath {
    if([_currentNoteView isKindOfClass:[NTPathView class]]){
        [_items removeObject:_currentNoteView.item];
        [self exitEditMode];
        [_contentView setNeedsDisplay];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)saveCurrentNoteItemPath{
    if (![[_contentView gestureRecognizers] containsObject:_tapGestureRecognizer]) {
        [_contentView addGestureRecognizer:_tapGestureRecognizer];
    }
    
    [self exitEditMode];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentViewMode:(NSUInteger)mode {
    [_contentView setNoteContentMode:mode];
    if (_currentNoteView != nil) {
        [_currentNoteView resignFirstResponder];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)clearContent {
    [_items removeAllObjects];
    [self exitEditMode];
    [_contentView setNeedsDisplay];
    [self saveNoteItems];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)textNotesArray {
    NSMutableArray *textNotes = [[NSMutableArray alloc] init];
    
    for(NTNoteItem *item in _items){
        if([item isKindOfClass:[NTNoteTextItem class]]) {
            NTNoteTextItem *itemt = (NTNoteTextItem *)item;
            if (itemt.text && ![itemt.text isEqualToString:@""]) {
                [textNotes addObject:itemt.text];
            }
        }
    }
    
    return textNotes;
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
            NSString* localPath = [item objectForKey:@"local"];
            [image setLocalPath:localPath];
            
            NSString* remotePath = [item objectForKey:@"url"];
            [image setRemotePath:[NSURL URLWithString:remotePath]];
            
            NSString* uid = [item objectForKey:@"id"];
            [image setUid:uid];
            
            // add item to array
            [_items addObject:image];
            
            //configure topic flags
            hasPicture = YES;
            
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
            CGFloat size = [[item objectForKey:@"textSize"] floatValue];
            [text setFont:[UIFont fontWithName:fontName size:size]];
            
            // add item to array
            [_items addObject:text];

        }
        // create audio note item
        else if([type isEqualToString:@"voice"]){
            
            NTNoteAudioItem *voice = [[NTNoteAudioItem alloc] init];
            
            // change frame
            CGRect rect = CGRectMake(x, y, 66.0f, 66.0f);
            [voice setRect:rect];
            
            // change remote url
            NSString* url = [item objectForKey:@"url"];
            [voice setRemotePath:[NSURL URLWithString:url]];
            
            // change local path
            NSString *path = [item objectForKey:@"local"];
            [voice setLocalPath:path];
            
            // change uid
            NSString* uid = [item objectForKey:@"id"];
            [voice setUid:uid];
            
            // add item to array
            [_items addObject:voice];
            
            //configure topic flags
            hasSound = YES;
             
        }
        // create path note item
        else if([type isEqualToString:@"path"]){
            
            // array for all point in path
            NSMutableArray *points = [[NSMutableArray alloc] init];
            
            // create points and add to array
            for (id obj in [item objectForKey:@"points"]){
                
                CGPoint point = CGPointMake([[obj objectForKey:@"x"] floatValue], [[obj objectForKey:@"y"] floatValue]);
                [points addObject:[NSValue valueWithCGPoint:point]];
                
            }

            NTNotePathItem *path = [[NTNotePathItem alloc] init];
            
            path.path = [NTNotePathItem pathFromPoints:points];
            
            // get height
            CGFloat width = [[item objectForKey:@"width"] floatValue];
            CGFloat height = [[item objectForKey:@"height"] floatValue];
            
            // change frame
            CGRect rect = CGRectMake(x, y, width, height);
            [path setRect:rect];
            
            // change Line Width
            [path setLineWidth:[[item objectForKey:@"lineWidth"] floatValue]];
            
            // change line opacity
            [path setOpacity:[[item objectForKey:@"opacity"] floatValue]];
            
            // change line color

            if([[item objectForKey:@"lineColor"] isEqual:@"(null)"]){
                [path setLineColor:[UIColor blackColor]];
            }
            else{
                [path setLineColor:[[item objectForKey:@"lineColor"] colorWithHexString]];
            }
            
            // add to items array
            [_items addObject:path];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)saveNoteItems{

    NSMutableString *jsonString = [[NSMutableString alloc] init];
    [jsonString appendString:@"{\"elements\":["];
    int i=0;
    
    // reset topic flags
    hasSound = NO;
    hasPicture = NO;
    hasCalendar = NO;
    
    for(NTNoteItem *item in _items){
                [jsonString appendString:@"{"];
        if([item isKindOfClass:[NTNoteTextItem class]]) {
            NTNoteTextItem *itemt = (NTNoteTextItem *)item;
            
            // save for json
            NSString *stringJSON = itemt.text;
            stringJSON = [stringJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
            stringJSON = [stringJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            stringJSON = [stringJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            
            [jsonString appendString:@"\"type\":\"html\","];
            [jsonString appendFormat:@"\"html\":\"%@\",", stringJSON];
            [jsonString appendFormat:@"\"textColor\":\"#%@\",", [itemt.color stringWithHexColorWithoutAlpha]];
            [jsonString appendFormat:@"\"textSize\":\"%f\",", itemt.font.pointSize];
            [jsonString appendFormat:@"\"font\":\"%@\",", itemt.font.fontName];
        }
        else if([item isKindOfClass:[NTNoteImageItem class]]){
            NTNoteImageItem *itemt = (NTNoteImageItem *)item;
            [jsonString appendString:@"\"type\":\"image\","];
            [jsonString appendFormat:@"\"id\":\"%@\",", itemt.uid];
            [jsonString appendFormat:@"\"url\":\"%@\",", [itemt.remotePath absoluteString]];
            [jsonString appendFormat:@"\"local\":\"%@\",", itemt.localPath];
            hasPicture = YES;
        }
        else if([item isKindOfClass:[NTNoteAudioItem class]]){
            NTNoteAudioItem *itemt = (NTNoteAudioItem *)item;
            [jsonString appendString:@"\"type\":\"voice\","];
            [jsonString appendFormat:@"\"id\":\"%@\",", itemt.uid];
            [jsonString appendFormat:@"\"url\":\"%@\",", [itemt.remotePath absoluteString]];
            [jsonString appendFormat:@"\"local\":\"%@\",", itemt.localPath];
            hasSound = YES;
        }
        else if([item isKindOfClass:[NTNotePathItem class]]){
            NTNotePathItem *itemt = (NTNotePathItem *)item;
            [jsonString appendString:@"\"type\":\"path\","];
            [jsonString appendFormat:@"\"lineColor\":\"%@\",", [itemt.lineColor stringWithHexColorWithoutAlpha]];
            [jsonString appendFormat:@"\"lineWidth\":\"%.2f\",", itemt.lineWidth];
            [jsonString appendFormat:@"\"opacity\":\"%.2f\",", itemt.opacity];
            [jsonString appendString:[self pointsFromPath:itemt.path]];
        }
       
        [jsonString appendFormat:@"\"x\":\"%.2f\",", item.rect.origin.x];
        [jsonString appendFormat:@"\"y\":\"%.2f\",", item.rect.origin.y];
        [jsonString appendFormat:@"\"width\":\"%.2f\",", item.rect.size.width];
        [jsonString appendFormat:@"\"height\":\"%.2f\"", item.rect.size.height];
        
        [jsonString appendString:@"}"];
        if(i<[_items count]-1) [jsonString appendString:@","];
        i++;
    }
    [jsonString appendString:@"]}"];
    
    if (_filePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_filePath];
        
        [jsonString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    
    _fileContents = [jsonString dataUsingEncoding:NSStringEncodingConversionExternalRepresentation];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)pointsFromPath:(CGPathRef)path{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    [resultString appendString:@"\"points\":\["];

    NSMutableArray* a = [[NSMutableArray alloc] init];
	CGPathApply(path, (__bridge void *)(a), &SaveCGPathApplierFunc);
	if (a)
	{
        for (int i=0; i<[a count];i++) {
            CGPoint myPoint = [[[a objectAtIndex:i] objectForKey:@"point"] CGPointValue];
            [resultString appendFormat:@"\{ \"x\":\"%.2f\",\"y\":\"%.2f\"  \}", myPoint.x, myPoint.y];
            if(i != [a count]-1){
                [resultString appendString:@","];
            }
        }
        [resultString appendString:@"],"];
        return resultString;
	}
    return @"";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)enterEditModeOfItem:(NTNoteItem *)item {
    // exit editing mode
    [self exitEditMode];

    if ([item isKindOfClass:[NTNoteTextItem class]]) {

        // create text item view
        _currentNoteView = [[NTTextView alloc] initWithItem:item];
        [_currentNoteView setResizableViewDelegate:self];
        [(NTTextView *)_currentNoteView setNoteViewDelegate:self];
        [(NTTextView *)_currentNoteView setMaxRect:self.view.bounds];
        
        [(NTTextView *)_currentNoteView allowUserTextEditing];
    }
    
    else if ([item isKindOfClass:[NTNoteImageItem class]]) {

        // create image item view
        _currentNoteView = [[NTImageView alloc] initWithItem:item];
        [_currentNoteView setResizableViewDelegate:self];
    }
    else if([item isKindOfClass:[NTNoteAudioItem class]]){
        
        //create audio view
        [item setRect:CGRectMake(item.rect.origin.x, item.rect.origin.y, 264.0f, 220.0f)];
        _currentNoteView = [[NTNoteAudioView alloc] initWithAudioItem:(NTNoteAudioItem *)item];
        [(NTNoteAudioView*)_currentNoteView setNoteDelegate:self];
        [(NTNoteAudioView*)_currentNoteView setAutomaticStop:self.automaticStop];
        [(NTNoteAudioView*)_currentNoteView setAutomaticStopInterval:self.automaticStopInterval];
        [_contentView removeGestureRecognizer:_tapGestureRecognizer];
        [_currentNoteView setResizableViewDelegate:self];
    }
    else if([item isKindOfClass:[NTNotePathItem class]]){
        _currentNoteView = [[NTPathView alloc] initWithItem:item];
        [_currentNoteView setResizableViewDelegate:self];
    }
    // move to editing mode
    [item setEditingMode:YES];
    
    // show blue dots
    [_currentNoteView showEditingHandles];
    
    //set interaction delegate
    [_currentNoteView setInteractionDelegate:self];

    // add subview
    [_contentView addSubview:_currentNoteView];
    [_contentView setNeedsDisplay];
    [_delegate editingModeIsOn];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)exitEditMode {
    
    if (_currentNoteView) {
        // if is in text mode, have to break because this method will be called on textViewDidEndEditing:
        if([_currentNoteView isKindOfClass:[NTTextView class]] && [_currentNoteView isFirstResponder]) {
            [(NTTextView*)_currentNoteView resignFirstResponder];
            return;
        }

        // exit editing mode
        [[_currentNoteView item] setEditingMode:NO];

        if([[_currentNoteView item] isKindOfClass:[NTNoteAudioItem class]]){
            
            //create audio view
            [[_currentNoteView item] setRect:CGRectMake(_currentNoteView.item.rect.origin.x, _currentNoteView.item.rect.origin.y, 66.0f, 66.0f)];
            
        } else if ([_currentNoteView isKindOfClass:[NTTextView class]]) {
            if ([[(NTTextView*)_currentNoteView getText] isEqualToString:@""]) {
                [_currentNoteView resignFirstResponder];
                [_items removeObject:_currentNoteView.item];
                [_contentView setNeedsDisplay];
            }
        }
        
        // hide blue dots
        [_currentNoteView hideEditingHandles];
        
        // remove view
        [_currentNoteView removeFromSuperview];
        _currentNoteView = nil;
        
        // redraw view
        [_contentView setNeedsDisplay];
        
        if (![[_contentView gestureRecognizers] containsObject:_tapGestureRecognizer]) {
            [_contentView addGestureRecognizer:_tapGestureRecognizer];
        }
        
        // save contents of file
        [self saveNoteItems];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)viewDidChangePosition:(CGRect)frame{
    // set frame to match lines
    if([_currentNoteView.item isKindOfClass:[NTNoteTextItem class]]) {
        // there surely is better method to get lineHeight in pixels; baselineOffset is top offset
        CGFloat lineHeight = 24;
        CGFloat baselineOffset = 0.0f;

        NSUInteger numberOfLines = (self.view.bounds.size.height - baselineOffset) / lineHeight;
        int heightMin = baselineOffset; int heightMax = 0; int result = 0;
        for (int x = 0; x < numberOfLines; x++) {
            heightMax = lineHeight*x + baselineOffset;
            
            if (heightMax > CGRectGetMinY(frame)) {
                // heightMax is farer than touchpoint
                if (CGRectGetMinY(frame) - heightMin < heightMax - CGRectGetMinY(frame)) {
                    result = heightMin;
                } else {
                    result = heightMax;
                }
                // we don't need to execute it any more
                break;
            } else {
                // we need to keep previous height
                heightMin = heightMax;
                result = heightMax;
            }
        }
        
        // apply value to our frame & save result
        frame.origin.y = result;
        [_currentNoteView setFrame:frame];
        [_currentNoteView.item setRect:frame];
        
    } else if([_currentNoteView.item isKindOfClass:[NTNoteImageItem class]] || [_currentNoteView.item isKindOfClass:[NTNoteAudioItem class]]) {
        [_currentNoteView.item setRect:frame];
        
    } else {
        [_currentNoteView.item setRect:CGRectInset(frame, -20.0f, -20.0f)];
        
        [self exitEditMode];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateCurrentNoteView{
    [(NTTextView *)_currentNoteView updateTextView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateDownloadableItem:(NTNoteItem*)item {
    if ([self.delegate respondsToSelector:@selector(willUpdateNoteItem:)]) {
        [self.delegate willUpdateNoteItem:item];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tapGestureAction:(UITapGestureRecognizer *)gestureRecognizer {
    // get touch point
    CGPoint point = [gestureRecognizer locationInView:_contentView];
    
    // hack for iOS 5.1
    UIView * view = [self.view hitTest:point withEvent:nil];
    
    [self handleActionForPoint:point edit:YES delete:[view isKindOfClass:[UIButton class]]];
}

- (void)handleActionForPoint:(CGPoint)point edit:(BOOL)edit delete:(BOOL)delete {
       
    // enumerate all items
    [_items enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NTNoteItem* item, NSUInteger idx, BOOL *stop) {
        
        // fix bug with _currentNoteView not receiving neither touchCancelled nor touchEnded - as a result not saving new frame
        if ([_currentNoteView.item isEqual:item] && item.editingMode) {
            [_currentNoteView touchesEnded:nil withEvent:nil];
        }
        
        // check if rect of item contain touch point
        if ((!item.editingMode || delete) &&  CGRectContainsPoint(CGRectInset(item.rect, -10.0f, -10.0f), point)) {
            
            if (delete) {
                if ([self.delegate respondsToSelector:@selector(willDeleteNoteItem:)]) {
                    [self.delegate willDeleteNoteItem:item];
                }
                [self deleteItem:item];
                *stop = YES;
                return;
            }
            
            if (edit) {
            // enter editimg mode with selected item
                [self enterEditModeOfItem:item];
                *stop = YES;
            } else {
                _draggedItem = item;
            }
            // yeap, we found
            
        }
        // if last object
        else if (idx == [_items count] -1) {
            // exit edit mode
            [self exitEditMode];
        }
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
    [super touchesBegan:touches withEvent:event];
   
    _draggedItem = nil;
    
    CGPoint point = [[touches anyObject] locationInView:_contentView];
    [self handleActionForPoint:point edit:NO delete:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
 
    [super touchesMoved:touches withEvent:event];
    
    CGPoint point = [[touches anyObject] locationInView:_contentView];
    UIEdgeInsets insets = UIEdgeInsetsMake(70, 130, 70, 80);
    
    if ((point.x > insets.left) && (point.x + insets.right < CGRectGetWidth(_contentView.frame)) && (point.y > insets.top) && (point.y + insets.bottom < CGRectGetHeight(_contentView.frame)) && [_draggedItem isKindOfClass:[NTNoteAudioItem class]]) {
        CGRect frame = [(NTNoteAudioItem*)_draggedItem rect];
        frame.origin.x = floorf(point.x - CGRectGetWidth(frame) * 0.5);
        frame.origin.y = floorf(point.y - CGRectGetHeight(frame) * 0.5);
        [(NTNoteAudioItem*)_draggedItem setRect:frame];
        [_contentView setNeedsDisplay];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    _draggedItem = nil;
}


#pragma mark - NoteAudioViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)audioView:(NTNoteAudioView *)audioView hasFinishedRecording:(BOOL)finished {
    [self updateDownloadableItem:_currentNoteView.item];
}


#pragma mark - flags getters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasPicture {
    return hasPicture;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasSound {
    return hasSound;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasCalendar {
    return hasCalendar;
}


#pragma mark - other

////////////////////////////////////////////////////////////////////////////////////////////////////
void SaveCGPathApplierFunc(void *info, const CGPathElement *element) {
    NSMutableArray* a = (__bridge NSMutableArray*) info;

    int nPoints;
    
    if (element->type == kCGPathElementMoveToPoint) {
        nPoints = 1;
    } else if (element->type == kCGPathElementAddLineToPoint) {
        nPoints = 1;
    } else if (element->type == kCGPathElementAddQuadCurveToPoint) {
        nPoints = 2;
    } else if (element->type == kCGPathElementAddCurveToPoint) {
        nPoints = 3;
    } else if (element->type == kCGPathElementCloseSubpath) {
        nPoints = 0;
    }
    else return;
    CGPoint p = (CGPoint)element->points[0];

    NSDictionary *singleElement =[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:nPoints],[NSValue valueWithCGPoint:p], nil]
                                                             forKeys:[NSArray arrayWithObjects:@"type", @"point", nil]];
    [a addObject:singleElement];

}

#pragma mark - Interaction Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteItem:(NTNoteItem *)item {
    [_items removeObject:item];
    [self exitEditMode];
    [_contentView setNeedsDisplay];
}

#pragma mark - NTTextView delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDelegate:(NTTextView *)textView requestedRefreshingFrameOfItem:(NTNoteTextItem *)item {
    if ([_currentNoteView.item isEqual:item]) {
        [_currentNoteView setFrame:item.rect];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDelegate:(NTUserResizableView *)textView requestedEndEditionOfItem:(NTNoteTextItem *)item {
    [self exitEditMode];
}


@end
