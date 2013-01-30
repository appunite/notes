//
//  NTNotePathItem.h
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>

//Others
#import "NTNoteItem.h"

@interface NTNotePathItem : NTNoteItem
// settings of path
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) UIColor* lineColor;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) NSInteger type;
// drawing path
@property (nonatomic, assign) CGMutablePathRef path;
@end


@interface NTNotePathItem (Draw)
+ (void)drawItem:(NTNotePathItem *)item rect:(CGRect)rect context:(CGContextRef)ctx;
-(id)initWithBrushAttributes:(NSDictionary *)attributes;
@end

