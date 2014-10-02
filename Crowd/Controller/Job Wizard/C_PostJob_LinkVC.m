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
#pragma mark - Extra

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
