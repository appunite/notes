//
//  NTNoteDownloadableItem.h
//  Notes
//
//  Created by Piotrek on 30.04.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTNoteItem.h"

@interface NTNoteDownloadableItem : NTNoteItem

@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSURL *remotePath;

@end
