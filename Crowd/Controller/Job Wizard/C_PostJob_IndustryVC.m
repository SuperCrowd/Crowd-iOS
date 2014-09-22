//
//  C_PostJob_IndustryVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_IndustryVC.h"
#import "AppConstant.h"
#import "C_PostJob_IndustryListingVC.h"
#import "C_ViewEditableTextField.h"
#import "C_PostJob_PositionVC.h"

@interface C_PostJob_IndustryVC ()<UITextFieldDelegate,textSelected_PostJob_Industry>
{
    __weak IBOutlet UIScrollView *scrlV;
    
    NSInteger selectedView;
}

@end

@implementation C_PostJob_IndustryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    
    
    scrlV.translatesAutoresizingMaskIntoConstraints = NO;
    [self showData];
}
-(void)back
{
    popView;
}
-(void)btnCancelClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)showData
{
    int yAxis = 150;
    int heightV = 55;

    C_ViewEditableTextField *objT = [[C_ViewEditableTextField alloc]initWithFrame:CGRectMake(0, yAxis, screenSize.size.width, heightV)];
    objT.tag = 1;
    
    /*--- text field ---*/
    objT.txtName.delegate = self;
    objT.txtName.tag = 0;
    objT.txtName.adjustsFontSizeToFitWidth = YES;
    objT.txtName.text = [dictPostNewJob valueForKey:@"industry1"];
    
    /*--- button that user cant touch textfield ---*/
    objT.btnTextField.alpha = 1.0;
    [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    /*--- btn Edit ---*/
    [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    /*--- set label text to blank ---*/
    objT.lblName.text = @"";
    
    [scrlV addSubview:objT];

    
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
#pragma mark - IBAction
-(void)btnEditClicked:(UIButton *)btnEdit
{
    selectedView = btnEdit.superview.tag;
    C_PostJob_IndustryListingVC *obj = [[C_PostJob_IndustryListingVC alloc]initWithNibName:@"C_PostJob_IndustryListingVC" bundle:nil];
    obj.delegate = self;
    obj.isAdd_1 = NO;
    obj.isAdd_2 = NO;
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)btnAddNewIndustryClicked:(UIButton *)btn
{
    C_PostJob_IndustryListingVC *obj = [[C_PostJob_IndustryListingVC alloc]initWithNibName:@"C_PostJob_IndustryListingVC" bundle:nil];
    obj.delegate = self;
    obj.isAdd_1 = NO;
    obj.isAdd_2 = YES;
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)btnNextClicked:(id)sender
{
    C_PostJob_PositionVC *objC = [[C_PostJob_PositionVC alloc]initWithNibName:@"C_PostJob_PositionVC" bundle:nil];
    [self.navigationController pushViewController:objC animated:YES];
}
#pragma mark -
#pragma mark - Protocols
-(void)updateText:(NSString *)strText
{
    C_ViewEditableTextField *objT = (C_ViewEditableTextField *)[scrlV viewWithTag:selectedView];
    objT.txtName.text = strText;
}
-(void)addText:(NSString *)strText
{
    [dictPostNewJob setValue:strText forKey:@"industry2"];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
