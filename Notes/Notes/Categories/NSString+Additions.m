//
//  NSString+Additions.m
//  Notes
//
//  Created by Natalia Osiecka on 23.05.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)colorWithHexString {
    CGFloat alpha, red, blue, green;
    int digitStart = 0;
    if ([self characterAtIndex:0] == '#') {
        digitStart++;
    }
    
    red = [self colorComponentFrom:self start:digitStart length:2];
    green = [self colorComponentFrom:self start:digitStart+2 length:2];
    blue = [self colorComponentFrom:self start:digitStart+4 length:2];
    
    if ([self length] > digitStart+6) {
        alpha = [self colorComponentFrom:self start:digitStart+6 length:2];
    } else {
        alpha = 1;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


@end
