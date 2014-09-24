//
//  C_IndustryVC.m
//  Crowd
//
//  Created by MAC107 on 08/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_IndustryVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#import "C_ViewEditableTextField.h"
#import "C_SearchVC.h"

#import "C_SkillsVC.h"
#import "C_ProfilePreviewVC.h"
@interface C_IndustryVC ()<UITextFieldDelegate,textSelectedProtocol>
{
    __weak IBOutlet UIScrollView *scrlV;

    NSInteger selectedView;
    
    BOOL goToNext;
}
@end

@implementation C_IndustryVC
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Industry";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    if ([[UserDefaults objectForKey:PROFILE_PREVIEW]isEqualToString:@"yes"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    }
    
    
    NSLog(@"Industry > %@",myUserModel.industry);
    scrlV.translatesAutoresizingMaskIntoConstraints = NO;
    goToNext = NO;
    [self showData];

}
-(void)btnDoneClicked:(id)sender
{
    [self saveIndustry];

    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[C_ProfilePreviewVC class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}
-(void)showData
{
    int yAxis = 150;
    int heightV = 55;

    if (![myUserModel.industry isEqualToString:@""])
    {
        goToNext = YES;
        C_ViewEditableTextField *objT = [[C_ViewEditableTextField alloc]initWithFrame:CGRectMake(0, yAxis, screenSize.size.width, heightV)];
        objT.tag = 1;
        
        /*--- text field ---*/
        objT.txtName.delegate = self;
        objT.txtName.tag = 0;
        objT.txtName.adjustsFontSizeToFitWidth = YES;
        objT.txtName.text = myUserModel.industry;
        
        /*--- button that user cant touch textfield ---*/
        objT.btnTextField.alpha = 1.0;
        [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        /*--- btn Edit ---*/
        [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        /*--- set label text to blank ---*/
        objT.lblName.text = @"";
        
        [scrlV addSubview:objT];
    }
    if (![myUserModel.industry2 isEqualToString:@""]) {
     
        goToNext = YES;
        C_ViewEditableTextField *objT = [[C_ViewEditableTextField alloc]initWithFrame:CGRectMake(0, yAxis+heightV+20.0, screenSize.size.width, 50)];
        objT.tag = 2;
        
        /*--- text field ---*/
        objT.txtName.delegate = self;
        objT.txtName.adjustsFontSizeToFitWidth = YES;
        objT.txtName.text = myUserModel.industry2;
        
        /*--- button that user cant touch textfield ---*/
        objT.btnTextField.alpha = 1.0;
        [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        /*--- btn Edit ---*/
        [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        /*--- set label text to blank ---*/
        objT.lblName.text = @"";
        
        [scrlV addSubview:objT];
    }
    
    if ([myUserModel.industry isEqualToString:@""] || [myUserModel.industry2 isEqualToString:@""]) {
        /*--- At last add button for another industry ---*/
        UIButton *btnAddIndustry = [[UIButton alloc]initWithFrame:CGRectMake(65.0, yAxis+heightV+20.0, screenSize.size.width-130.0, 30)];
        btnAddIndustry.tag = 51;
        btnAddIndustry.layer.cornerRadius = 10.0;
        [btnAddIndustry setTitle:@"Add Another Industry" forState:UIControlStateNormal];
        [btnAddIndustry.titleLabel setFont:kFONT_LIGHT(15.0)];

        [btnAddIndustry setBackgroundImage:[UIImage imageNamed:@"btnGreenBG"] forState:UIControlStateNormal];
//        btnAddIndustry.backgroundColor = RGBCOLOR(72.0, 190.0, 128.0);
        [btnAddIndustry addTarget:self action:@selector(btnAddNewIndustryClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrlV addSubview:btnAddIndustry];
        
        
        [scrlV setContentSize:CGSizeMake(320, btnAddIndustry.frame.origin.y + btnAddIndustry.frame.size.height + 20.0)];
    }
    
}
#pragma mark - IBAction
-(void)btnEditClicked:(UIButton *)btnEdit
{
    selectedView = btnEdit.superview.tag;
    C_SearchVC *obj = [[C_SearchVC alloc]initWithNibName:@"C_SearchVC" bundle:nil];
    obj.delegate = self;
    obj.isUpdate = YES;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:obj];
    nav.navigationBar.translucent = NO;

    [self presentViewController:nav animated:YES completion:^{}];
}
-(void)btnAddNewIndustryClicked:(UIButton *)btn
{
    C_SearchVC *obj = [[C_SearchVC alloc]initWithNibName:@"C_SearchVC" bundle:nil];
    obj.delegate = self;
    obj.isUpdate = NO;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:obj];
    nav.navigationBar.translucent = NO;

    [self presentViewController:nav animated:YES completion:^{}];
}
-(void)saveIndustry
{
    C_ViewEditableTextField *industry1 = (C_ViewEditableTextField *)[scrlV viewWithTag:1];
    if (industry1)
        myUserModel.industry = industry1.txtName.text;
    
    C_ViewEditableTextField *industry2 = (C_ViewEditableTextField *)[scrlV viewWithTag:2];
    if (industry2)
        myUserModel.industry2 = industry2.txtName.text;
    
    [CommonMethods saveMyUser:myUserModel];
    myUserModel = [CommonMethods getMyUser];
}
-(IBAction)btnNextClicked:(id)sender
{
    if (goToNext)
    {
        [self saveIndustry];
        
        C_SkillsVC *objC_SkillsVC = [[C_SkillsVC alloc]initWithNibName:@"C_SkillsVC" bundle:nil];
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
