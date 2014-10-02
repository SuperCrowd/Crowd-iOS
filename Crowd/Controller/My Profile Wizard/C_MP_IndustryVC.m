//
//  C_MP_IndustryVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_IndustryVC.h"
#import "AppConstant.h"
#import "C_ViewEditableTextField.h"
#import "C_MP_IndustryListVC.h"
#import "C_MyProfileVC.h"
#import "UpdateProfile.h"

#import "C_MP_SkillsVC.h"
@interface C_MP_IndustryVC ()<UITextFieldDelegate,textSelectedProtocol>
{
    __weak IBOutlet UIScrollView *scrlV;
    
    NSInteger selectedView;
    
    BOOL goToNext;
}
@end

@implementation C_MP_IndustryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Industry";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(doneClicked)];
    
    scrlV.translatesAutoresizingMaskIntoConstraints = NO;
    [self showData];
}

-(void)back
{
    popView;
}
-(void)doneClicked
{
    [self saveIndustry];

    UpdateProfile *profile = [[UpdateProfile alloc]init];
    [profile updateProfile_WithModel:_obj_ProfileUpdate withSuccessBlock:^{
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_MyProfileVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    } withFailBlock:^(NSString *strError) {
        [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
    }];
}
-(void)showData
{
    int yAxis = 150;
    int heightV = 55;
    
    if (![_obj_ProfileUpdate.Industry isEqualToString:@""])
    {
        goToNext = YES;
        C_ViewEditableTextField *objT = [[C_ViewEditableTextField alloc]initWithFrame:CGRectMake(0, yAxis, screenSize.size.width, heightV)];
        objT.tag = 1;
        
        /*--- text field ---*/
        objT.txtName.delegate = self;
        objT.txtName.tag = 0;
        objT.txtName.adjustsFontSizeToFitWidth = YES;
        objT.txtName.text = _obj_ProfileUpdate.Industry;
        
        /*--- button that user cant touch textfield ---*/
        objT.btnTextField.alpha = 1.0;
        [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        /*--- btn Edit ---*/
        [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        /*--- set label text to blank ---*/
        objT.lblName.text = @"";
        
        [scrlV addSubview:objT];
    }
    if (![_obj_ProfileUpdate.Industry2 isEqualToString:@""]) {
        
        goToNext = YES;
        C_ViewEditableTextField *objT = [[C_ViewEditableTextField alloc]initWithFrame:CGRectMake(0, yAxis+heightV+20.0, screenSize.size.width, 50)];
        objT.tag = 2;
        
        /*--- text field ---*/
        objT.txtName.delegate = self;
        objT.txtName.adjustsFontSizeToFitWidth = YES;
        objT.txtName.text = _obj_ProfileUpdate.Industry2;
        
        /*--- button that user cant touch textfield ---*/
        objT.btnTextField.alpha = 1.0;
        [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        /*--- btn Edit ---*/
        [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        /*--- set label text to blank ---*/
        objT.lblName.text = @"";
        
        [scrlV addSubview:objT];
    }
    
    if ([_obj_ProfileUpdate.Industry isEqualToString:@""] || [_obj_ProfileUpdate.Industry2 isEqualToString:@""]) {
        /*--- At last add button for another industry ---*/
        UIButton *btnAddIndustry = [[UIButton alloc]initWithFrame:CGRectMake(65.0, yAxis+heightV+20.0, screenSize.size.width-130.0, 30)];
        btnAddIndustry.tag = 51;
        btnAddIndustry.layer.cornerRadius = 10.0;
        [btnAddIndustry setTitle:@"Add Another Industry" forState:UIControlStateNormal];
        [btnAddIndustry.titleLabel setFont:kFONT_LIGHT(15.0)];
        
        [btnAddIndustry setBackgroundImage:[UIImage imageNamed:@"btnGreenBG"] forState:UIControlStateNormal];
        [btnAddIndustry addTarget:self action:@selector(btnAddNewIndustryClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrlV addSubview:btnAddIndustry];
        
        
        [scrlV setContentSize:CGSizeMake(320, btnAddIndustry.frame.origin.y + btnAddIndustry.frame.size.height + 20.0)];
    }
    
}
#pragma mark - IBAction
-(void)btnEditClicked:(UIButton *)btnEdit
{
    selectedView = btnEdit.superview.tag;
    C_MP_IndustryListVC *obj = [[C_MP_IndustryListVC alloc]initWithNibName:@"C_MP_IndustryListVC" bundle:nil];
    obj.delegate = self;
    obj.isUpdate = YES;
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)btnAddNewIndustryClicked:(UIButton *)btn
{
    C_MP_IndustryListVC *obj = [[C_MP_IndustryListVC alloc]initWithNibName:@"C_MP_IndustryListVC" bundle:nil];
    obj.delegate = self;
    obj.isUpdate = NO;
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)saveIndustry
{
    C_ViewEditableTextField *industry1 = (C_ViewEditableTextField *)[scrlV viewWithTag:1];
    if (industry1)
        _obj_ProfileUpdate.Industry = industry1.txtName.text;
    
    C_ViewEditableTextField *industry2 = (C_ViewEditableTextField *)[scrlV viewWithTag:2];
    if (industry2)
        _obj_ProfileUpdate.Industry2 = industry2.txtName.text;
}
-(IBAction)btnNextClicked:(id)sender
{
    if (goToNext)
    {
        [self saveIndustry];
        
        C_MP_SkillsVC *objC_SkillsVC = [[C_MP_SkillsVC alloc]initWithNibName:@"C_MP_SkillsVC" bundle:nil];
        objC_SkillsVC.obj_ProfileUpdate = _obj_ProfileUpdate;
        [self.navigationController pushViewController:objC_SkillsVC animated:YES];
    }
    else
    {
        [CommonMethods displayAlertwithTitle:@"Please select one industry" withMessage:nil withViewController:self];
    }
}
#pragma mark -
#pragma mark - Protocols
-(void)updateText:(NSString *)strText
{
    goToNext = YES;
    C_ViewEditableTextField *objT = (C_ViewEditableTextField *)[scrlV viewWithTag:selectedView];
    objT.txtName.text = strText;
}
-(void)addText:(NSString *)strText
{
    goToNext = YES;
    UIButton *btnAddAnotherIndustry = (UIButton *)[scrlV viewWithTag:51];
    
    C_ViewEditableTextField *objT = [[C_ViewEditableTextField alloc]initWithFrame:CGRectMake(0, btnAddAnotherIndustry.frame.origin.y, screenSize.size.width, 55.0)];
    objT.tag = 2;
    
    /*--- text field ---*/
    objT.txtName.delegate = self;
    objT.txtName.adjustsFontSizeToFitWidth = YES;
    objT.txtName.text = strText;
    
    /*--- button that user cant touch textfield ---*/
    objT.btnTextField.alpha = 1.0;
    [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    /*--- btn Edit ---*/
    [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    /*--- set label text to blank ---*/
    objT.lblName.text = @"";
    
    [scrlV addSubview:objT];
    [btnAddAnotherIndustry removeFromSuperview];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
