//
//  AppDelegate.h
//  Notes
//
//  Created by Emil Wojtaszek on 30.11.2012.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTNoteViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow* window;
@property (strong, nonatomic) NTNoteViewController* viewController;
@end
