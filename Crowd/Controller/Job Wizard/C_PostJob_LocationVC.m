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
#if TARGET_IPHONE_SIMULATOR
        viewCity.txtName.text = @"Ahmedabad";
        viewState.txtName.text = @"Gujarat";
        viewCountry.txtName.text = @"India";
#else
        // Device
#endif
    }
    
    
    
    [self setupEditableView];
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
    //NSString *strState = [viewState.txtName.text isNull];
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
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([self checkValidation])
    {
        @try
        {
            C_PostJob_ExperienceVC *obj = [[C_PostJob_ExperienceVC alloc]initWithNibName:@"C_PostJob_ExperienceVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        

    }
}
-(void)btnEditClicked:(id)sender
{
    NSLog(@"btn tapped");
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
