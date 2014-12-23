//
//  C_PostJob_PreviewVC.m
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_PreviewVC.h"
#import "AppConstant.h"

#import "C_PostJob_NameVC.h"
#import "C_PostJob_RolesVC.h"
#import "C_PostJob_SkillsVC.h"
#import "C_PostJob_ExperienceVC.h"

#import "C_Header_ProfilePreview.h"
#import "C_Cell_SkillsProfile.h"
#import "DWTagList.h"

#import "C_PostJob_UpdateVC.h"

#import "C_PostJobModel.h"

#define ROLES @"Roles and Responsibilities"
#define SKILLS @"Skills Requirements"
#define EXPERIENCE @"Required Experience"
@interface C_PostJob_PreviewVC ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    
    /*--- Header View outlets ---*/
    __weak IBOutlet UILabel *lbl_Company;
    __weak IBOutlet UILabel *lbl_JobTitle;
    __weak IBOutlet UILabel *lbl_City_State;
    __weak IBOutlet UILabel *lbl_Country;
    
    /*--- Section Header Table ---*/
    NSArray *arrSectionHeader;
    
    JSONParser *parser;
}

@end

@implementation C_PostJob_PreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Job Posting Draft";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    
    arrSectionHeader = @[ROLES,SKILLS,EXPERIENCE];
    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerClass:[C_Header_ProfilePreview class] forHeaderFooterViewReuseIdentifier:cellHeaderProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_SkillsProfile" bundle:nil] forCellReuseIdentifier:cellSkillsProfilePreviewID];
}
-(void)back
{
    is_PostJob_Edit_update = @"no";
    popView;
}
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    is_PostJob_Edit_update = @"no";
    [self showData];
    [tblView reloadData];
}
-(void)showData
{
    NSLog(@"Final > %@",dictPostNewJob);

    /*--- Show Header Data ---*/
    lbl_Company.text = [[NSString stringWithFormat:@"%@",dictPostNewJob[@"Company"]] isNull];
    lbl_JobTitle.text = [[NSString stringWithFormat:@"%@",dictPostNewJob[@"Title"]] isNull];

    NSString *strCity = [[NSString stringWithFormat:@"%@",dictPostNewJob[@"LocationCity"]] isNull];
    NSString *strState = [[NSString stringWithFormat:@"%@",dictPostNewJob[@"LocationState"]] isNull];
    
    if ([strState isEqualToString:@""])
        lbl_City_State.text = strCity;
    else
        lbl_City_State.text = [NSString stringWithFormat:@"%@, %@",strCity,strState];

    lbl_Country.text = [[NSString stringWithFormat:@"%@",dictPostNewJob[@"LocationCountry"]] isNull];
}

