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
-(void)done
{
    if ([self checkValidation])
    {
        Class mtyC = nil;;
        if ([is_PostJob_Edit_update isEqualToString:@"edit"])
        {
            mtyC = [C_PostJob_PreviewVC class];
        }
        else
        {
            mtyC = [C_PostJob_UpdateVC class];
        }
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:mtyC])
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
-(void)btnCancelClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
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
        {
            postJob_ModelClass.Title = [[NSString stringWithFormat:@"%@",txtPosition.text]isNull];
        }
        else
        {
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",txtPosition.text]isNull] forKey:@"Title"];
        }
        return YES;
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        @try
        {
            
            C_PostJob_LocationVC *objC = [[C_PostJob_LocationVC alloc]initWithNibName:@"C_PostJob_LocationVC" bundle:nil];
            [self.navigationController pushViewController:objC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtPosition resignFirstResponder];
    return YES;
}
#pragma mark - Extra

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
