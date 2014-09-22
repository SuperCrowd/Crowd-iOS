//
//  UINavigationController+Rotation_IOS6.h
//  Top Files
//
//  Created by Gagan on 12/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotation_IOS6)
-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
@end
