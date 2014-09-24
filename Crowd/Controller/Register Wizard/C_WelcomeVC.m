//
//  C_WelcomeVC.m
//  Crowd
//
//  Created by MAC107 on 08/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_WelcomeVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#import "C_ChooseImageVC.h"
#import "C_ViewEditableTextField.h"
#import "C_ScrollViewKeyboard.h"
#import "C_ProfilePreviewVC.h"
typedef NS_ENUM(NSInteger, btnTapped){
    btn_FirstName = 1,
    btn_LastName = 2
};
@interface C_WelcomeVC ()<UITextFieldDelegate>
{
    __weak IBOutlet C_ScrollViewKeyboard *scrlV;
    
    __weak IBOutlet C_ViewEditableTextField *viewFirstName;
    __weak IBOutlet C_ViewEditableTextField *viewLastName;
    
    __weak IBOutlet UIView *viewWelcome;
}
@end

@implementation C_WelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Name";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];

    if ([[UserDefaults objectForKey:PROFILE_PREVIEW]isEqualToString:@"yes"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
        
        viewWelcome.alpha = 0.0;
    }
    /*--- Show data ---*/
    [self showData];
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
-(void)showData
{
    viewFirstName.lblName.adjustsFontSizeToFitWidth = YES;
    viewLastName.lblName.adjustsFontSizeToFitWidth = YES;
    
    viewFirstName.txtName.placeholder = @"First name";
    viewLastName.txtName.placeholder = @"Last name";
    
    viewFirstName.lblName.text = @"First name";
    viewLastName.lblName.text = @"Last name";

    
    viewFirstName.txtName.text = myUserModel.firstName;
    viewLastName.txtName.text = myUserModel.lastName;
    
    viewLastName.txtName.returnKeyType = UIReturnKeyDone;
    
    viewFirstName.txtName.delegate = self;
    viewLastName.txtName.delegate = self;
    
    
    viewFirstName.btnEdit.tag = 1.0;
    viewLastName.btnEdit.tag = 2.0;
    
    [viewFirstName.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewLastName.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)btnEditClicked:(UIButton *)btnEdit
{
    btnTapped btnSelected = btnEdit.tag;
    switch (btnSelected) {
        case 1:
            [viewFirstName.txtName becomeFirstResponder];
            break;
        case 2:
            [viewLastName.txtName becomeFirstResponder];
            break;
        default:
            break;
    }
}
-(BOOL)checkValidation
{
    if ([[viewFirstName.txtName.text isNull]isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please enter first name" withMessage:nil withViewController:self];
        return NO;
    }
    else if([[viewLastName.txtName.text isNull]isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please enter last name" withMessage:nil withViewController:self];
        return NO;

    }
    else
    {
        myUserModel.firstName = viewFirstName.txtName.text;
        myUserModel.lastName = viewLastName.txtName.text;
        [CommonMethods saveMyUser:myUserModel];
        myUserModel = [CommonMethods getMyUser];
        return YES;
    }
}

-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        C_ChooseImageVC *obj = [[C_ChooseImageVC alloc]initWithNibName:@"C_ChooseImageVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == viewFirstName.txtName)
    {
        [viewLastName.txtName becomeFirstResponder];
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

}


@end
