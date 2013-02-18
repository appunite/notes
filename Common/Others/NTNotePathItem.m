//
//  NTNotePathItem.m
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNotePathItem.h"

enum type{
    brush=0,
    pencil=1,
    highlighter=2,
    eraser=3
};

#define DEFAULT_COLOR [UIColor blackColor]
#define DEFAULT_WIDTH 5.0f

@implementation NTNotePathItem

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        // set defalts
        _lineWidth = DEFAULT_WIDTH;
        _lineColor = DEFAULT_COLOR;
        
        // create new mutable path
        _path = CGPathCreateMutable();
    }
    return self;
}
-(id)initWithBrushAttributes:(NSDictionary *)attributes{
    self = [super init];
    if (self) {
        // set defalts
        _lineWidth = DEFAULT_WIDTH;
        _lineColor = DEFAULT_COLOR;
        _opacity = 1.0f;
        _type = brush;
        
        // if type is brush
        if([attributes objectForKey:@"type"] == @"brush"){
            
        // set brush type
        _type = brush;
            
        // set line width
        if([attributes objectForKey:@"size"] == @"small")
            _lineWidth = 2.0f;
        if([attributes objectForKey:@"size"] == @"medium")
            _lineWidth = 4.0f;
        if([attributes objectForKey:@"size"] == @"large")
            _lineWidth = 10.0f;

        // set line color
        if([attributes objectForKey:@"color"])
            _lineColor = [attributes objectForKey:@"color"];
        
        // set opacity
            _opacity = 1.0f;
        }
        
        
        //if type is pencil
        if([attributes objectForKey:@"type"] == @"pencil"){

            // set brush type
            _type = pencil;
            
            // set line width
            _lineWidth = 1.0f;
            
            // set line color
            _lineColor = [UIColor blackColor];
            
            // set opacity
            _opacity = 1.0f;
        }
        if([attributes objectForKey:@"type"] == @"eraser"){
            
            // set brush type
            _type = eraser;
            
            // set line width
            _lineWidth = 15.0f;
            
            // set line color
            _lineColor = [UIColor clearColor];
            
            // set opacity
            _opacity = 1.0f;
        }
        
        
        // if type is highlighter
        if([attributes objectForKey:@"type"] == @"highlighter")
        {
            // set brush type
            _type = highlighter;
            
            // set line width
            _lineWidth = 20.0f;
            
            // set line color
        if([attributes objectForKey:@"color"])
            _lineColor = [attributes objectForKey:@"color"];
            
            // set opacity
            _opacity = 0.3f;
            
        }

        // create new mutable path
        _path = CGPathCreateMutable();
    }
    return self;
}

#pragma mark - Draw

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)drawItem:(NTNotePathItem *)item rect:(CGRect)rect context:(CGContextRef)ctx {

	CGContextAddPath(ctx, item.path);
    if(item.type == eraser){
        CGContextSetBlendMode(ctx, kCGBlendModeClear);
    }
    if(item.type == highlighter){
     CGContextSetLineCap(ctx, kCGLineCapSquare);
     CGContextSetBlendMode(ctx, kCGBlendModeColorBurn);
    }
    else CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetAlpha(ctx, item.opacity);
    CGContextSetLineWidth(ctx, item.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, item.lineColor.CGColor);
    CGContextStrokePath(ctx);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
	CGPathRelease(_path);
}

@end