-(IBAction)btnEditClicked:(id)sender
{
    is_PostJob_Edit_update = @"edit";
    C_PostJob_NameVC *obj = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)btnEditHeaderClicked:(UIButton *)btnEditSection
{
    is_PostJob_Edit_update = @"edit";
    NSString *sectionTitle = arrSectionHeader[btnEditSection.tag];
    NSLog(@"Choose Section : %@",sectionTitle);

    if ([sectionTitle isEqualToString:ROLES])
    {
        C_PostJob_RolesVC *obj = [[C_PostJob_RolesVC alloc]initWithNibName:@"C_PostJob_RolesVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if ([sectionTitle isEqualToString:EXPERIENCE])
    {
        C_PostJob_ExperienceVC *obj = [[C_PostJob_ExperienceVC alloc]initWithNibName:@"C_PostJob_ExperienceVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else
    {
        C_PostJob_SkillsVC *obj = [[C_PostJob_SkillsVC alloc]initWithNibName:@"C_PostJob_SkillsVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    
}
#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionHeader.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    C_Header_ProfilePreview *myHeader = (C_Header_ProfilePreview *)[tblView dequeueReusableHeaderFooterViewWithIdentifier:cellHeaderProfilePreviewID];
    myHeader.lblHeader.text = arrSectionHeader[section];
    myHeader.btnEditHeader.tag = section;
    [myHeader.btnEditHeader addTarget:self action:@selector(btnEditHeaderClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return myHeader;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = arrSectionHeader[indexPath.section];
    CGFloat heightFinal = 0;
    
    if ([sectionTitle isEqualToString:ROLES])
    {
        CGFloat heightSummary = [dictPostNewJob[@"Responsibilities"] getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 5.0 + heightSummary + 5.0;
        return heightFinal;
    }
    else if ([sectionTitle isEqualToString:EXPERIENCE])
    {
        return 45.0;
    }
    else
    {
//        NSMutableArray *arrSkills = [NSMutableArray array];
//        for (NSDictionary *mySkills in dictPostNewJob[@"Skills"])
//        {
//            [arrSkills addObject:mySkills[@"Skill"]];
//        }
        NSArray *arrSkills = [dictPostNewJob valueForKeyPath:@"Skills.Skill"];

        DWTagList *tagList = [[DWTagList alloc]initWithFrame:CGRectMake(10.0,12.0,screenSize.size.width - 20.0 -10.0 , 21.0)];
        [tagList setTags:arrSkills];
        [tagList setAutomaticResize:YES];
        [tagList display];
        [tagList fittedSize];
        return MAX(0.0, 12.0 + [tagList fittedSize].height + 12.0);
    }
    
    return 45.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = arrSectionHeader[indexPath.section];
    
    if ([sectionTitle isEqualToString:ROLES])
    {
        static NSString *cellID = @"Cell";
        UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
        UILabel *lblSummary ;
        CGRect rectLBL = CGRectMake(10.0, 5.0, screenSize.size.width-20.0,0.0);
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            
            lblSummary = [[UILabel alloc]initWithFrame:rectLBL];
            lblSummary.font = kFONT_LIGHT(14.0);
            lblSummary.numberOfLines = 0.0;
            lblSummary.tag = 100;
            [cell.contentView addSubview:lblSummary];
        }
        lblSummary = (UILabel *)[cell.contentView viewWithTag:100];
        rectLBL.size.height = [dictPostNewJob[@"Responsibilities"] getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width-20.0];
        lblSummary.frame = rectLBL;
        lblSummary.text = dictPostNewJob[@"Responsibilities"];
        return cell;
    }
    else if ([sectionTitle isEqualToString:EXPERIENCE])
    {
        static NSString *cellID = @"Cell";
        UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
        UILabel *lblExperience ;
        CGRect rectLBL = CGRectMake(10.0, 5.0, screenSize.size.width-20.0,35.0);
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            
            lblExperience = [[UILabel alloc]initWithFrame:rectLBL];
            lblExperience.font = kFONT_LIGHT(14.0);
            lblExperience.numberOfLines = 0.0;
            lblExperience.tag = 100;
            [cell.contentView addSubview:lblExperience];
        }
        lblExperience = (UILabel *)[cell.contentView viewWithTag:100];
        switch ([dictPostNewJob[@"ExperienceLevel"] integerValue]) {
            case 1:
                lblExperience.text = @"0-1 years";
                break;
            case 2:
                lblExperience.text = @"1-3 years";
                break;
            case 3:
                lblExperience.text = @"3-5 years";
                break;
            case 4:
                lblExperience.text = @"5-8 years";
                break;
            case 5:
                lblExperience.text = @"8+ years";
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    else
    {
        NSArray *arrSkills = [dictPostNewJob valueForKeyPath:@"Skills.Skill"];
        C_Cell_SkillsProfile *mySkillCell = (C_Cell_SkillsProfile *)[tblView dequeueReusableCellWithIdentifier:cellSkillsProfilePreviewID];
        
        [mySkillCell.tagList setTags:arrSkills];
        mySkillCell.tagList.scrollEnabled = NO;
        [mySkillCell.tagList setCornerRadius:4.0f];
        [mySkillCell.tagList setHighlightedBackgroundColor:RGBCOLOR_DARK_BROWN];
        [mySkillCell.tagList setTextColor:[UIColor blackColor]];
        //        [cell.tagList setBorderColor:RGBCOLOR_DARK_BROWN.CGColor];
        [mySkillCell.tagList setTagBackgroundColor:RGBCOLOR_DARK_BROWN];
        [mySkillCell.tagList setBorderWidth:0.0f];
        [mySkillCell.tagList setTextShadowOffset:CGSizeMake(0, 0)];
        
        mySkillCell.tagList.translatesAutoresizingMaskIntoConstraints = NO;
        return mySkillCell;
    }
    return nil;
}

#pragma mark -
#pragma mark - Post Job
-(IBAction)PostJobNOW:(id)sender
{
    @try
    {
        showHUD_with_Title(@"Job Posting");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [dictPostNewJob setValue:userInfoGlobal.UserId forKey:@"UserID"];
            [dictPostNewJob setValue:userInfoGlobal.Token forKey:@"UserToken"];

            [dictPostNewJob setValue:@"0" forKey:@"JobID"];
            [dictPostNewJob setValue:@"" forKey:@"EmployerIntroduction"];

            parser = [[JSONParser alloc]initWith_withURL:Web_POST_JOB withParam:dictPostNewJob withData:nil withType:kURLPost withSelector:@selector(getDataDone:) withObject:self];
        });
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please try again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)getDataDone:(id)objResponse
{
    NSLog(@"%@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
    else if([objResponse objectForKey:@"AddEditJobResult"])
    {
        /*--- Save data here ---*/
        BOOL isNewJobPostSuccess = [[objResponse valueForKeyPath:@"AddEditJobResult.ResultStatus.Status"] boolValue];
        if (isNewJobPostSuccess)
        {
            hideHUD;
            postJob_ModelClass = [C_PostJobModel addPostJobModel:[objResponse valueForKeyPath:@"AddEditJobResult.JobDetailsWithSkills"]];
                        
            C_PostJob_UpdateVC *objD = [[C_PostJob_UpdateVC alloc]initWithNibName:@"C_PostJob_UpdateVC" bundle:nil];
            objD.isNewJobPost = YES;
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objD];
            navvv.navigationBar.translucent = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:NO completion:^(BOOL finished) {
//                showHUD_with_Success(@"Job Posted Successfully");
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    hideHUD;
//                });
            }];
            
        }
        else
        {
            hideHUD;
            NSString *str = [objResponse valueForKeyPath:@"AddEditJobResult.ResultStatus.StatusMessage"];
            [CommonMethods displayAlertwithTitle:str withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
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
