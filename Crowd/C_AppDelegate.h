//
//  C_AppDelegate.h
//  Crowd
//
//  Created by MAC107 on 05/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C_LoginVC;
@interface C_AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navC;
@property (strong, nonatomic) C_LoginVC *objLoginVC;

-(BOOL)isConnected;
@end
