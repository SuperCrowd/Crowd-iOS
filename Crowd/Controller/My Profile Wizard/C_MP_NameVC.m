//
//  C_MP_NameVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_NameVC.h"
#import "AppConstant.h"
#import "C_ScrollViewKeyboard.h"
#import "C_ViewEditableTextField.h"
#import "C_MP_ChooseImageVC.h"

#import "UpdateProfile.h"
typedef NS_ENUM(NSInteger, btnTapped){
    btn_FirstName = 1,
    btn_LastName = 2
};
@interface C_MP_NameVC ()<UITextFieldDelegate>
{
    __weak IBOutlet C_ScrollViewKeyboard *scrlV;
    
    __weak IBOutlet C_ViewEditableTextField *viewFirstName;
    __weak IBOutlet C_ViewEditableTextField *viewLastName;

}

@end

@implementation C_MP_NameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Name";    
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(doneClicked)];

    /*--- Show data ---*/
    [self showData];
}
-(void)back
{
    popView;
}
-(void)doneClicked
{
    if ([self checkValidation])
    {
        UpdateProfile *profile = [[UpdateProfile alloc]init];
        [profile updateProfile_WithModel:_obj_ProfileUpdate withSuccessBlock:^{
            [self back];
        } withFailBlock:^(NSString *strError) {
            [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
        }];
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
    
    
    viewFirstName.txtName.text = _obj_ProfileUpdate.FirstName;
    viewLastName.txtName.text = _obj_ProfileUpdate.LastName;
    
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
        _obj_ProfileUpdate.FirstName = viewFirstName.txtName.text;
        _obj_ProfileUpdate.LastName = viewLastName.txtName.text;
        return YES;
    }
}

-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        C_MP_ChooseImageVC *obj = [[C_MP_ChooseImageVC alloc]initWithNibName:@"C_MP_ChooseImageVC" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
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
    // Dispose of any resources that can be recreated.
}



@end
