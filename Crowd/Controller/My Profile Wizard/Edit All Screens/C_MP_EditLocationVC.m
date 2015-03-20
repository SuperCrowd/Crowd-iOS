//
//  C_MP_EditLocationVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_EditLocationVC.h"
#import "AppConstant.h"
#import "C_ViewEditableTextField.h"
#import "C_ScrollViewKeyboard.h"


#define POSITION @"Position"

typedef NS_ENUM(NSInteger, btnEdit) {
    btnCity = 1,
    btnState = 2,
    btnCountry = 3
};

@interface C_MP_EditLocationVC ()<UITextFieldDelegate>
{
    __weak IBOutlet C_ScrollViewKeyboard *scrlV;
    
    __weak IBOutlet C_ViewEditableTextField *viewCity;
    __weak IBOutlet C_ViewEditableTextField *viewState;
    __weak IBOutlet C_ViewEditableTextField *viewCountry;
}


@end

@implementation C_MP_EditLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _strTitle;
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    
    [self setupEditableView];
    
    
    C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
    
    viewCity.txtName.text = myWork.LocationCity;
    viewState.txtName.text = myWork.LocationState;
    viewCountry.txtName.text = myWork.LocationCountry;
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [viewCity.txtName becomeFirstResponder];
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

-(void)btnDoneClicked:(id)sender
{
    [self.view endEditing:YES];
    if ([self saveNowDone])
    {
        [self.navigationController popViewControllerAnimated:YES];
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
-(BOOL)saveNowDone
{
    NSString *strCity = [viewCity.txtName.text isNull];
    NSString *strState = [viewState.txtName.text isNull];
    NSString *strCountry= [viewCountry.txtName.text isNull];
    
    /*---------Need to check for current work now-----------*/
    BOOL isCurrent;
    C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
    if (myWork.EndMonth && myWork.EndMonth.length==0) {
        isCurrent = YES;
    }
    else{
        isCurrent = NO;
    }
  
    if ([strCity isEqualToString:@""] && isCurrent)
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter City name" withMessage:nil withViewController:self];
        return NO;
    }
    else if ([strCountry isEqualToString:@""] && isCurrent)
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter Country name" withMessage:nil withViewController:self];
        return NO;
    }
    else
    {
        //save here
        if ([_strComingFrom isEqualToString:POSITION])
        {
            C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
            myWork.LocationCity = strCity;
            myWork.LocationState = strState;
            myWork.LocationCountry = strCountry;
            
            [_obj_ProfileUpdate.arr_WorkALL replaceObjectAtIndex:_selectedIndexToUpdate withObject:myWork];
            
        }
        
        return YES;
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
