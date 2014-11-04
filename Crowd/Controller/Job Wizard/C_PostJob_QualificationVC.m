//
//  C_PostJob_QualificationVC.m
//  Crowd
//
//  Created by MAC107 on 31/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_QualificationVC.h"
#import "AppConstant.h"

#import "C_PostJob_RolesVC.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"

#import "Update_PostJob.h"

typedef NS_ENUM(NSInteger, btnQualification)
{
    btn_0_HIGH_SCHOOL = 0,
    btn_1_BACHELOR = 1,
    btn_3_MASTER = 2,
    btn_4_PHD = 3,
    btn_5_NONE = 4,
};


@interface C_PostJob_QualificationVC ()
{
    __weak IBOutlet UIScrollView *scrlV;
}
@end

@implementation C_PostJob_QualificationVC
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"]||
       [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
    for (UIButton *btn in scrlV.subviews)
        if ([btn isKindOfClass:[UIButton class]])
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showSelectedButton];
}
-(void)showSelectedButton
{
    for (UIButton *btn in scrlV.subviews)
        if ([btn isKindOfClass:[UIButton class]])
            [btn setBackgroundImage:[UIImage imageNamed:@"btnGreenBG-Big"] forState:UIControlStateNormal];
    NSInteger index ;
    NSString *strQ;
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        strQ = postJob_ModelClass.Qualifications;
    }
    else
    {
        strQ = [[NSString stringWithFormat:@"%@",dictPostNewJob[@"Qualifications"]]isNull];
    }
    
    if ([strQ isEqualToString:@""]) {
        index = 25;
    }
    else if ([strQ isEqualToString:@"High School GED"]) {
        index = 1;
    }
    else if ([strQ isEqualToString:@"Bachelor's"]) {
        index = 2;
    }
    else if ([strQ isEqualToString:@"Master's"]) {
        index = 3;
    }
    else if ([strQ isEqualToString:@"PhD"]) {
        index = 4;
    }
    else
    {
        //None
        index = 5;
    }
    if (index != 25)
    {
        UIButton *btnSel = (UIButton *)[scrlV viewWithTag:index];
        [btnSel setBackgroundImage:[UIImage imageNamed:@"btnOrangeBG-Big"] forState:UIControlStateNormal];
    }
    
}
-(void)done
{
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        Update_PostJob *job = [[Update_PostJob alloc]init];
        [job update_JobPost_with_withSuccessBlock:^{
            /*--- First update list model so fire notification then pop to update view---*/
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateJobListModel" object:nil];
            for (UIViewController *vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[C_PostJob_UpdateVC class]])
                {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        } withFailBlock:^(NSString *strError) {
            [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
        }];
    }
    else
    {
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_PostJob_PreviewVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    }
}
-(void)back
{
    popView;
}

-(IBAction)btnClicked:(UIButton *)btnQ
{
    //NSLog(@"%@",btnQ.titleLabel.text);
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        postJob_ModelClass.Qualifications = [NSString stringWithFormat:@"%@",btnQ.titleLabel.text];
    }
    else
    {
        [dictPostNewJob setValue:[NSString stringWithFormat:@"%@",btnQ.titleLabel.text] forKey:@"Qualifications"];
    }
    [self showSelectedButton];
    C_PostJob_RolesVC *obj = [[C_PostJob_RolesVC alloc]initWithNibName:@"C_PostJob_RolesVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark - Cancel Clicked
-(void)btnCancelClicked:(id)sender
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your job has not been posted yet. if you leave it will be lost. This can not be undone." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* LeaveAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                      {
                                          is_PostJob_Edit_update = @"no";
                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                      }];
        [alert addAction:LeaveAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your job has not been posted yet. if you leave it will be lost. This can not be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave",nil];[alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            is_PostJob_Edit_update = @"no";
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
