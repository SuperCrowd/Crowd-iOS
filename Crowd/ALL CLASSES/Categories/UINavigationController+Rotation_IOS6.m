//
//  UINavigationController+Rotation_IOS6.m
//  Top Files
//
//  Created by Gagan on 12/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UINavigationController+Rotation_IOS6.h"
@implementation UINavigationController (Rotation_IOS6)
-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
        return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
@end
