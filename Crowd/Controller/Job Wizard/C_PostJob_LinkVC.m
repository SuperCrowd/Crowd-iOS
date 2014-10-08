//
//  C_PostJob_LinkVC.m
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_LinkVC.h"
#import "AppConstant.h"
#import "UITextFieldExtended.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"

#import "Update_PostJob.h"
@interface C_PostJob_LinkVC ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextFieldExtended *txtLink;
}
@end

@implementation C_PostJob_LinkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"] ||
       [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
        txtLink.text = ([is_PostJob_Edit_update isEqualToString:@"update"])?postJob_ModelClass.URL:dictPostNewJob[@"JobURL"];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [txtLink becomeFirstResponder];
}
-(void)done
{
    if ([self checkValidation])
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
}
-(void)back
{
    popView;
}

-(IBAction)btnEditClicked:(UIButton *)btnEdit
{
    [txtLink becomeFirstResponder];
}
-(BOOL)checkValidation
{
    NSString *strURL = [[NSString stringWithFormat:@"%@",txtLink.text]isNull];;
    if (strURL.length > 0) {
        if (![CommonMethods isValidateUrl:strURL])
        {
            showHUD_with_error(@"Please Enter Valid URL");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                hideHUD;
            });
            return NO;
        }
    }
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
        postJob_ModelClass.URL = [[NSString stringWithFormat:@"%@",txtLink.text]isNull];
    else
        [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",txtLink.text]isNull] forKey:@"JobURL"];
    return YES;
}
-(IBAction)btnNextClicked:(id)sender
{
    @try
    {
        if ([self checkValidation])
        {
            if ([is_PostJob_Edit_update isEqualToString:@"update"])
            {
                for (UIViewController *vc in self.navigationController.viewControllers)
                {
                    if ([vc isKindOfClass:[C_PostJob_UpdateVC class]])
                    {
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                }
            }
            else
            {
                C_PostJob_PreviewVC *obj = [[C_PostJob_PreviewVC alloc]initWithNibName:@"C_PostJob_PreviewVC" bundle:nil];
                [self.navigationController pushViewController:obj animated:YES];
            }
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtLink resignFirstResponder];
    return YES;
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
