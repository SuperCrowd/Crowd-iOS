//
//  C_PostJob_IndustryVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_IndustryVC.h"
#import "AppConstant.h"
#import "C_PostJob_NameVC.h"

#import "C_PostJob_IndustryListingVC.h"
#import "C_ViewEditableTextField.h"
#import "C_PostJob_PositionVC.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"

#import "Update_PostJob.h"
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
    if([is_PostJob_Edit_update isEqualToString:@"edit"] ||
        [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
    
    scrlV.translatesAutoresizingMaskIntoConstraints = NO;
    [self showData];
}
-(void)back
{
    if ([is_PostJob_Edit_update isEqualToString:@"no"])
    {
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_PostJob_NameVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    }
    else
        popView;
}
-(void)done
{
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        Update_PostJob *job = [[Update_PostJob alloc]init];
        [job update_JobPost_with_withSuccessBlock:^{
            /*--- First update list model so fire notification then pop to update view---*/
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateJobListModel" object:nil];
            for (UIViewController *vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[C_PostJob_UpdateVC class]])
                {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        } withFailBlock:^(NSString *strError) {
            [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
        }];
    }
    else
    {
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_PostJob_PreviewVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    }
    
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
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
        objT.txtName.text = postJob_ModelClass.Industry;
    else
        objT.txtName.text = [dictPostNewJob valueForKey:@"Industry"];
    
    /*--- button that user cant touch textfield ---*/
    objT.btnTextField.alpha = 1.0;
    [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    /*--- btn Edit ---*/
    [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    /*--- set label text to blank ---*/
    objT.lblName.text = @"Industry";
    
    CGRect btnEditFrame = objT.btnEdit.frame;
    btnEditFrame.origin.x = btnEditFrame.origin.x - 10.0;
    objT.btnEdit.frame = btnEditFrame;
    
    [scrlV addSubview:objT];

    BOOL showInd2 = NO;
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        if (![postJob_ModelClass.Industry2 isEqualToString:@""])
            showInd2 = YES;
    }
    else
    {
        if (![dictPostNewJob[@"Industry2"] isEqualToString:@""])
            showInd2 = YES;
    }
    if (showInd2)
    {
        C_ViewEditableTextField *objT = [[C_ViewEditableTextField alloc]initWithFrame:CGRectMake(0, yAxis+heightV+20.0, screenSize.size.width, heightV)];
        objT.tag = 2;
        
        /*--- text field ---*/
        objT.txtName.delegate = self;
        objT.txtName.adjustsFontSizeToFitWidth = YES;
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
            objT.txtName.text = postJob_ModelClass.Industry2;
        else
            objT.txtName.text = [dictPostNewJob valueForKey:@"Industry2"];
        
        /*--- button that user cant touch textfield ---*/
        objT.btnTextField.alpha = 1.0;
        [objT.btnTextField addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        /*--- btn Edit ---*/
        [objT.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        /*--- set label text to blank ---*/
        objT.lblName.text = @"Industry";
        
        CGRect btnEditFrame = objT.btnEdit.frame;
        btnEditFrame.origin.x = btnEditFrame.origin.x - 10.0;
        objT.btnEdit.frame = btnEditFrame;
        [scrlV addSubview:objT];
        return;
    }

    /*--- At last add button for another industry ---*/
    UIButton *btnAddIndustry = [[UIButton alloc]initWithFrame:CGRectMake(65.0, yAxis+heightV+20.0, screenSize.size.width-130.0, 30)];
    btnAddIndustry.tag = 51;
    btnAddIndustry.layer.cornerRadius = 10.0;
    [btnAddIndustry setTitle:@"Add Another Industry" forState:UIControlStateNormal];
    [btnAddIndustry.titleLabel setFont:kFONT_THIN(15.0)];
    
    [btnAddIndustry setBackgroundImage:[UIImage imageNamed:@"btnGreenBG"] forState:UIControlStateNormal];
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
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        if (selectedView == 1)
            postJob_ModelClass.Industry = strText;
        else
            postJob_ModelClass.Industry2 = strText;
    }
    
    else
    {
        if (selectedView == 1)
            [dictPostNewJob setValue:strText forKey:@"Industry"];
        else
            [dictPostNewJob setValue:strText forKey:@"Industry2"];
    }
    
}
-(void)addText:(NSString *)strText
{
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        postJob_ModelClass.Industry2 = strText;
    }
    else
    {
        [dictPostNewJob setValue:strText forKey:@"Industry2"];
    }

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
    objT.lblName.text = @"Industry";
    
    CGRect btnEditFrame = objT.btnEdit.frame;
    btnEditFrame.origin.x = btnEditFrame.origin.x - 10.0;
    objT.btnEdit.frame = btnEditFrame;
    [scrlV addSubview:objT];
    [btnAddAnotherIndustry removeFromSuperview];
}


#pragma mark - Cancel Clicked
-(void)btnCancelClicked:(id)sender
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your job has not been posted yet. if you leave it will be lost. This can not be undone." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* LeaveAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                      {
                                          is_PostJob_Edit_update = @"no";
                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                      }];
        [alert addAction:LeaveAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your job has not been posted yet. if you leave it will be lost. This can not be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave",nil];[alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            is_PostJob_Edit_update = @"no";
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}



#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
