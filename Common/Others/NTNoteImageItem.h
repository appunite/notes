//
//  NTNoteImageItem.h
//  Notes
//
//  Created by Emil Wojtaszek on 01.12.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>

//Others
#import "NTNoteItem.h"

@interface NTNoteImageItem : NTNoteItem

// keep respurce path of image
@property (nonatomic, strong) NSString* localPath;

// keep respurce path of image
@property (nonatomic, strong) NSString* remotePath;
@end


@interface NTNoteImageItem (Draw)
+ (void)drawItem:(NTNoteImageItem *)item rect:(CGRect)rect context:(CGContextRef)ctx;
@end
