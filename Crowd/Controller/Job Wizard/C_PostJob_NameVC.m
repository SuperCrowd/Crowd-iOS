//
//  C_PostJob_NameVC.m
//  Crowd
//
//  Created by MAC107 on 19/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//


#import "C_PostJob_NameVC.h"
#import "AppConstant.h"
#import "UITextFieldExtended.h"
#import "C_ScrollViewKeyboard.h"
#import "C_PostJob_IndustryVC.h"
#import "C_PostJob_IndustryListingVC.h"
#import "C_PostJobModel.h"

@interface C_PostJob_NameVC ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextFieldExtended *txtName;
}
@end

@implementation C_PostJob_NameVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IndustryList" ofType:@"plist"]];
    self.title = @"New Job Listing";
    self.navigationItem.hidesBackButton = YES;
    
    if (_isComeFromTutorial)
    {
        dictPostNewJob = [[NSMutableDictionary alloc]init];

        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(back)];
        txtName.text = @"";
    }
    else if([is_PostJob_Edit_update isEqualToString:@"edit"]||[is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
        txtName.text = ([is_PostJob_Edit_update isEqualToString:@"update"])?postJob_ModelClass.Company:dictPostNewJob[@"Company"];
    }
    else
    {
        dictPostNewJob = [[NSMutableDictionary alloc]init];
        self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
        txtName.text = @"";
    }

    /*--- Hide Center View Keyboard---*/
    //[CommonMethods HideMyKeyboard:self.mm_drawerController];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![is_PostJob_Edit_update isEqualToString:@"edit"] && ![is_PostJob_Edit_update isEqualToString:@"update"])
    {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [txtName becomeFirstResponder];
}
-(void)back
{
    popView;
}
-(void)done
{
    if ([self checkValidation])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [txtName resignFirstResponder];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtName resignFirstResponder];
}
#pragma mark - IBAction
-(IBAction)btnEditClicked:(UIButton *)btnEdit
{
    [txtName becomeFirstResponder];
}
-(BOOL)checkValidation
{
    NSString *strT = [[NSString stringWithFormat:@"%@",txtName.text]isNull];
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please enter company name" withMessage:nil withViewController:self];
        return NO;
    }

    else
    {
        if ([is_PostJob_Edit_update isEqualToString:@"update"]) {
            postJob_ModelClass.Company = [[NSString stringWithFormat:@"%@",txtName.text]isNull];
        }
        else
        {
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",txtName.text]isNull] forKey:@"Company"];
        }
        return YES;
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        if ([is_PostJob_Edit_update isEqualToString:@"edit"]||[is_PostJob_Edit_update isEqualToString:@"update"])
        {
            C_PostJob_IndustryVC *obj = [[C_PostJob_IndustryVC alloc]initWithNibName:@"C_PostJob_IndustryVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
        else
        {
            C_PostJob_IndustryListingVC *objC = [[C_PostJob_IndustryListingVC alloc]initWithNibName:@"C_PostJob_IndustryListingVC" bundle:nil];
            objC.isAdd_1 = YES;
            objC.isAdd_2 = NO;
            [self.navigationController pushViewController:objC animated:YES];

        }
    }
}
//-(BOOL)textFieldShouldClear:(UITextField *)textField
//{
//    textField.text = @"";
//    return YES;
//}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtName resignFirstResponder];
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
