//
//  C_Find_CandidateVC.m
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_Find_CandidateVC.h"
#import "AppConstant.h"

#import "C_Find_CandidateListingVC.h"
@interface C_Find_CandidateVC ()

@end

@implementation C_Find_CandidateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Find a Job";
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    C_Find_CandidateListingVC *obj = [[C_Find_CandidateListingVC alloc]initWithNibName:@"C_Find_CandidateListingVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    
    
    return;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
