//
//  NTInteractionDelegate.h
//  Notes
//
//  Created by Piotr Bernad on 04.03.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTInteractionDelegate <NSObject>
-(void)deleteItem:(NTNoteItem *)item;
@end