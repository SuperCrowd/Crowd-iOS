//
//  C_ExperienceVC.m
//  Crowd
//
//  Created by MAC107 on 16/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_ExperienceVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#import "C_ProffessionalSummaryVC.h"

typedef NS_ENUM(NSInteger, btnExperience)
{
    btn_0_to_1 = 0,
    btn_1_to_3 = 1,
    btn_3_to_5 = 2,
    btn_5_to_8 = 3,
    btn_8 = 4,
};
@interface C_ExperienceVC ()
{
    __weak IBOutlet UIScrollView *scrlV;
}
@end

@implementation C_ExperienceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Experience";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    for (UIButton *btn in scrlV.subviews)
        if ([btn isKindOfClass:[UIButton class]])
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(IBAction)btnClicked:(UIButton *)btnExp
{
    NSLog(@"%@",btnExp.titleLabel.text);
    myUserModel.experienceTotal = [NSString stringWithFormat:@"%ld",(long)btnExp.tag];
    [CommonMethods saveMyUser:myUserModel];
    myUserModel = [CommonMethods getMyUser];
    
    C_ProffessionalSummaryVC *obj = [[C_ProffessionalSummaryVC alloc]initWithNibName:@"C_ProffessionalSummaryVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
