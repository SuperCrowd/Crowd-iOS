//
//  C_MP_ExperienceVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_ExperienceVC.h"
#import "AppConstant.h"
#import "C_MP_ProffesionalSummaryVC.h"
typedef NS_ENUM(NSInteger, btnExperience)
{
    btn_0_to_1 = 0,
    btn_1_to_3 = 1,
    btn_3_to_5 = 2,
    btn_5_to_8 = 3,
    btn_8 = 4,
};

@interface C_MP_ExperienceVC ()
{
    __weak IBOutlet UIScrollView *scrlV;
}
@end

@implementation C_MP_ExperienceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Experience";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    for (UIButton *btn in scrlV.subviews)
        if ([btn isKindOfClass:[UIButton class]])
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)back
{
    popView;
}
-(IBAction)btnClicked:(UIButton *)btnExp
{
    _obj_ProfileUpdate.ExperienceLevel = [NSString stringWithFormat:@"%ld",(long)btnExp.tag];
    
    C_MP_ProffesionalSummaryVC *obj = [[C_MP_ProffesionalSummaryVC alloc]initWithNibName:@"C_MP_ProffesionalSummaryVC" bundle:nil];
    obj.obj_ProfileUpdate = _obj_ProfileUpdate;
    [self.navigationController pushViewController:obj animated:YES];
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
