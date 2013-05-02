//
//  NTSelfDownloadingView.h
//  Notes
//
//  Created by Piotrek on 30.04.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "NTUserResizableView.h"

#import "NTNoteAudioItem.h"

@interface NTSelfDownloadingView : NTUserResizableView

@property(nonatomic, strong) NSURL * fileURL;

- (NSData*)itemContent;

@end
