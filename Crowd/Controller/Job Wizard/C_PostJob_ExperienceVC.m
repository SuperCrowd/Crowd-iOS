//
//  C_PostJob_ExperienceVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_ExperienceVC.h"
#import "AppConstant.h"
#import "C_PostJob_RolesVC.h"
typedef NS_ENUM(NSInteger, btnExperience)
{
    btn_0_to_1 = 0,
    btn_1_to_3 = 1,
    btn_3_to_5 = 2,
    btn_5_to_8 = 3,
    btn_8 = 4,
};
@interface C_PostJob_ExperienceVC ()
{
    __weak IBOutlet UIScrollView *scrlV;
}
@end

@implementation C_PostJob_ExperienceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    
    for (UIButton *btn in scrlV.subviews)
        if ([btn isKindOfClass:[UIButton class]])
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)back
{
    popView;
}
-(void)btnCancelClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(IBAction)btnClicked:(UIButton *)btnExp
{
    NSLog(@"%@",btnExp.titleLabel.text);
    [dictPostNewJob setValue:[NSString stringWithFormat:@"%ld",(long)btnExp.tag] forKey:@"experience"];
    C_PostJob_RolesVC *obj = [[C_PostJob_RolesVC alloc]initWithNibName:@"C_PostJob_RolesVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
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
