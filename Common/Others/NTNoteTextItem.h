//
//  NTNoteTextItem.h
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>

//Others
#import "NTNoteItem.h"

@interface NTNoteTextItem : NTNoteItem

// keep text of item
@property (nonatomic, strong) NSString* text;

// keep font of drawing text
@property (nonatomic, strong) UIFont* font;

// keep text color
@property (nonatomic, strong) UIColor* color;
@end


@interface NTNoteTextItem (Draw)
+ (void)drawItem:(NTNoteTextItem *)item rect:(CGRect)rect context:(CGContextRef)ctx;
+ (void)drawItem:(NTNoteTextItem *)item rect:(CGRect)rect context:(CGContextRef)ctx color:(UIColor *)fontColor font:(UIFont *)font;
@end