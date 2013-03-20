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
#import "NTNoteAudioView.h"
#import "NTPathView.h"
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
- (void)viewDidLoad {
    [super viewDidLoad];

    NSError* error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_filePath];

    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
    [self loadNoteItemsFromFile:filePath error:&error];
    }
    
    
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
//        NSLog(@"%@", error);
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
    [image setResourcePath:path];
    
    // add item to array
    [_items addObject:image];

}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestNewNoteTextItem {
    
    NTNoteTextItem *item = [[NTNoteTextItem alloc] init];
    
    CGFloat width = 200.0f;
    CGFloat height = 150.0f;
    
    CGRect rect = CGRectMake(10.0f, 10.0f, width, height);
    
    // set temporary text
    [item setText:@"Enter your text here..."];
    
    //set rect
    [item setRect:rect];
    
    //set default font
    [item setFont:[UIFont systemFontOfSize:13]];
    
    // add item to array
    [_items addObject:item];
    
    // reload content view
    [_contentView setNeedsDisplay];
    
    [self saveNoteItems];
    
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
    [self exitEditMode];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentViewMode:(NSUInteger)mode {
    [_contentView setNoteContentMode:mode];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)clearContent {
    [self exitEditMode];
    
    [_items removeAllObjects];
    [_contentView setNeedsDisplay];
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
            CGFloat size = [[item objectForKey:@"size"] floatValue];
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
                [path setLineColor:[self colorFromHexString:[item objectForKey:@"lineColor"]]];
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
        if([item isKindOfClass:[NTNoteTextItem class]])
        {
            NTNoteTextItem *itemt = item;
            [jsonString appendString:@"\"type\":\"html\","];
            [jsonString appendFormat:@"\"html\":\"%@\",", itemt.text];
            [jsonString appendFormat:@"\"textColor\":\"#%@\",", [self colorToWeb:itemt.color]];
            [jsonString appendFormat:@"\"textSize\":\"%f\",", itemt.font.pointSize];
        }
        else if([item isKindOfClass:[NTNoteImageItem class]]){
            NTNoteImageItem *itemt = item;
            [jsonString appendString:@"\"type\":\"image\","];
            [jsonString appendFormat:@"\"url\":\"%@\",", itemt.resourcePath];
            hasPicture = YES;
        }
        else if([item isKindOfClass:[NTNoteAudioItem class]]){
            NTNoteAudioItem *itemt = item;
            [jsonString appendString:@"\"type\":\"voice\","];
            [jsonString appendFormat:@"\"url\":\"%@\",", itemt.remotePath];
            [jsonString appendFormat:@"\"local\":\"%@\",", itemt.localPath];
            hasSound = YES;
        }
        else if([item isKindOfClass:[NTNotePathItem class]]){
            NTNotePathItem *itemt = item;
            [jsonString appendString:@"\"type\":\"path\","];
            [jsonString appendFormat:@"\"lineColor\":\"%@\",", [self colorToWeb:itemt.lineColor]];
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
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_filePath];

    [jsonString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
        [(NTTextView *)_currentNoteView allowUserTextEditing];
    }
    
    else if ([item isKindOfClass:[NTNoteImageItem class]]) {

        // create image item view
        _currentNoteView = [[NTImageView alloc] initWithItem:item];
        [_currentNoteView setResizableViewDelegate:self];
    }
    else if([item isKindOfClass:[NTNoteAudioItem class]]){
        
        //create audio view
        [item setRect:CGRectMake(item.rect.origin.x, item.rect.origin.y, 200.0f, 80.0f)];
        _currentNoteView = [[NTNoteAudioView alloc] initWithAudioItem:(NTNoteAudioItem *)item];
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

    // exit editing mode
    [[_currentNoteView item] setEditingMode:NO];

    if([[_currentNoteView item] isKindOfClass:[NTNoteAudioItem class]]){
        
        //create audio view
        [[_currentNoteView item] setRect:CGRectMake(_currentNoteView.item.rect.origin.x, _currentNoteView.item.rect.origin.y, 66.0f, 66.0f)];
    }
    
    // hide blue dots
    [_currentNoteView hideEditingHandles];
    
    // remove view
    [_currentNoteView removeFromSuperview];
    _currentNoteView = nil;

    // redraw view
    [_contentView setNeedsDisplay];
    
    [self saveNoteItems];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)viewDidChangePosition:(CGRect)frame{
    [_currentNoteView.item setRect:frame];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateCurrentNoteView{
    [(NTTextView *)_currentNoteView updateTextView];
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
-(NSString*)colorToWeb:(UIColor*)color {
    NSString *webColor = nil;
    
    if (color && CGColorGetNumberOfComponents(color.CGColor) == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        
        // These components range from 0.0 till 1.0 and need to be converted to 0 till 255
        CGFloat red, green, blue;
        red = roundf(components[0] * 255.0);
        green = roundf(components[1] * 255.0);
        blue = roundf(components[2] * 255.0);
        
        // Convert with %02x (use 02 to always get two chars)
        webColor = [[NSString alloc]initWithFormat:@"%02x%02x%02x", (int)red, (int)green, (int)blue];
    }
    
    return webColor;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [[UIColor alloc] initWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0  blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

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


@end
