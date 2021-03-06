//
//  C_PostJob_LocationVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_LocationVC.h"
#import "C_ViewEditableTextField.h"
#import "AppConstant.h"
#import "C_ScrollViewKeyboard.h"
#import "C_PostJob_ExperienceVC.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"

#import "Update_PostJob.h"
typedef NS_ENUM(NSInteger, btnEdit) {
    btnCity = 1,
    btnState = 2,
    btnCountry = 3
};

@interface C_PostJob_LocationVC ()<UITextFieldDelegate>
{
    __weak IBOutlet C_ScrollViewKeyboard *scrlV;
    
    __weak IBOutlet C_ViewEditableTextField *viewCity;
    __weak IBOutlet C_ViewEditableTextField *viewState;
    __weak IBOutlet C_ViewEditableTextField *viewCountry;
    
}

@end

@implementation C_PostJob_LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"] ||
       [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
        {
            viewCity.txtName.text = postJob_ModelClass.LocationCity;
            viewState.txtName.text = postJob_ModelClass.LocationState;
            viewCountry.txtName.text = postJob_ModelClass.LocationCountry;
        }
        else
        {
            viewCity.txtName.text = dictPostNewJob[@"LocationCity"];
            viewState.txtName.text = dictPostNewJob[@"LocationState"];
            viewCountry.txtName.text = dictPostNewJob[@"LocationCountry"];
        }
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }

    [self setupEditableView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [viewCity.txtName becomeFirstResponder];
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

-(void)setupEditableView
{
    viewCity.txtName.placeholder = @"Enter City";
    viewState.txtName.placeholder = @"Enter State";
    viewCountry.txtName.placeholder = @"Enter Country";
    
    viewCity.lblName.text = @"City";
    viewState.lblName.text = @"State";
    viewCountry.lblName.text = @"Country";
    
    viewCity.txtName.delegate = self;
    viewState.txtName.delegate = self;
    viewCountry.txtName.delegate = self;
    
    viewCountry.txtName.returnKeyType = UIReturnKeyDone;
    
    [viewCity.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    viewCity.btnEdit.tag = 1;
    
    [viewState.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    viewState.btnEdit.tag = 2;
    
    [viewCountry.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    viewCountry.btnEdit.tag = 3;
    
}
-(BOOL)checkValidation
{
    [self.view endEditing:YES];
    
    NSString *strCity = [viewCity.txtName.text isNull];
    NSString *strCountry= [viewCountry.txtName.text isNull];
    if ([strCity isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter City name" withMessage:nil withViewController:self];
        return NO;
    }
    else if ([strCountry isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter Country name" withMessage:nil withViewController:self];
        return NO;
    }
    else
    {
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
        {
            postJob_ModelClass.LocationCity = [[NSString stringWithFormat:@"%@",viewCity.txtName.text] isNull];
            postJob_ModelClass.LocationState = [[NSString stringWithFormat:@"%@",viewState.txtName.text] isNull];
            postJob_ModelClass.LocationCountry = [[NSString stringWithFormat:@"%@",viewCountry.txtName.text] isNull];
        }
        else
        {
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",viewCity.txtName.text] isNull] forKey:@"LocationCity"];
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",viewState.txtName.text] isNull] forKey:@"LocationState"];
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",viewCountry.txtName.text] isNull] forKey:@"LocationCountry"];
        }
        return YES;
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        C_PostJob_ExperienceVC *obj = [[C_PostJob_ExperienceVC alloc]initWithNibName:@"C_PostJob_ExperienceVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
}
-(void)btnEditClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btnEdit btnSelected = btn.tag;
    switch (btnSelected) {
        case btnCity:
            [viewCity.txtName becomeFirstResponder];
            break;
        case btnState:
            [viewState.txtName becomeFirstResponder];
            break;
        case btnCountry:
            [viewCountry.txtName becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - Textfield Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == viewCity.txtName)
    {
        [viewState.txtName becomeFirstResponder];
    }
    else if(textField == viewState.txtName)
    {
        [viewCountry.txtName becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
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
}

@end
