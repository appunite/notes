//
//  NTNoteTextItem.m
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "NTNoteTextItem.h"

//Frameworks
#import <CoreText/CoreText.h>

@implementation NTNoteTextItem

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont *)font {
    // assign new font
    _font = font;
    
    // set default font
    if (!_font) {
        _font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setColor:(UIColor *)color {
    // assign new text color
    _color = color;
    
    // set default font
    if (!_color) {
        _color = [UIColor blackColor];
    }
}


#pragma mark - Draw

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)drawItem:(NTNoteTextItem *)item rect:(CGRect)rect context:(CGContextRef)ctx color:(UIColor *)fontColor font:(UIFont *)font{
    // get text
    NSString* text = [item text];
    //
    //    // get font
    //    UIFont* font = [item font];
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(rect), CGRectGetHeight(rect));
    
    // Convert UIFont to CTFontRef and add italic on Retina display
    if(!font)font = [UIFont systemFontOfSize:16];
    CTFontRef sysUIFont = CTFontCreateWithName((__bridge CFStringRef)[font fontName], [font pointSize], NULL);
    //    CTFontRef sysUIFont = CTFontCreateCopyWithSymbolicTraits(ref, [font pointSize], NULL, kCTFontItalicTrait, kCTFontItalicTrait);

    CGColorRef color = fontColor.CGColor ? fontColor.CGColor : [UIColor blackColor].CGColor;
    
	// pack it into attributes dictionary
	NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)sysUIFont, (id)kCTFontAttributeName,
                                    color, (id)kCTForegroundColorAttributeName, nil];
    
	// make the attributed string
	NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:text attributes:attributesDict];
    
    
	// flip the coordinate system
	CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    // Initialize a rectangular path.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bounds);
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);
    
    // Create the frame and draw it into the graphics context
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0.0f, 0.0f), path, NULL);
    
    CGContextTranslateCTM(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
	CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CFRelease(framesetter);
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
    
}

@end
