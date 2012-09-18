//
//  AppDelegate.h
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-16.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglyEngine.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SinglyEngine *singlyEngine;
@property (strong, nonatomic) MKNetworkEngine *smallImageEngine;
@property (strong, nonatomic) MKNetworkEngine *largeImageEngine;

@end
