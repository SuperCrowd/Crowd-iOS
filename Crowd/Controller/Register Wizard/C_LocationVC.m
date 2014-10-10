//
//  C_LocationVC.m
//  Crowd
//
//  Created by MAC107 on 08/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_LocationVC.h"
#import "C_ViewEditableTextField.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#import "C_ScrollViewKeyboard.h"

#import "C_IndustryVC.h"
#import "C_ProfilePreviewVC.h"
typedef NS_ENUM(NSInteger, btnEdit) {
    btnCity = 1,
    btnState = 2,
    btnCountry = 3
};

@interface C_LocationVC ()<UITextFieldDelegate>
{
    __weak IBOutlet C_ScrollViewKeyboard *scrlV;
    
    __weak IBOutlet C_ViewEditableTextField *viewCity;
    __weak IBOutlet C_ViewEditableTextField *viewState;
    __weak IBOutlet C_ViewEditableTextField *viewCountry;
    
    __weak IBOutlet NSLayoutConstraint *constraint_scrollHeight;
}
@end

@implementation C_LocationVC
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Location";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    if ([[UserDefaults objectForKey:PROFILE_PREVIEW]isEqualToString:@"yes"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
        viewCity.txtName.text = myUserModel.location_city;
        viewState.txtName.text = myUserModel.location_state;
        viewCountry.txtName.text = myUserModel.location_country;
    }
    else
    {
        viewCity.txtName.text = myUserModel.location_city;
        viewState.txtName.text = myUserModel.location_state;
        viewCountry.txtName.text = myUserModel.location_country;
        
        /*
        NSArray *arr = [myUserModel.location_city componentsSeparatedByString:@","];
        if (arr.count == 1)
        {
            if (![myUserModel.location_city isEqualToString:@""]) {
                viewCity.txtName.text = myUserModel.location_city;
            }
            if (![myUserModel.location_state isEqualToString:@""])
            {
                viewState.txtName.text = myUserModel.location_state;
            }
            if (![myUserModel.location_country isEqualToString:@""]) {
                viewCountry.txtName.text = myUserModel.location_country;
            }
        }
        else if (arr.count == 2) {
            viewCity.txtName.text = [arr[0] isNull];
            viewCountry.txtName.text = [arr[1] isNull];
        }
        else
        {
            for (int i = 0; i<arr.count; i++)
            {
                if (i==0)
                    viewCity.txtName.text = [arr[0] isNull];
                else  if (i==1)
                    viewState.txtName.text = [arr[1] isNull];
                else if (i==2)
                {
                    viewCountry.txtName.text = [arr[2] isNull];
                    break;
                }
            }
        }
         */
    }
    [self setupEditableView];
    constraint_scrollHeight.constant = 0.0;
    
    
    
    
//#if TARGET_IPHONE_SIMULATOR
//    viewCity.txtName.text = myUserModel.location_city;
//    viewState.txtName.text = myUserModel.location_state;
//    viewCountry.txtName.text = myUserModel.location_country;
//#else
//    // Device
//#endif
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [viewCity.txtName becomeFirstResponder];
}
-(void)btnDoneClicked:(id)sender
{
    if ([self checkValidation])
    {
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_ProfilePreviewVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    }
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
    constraint_scrollHeight.constant = 0.0;
    [self.view endEditing:YES];
    
    NSString *strCity = [viewCity.txtName.text isNull];
    NSString *strState = [viewState.txtName.text isNull];
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
        myUserModel.location_city = strCity;
        myUserModel.location_state = strState;
        myUserModel.location_country = strCountry;
        
        [CommonMethods saveMyUser:myUserModel];
        myUserModel = [CommonMethods getMyUser];
        return YES;
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([self checkValidation])
    {
        C_IndustryVC *obj = [[C_IndustryVC alloc]initWithNibName:@"C_IndustryVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
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
//        constraint_scrollHeight.constant = 0.0;
        [textField resignFirstResponder];
    }
    return YES;
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
