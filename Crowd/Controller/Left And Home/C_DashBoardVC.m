//
//  C_DashBoardVC.m
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_DashBoardVC.h"
#import "AppConstant.h"
#import "C_PostJob_NameVC.h"
@interface C_DashBoardVC ()

@end

@implementation C_DashBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    
    if (_isGointToJobPostVC)
    {
        C_PostJob_NameVC *obj = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
        obj.isComeFromTutorial = YES;
        [self.navigationController pushViewController:obj animated:NO];
        return;
    }
}


-(void)btnMenuClicked:(id)sender
{
//    [UserDefaults removeObjectForKey:APP_USER_INFO];
//    [UserDefaults removeObjectForKey:PROFILE_PREVIEW];
//    [UserDefaults synchronize];
//    
//    [appDel.navC popToRootViewControllerAnimated:YES];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
