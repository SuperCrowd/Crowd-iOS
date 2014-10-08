//
//  C_PostJob_PositionVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_PositionVC.h"
#import "AppConstant.h"
#import "C_ViewEditableTextField.h"
#import "C_PostJob_LocationVC.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"

#import "Update_PostJob.h"
@interface C_PostJob_PositionVC ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextFieldExtended *txtPosition;
}
@end

@implementation C_PostJob_PositionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"] ||
       [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
        txtPosition.text = ([is_PostJob_Edit_update isEqualToString:@"update"])?postJob_ModelClass.Title:dictPostNewJob[@"Title"];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [txtPosition becomeFirstResponder];
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
#pragma mark - IBAction
-(IBAction)btnEditClicked:(UIButton *)btnEdit
{
    [txtPosition becomeFirstResponder];
}
-(BOOL)checkValidation
{
    NSString *strT = [[NSString stringWithFormat:@"%@",txtPosition.text]isNull];
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please enter your position" withMessage:nil withViewController:self];
        return NO;
    }
    
    else
    {
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
            postJob_ModelClass.Title = [[NSString stringWithFormat:@"%@",txtPosition.text]isNull];
        else
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",txtPosition.text]isNull] forKey:@"Title"];
        
        return YES;
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        C_PostJob_LocationVC *objC = [[C_PostJob_LocationVC alloc]initWithNibName:@"C_PostJob_LocationVC" bundle:nil];
        [self.navigationController pushViewController:objC animated:YES];
    }
}
#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtPosition resignFirstResponder];
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
