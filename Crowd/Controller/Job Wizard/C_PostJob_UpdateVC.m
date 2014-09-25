//
//  C_PostJob_UpdateVC.m
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_UpdateVC.h"
#import "AppConstant.h"
#import "C_PostJob_NameVC.h"
#import "C_PostJob_RolesVC.h"
#import "C_PostJob_SkillsVC.h"

#import "C_Header_ProfilePreview.h"
#import "C_Cell_SkillsProfile.h"
#import "DWTagList.h"

#import "C_PostJobModel.h"

#define ROLES @"Roles and Responsibilities"
#define SKILLS @"Skills Requirements"
@interface C_PostJob_UpdateVC ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
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

@implementation C_PostJob_UpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Job Posting";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Update" withSelector:@selector(updateJobNow)];
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    arrSectionHeader = @[ROLES,SKILLS];
    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerClass:[C_Header_ProfilePreview class] forHeaderFooterViewReuseIdentifier:cellHeaderProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_SkillsProfile" bundle:nil] forCellReuseIdentifier:cellSkillsProfilePreviewID];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self showData];
    [tblView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}

-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)showData
{
    /*--- Show Header Data ---*/
    lbl_Company.text = [[NSString stringWithFormat:@"%@",postJob_ModelClass.Company] isNull];
    lbl_JobTitle.text = [[NSString stringWithFormat:@"%@",postJob_ModelClass.Title] isNull];
    
    NSString *strCity = [[NSString stringWithFormat:@"%@",postJob_ModelClass.LocationCity] isNull];
    NSString *strState = [[NSString stringWithFormat:@"%@",postJob_ModelClass.LocationState] isNull];
    
    if ([strState isEqualToString:@""])
        lbl_City_State.text = strCity;
    else
        lbl_City_State.text = [NSString stringWithFormat:@"%@, %@",strCity,strState];
    
    lbl_Country.text = [[NSString stringWithFormat:@"%@",postJob_ModelClass.LocationCountry] isNull];
}
-(IBAction)btnEditClicked:(id)sender
{
    is_PostJob_Edit_update = @"update";
    C_PostJob_NameVC *obj = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)btnEditHeaderClicked:(UIButton *)btnEditSection
{
    is_PostJob_Edit_update = @"update";
    NSString *sectionTitle = arrSectionHeader[btnEditSection.tag];
    NSLog(@"Choose Section : %@",sectionTitle);
    
    if ([sectionTitle isEqualToString:ROLES])
    {
        C_PostJob_RolesVC *obj = [[C_PostJob_RolesVC alloc]initWithNibName:@"C_PostJob_RolesVC" bundle:nil];
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
    //myHeader.contentView.backgroundColor = [UIColor redColor];
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
        CGFloat heightSummary = [postJob_ModelClass.Responsibilities getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 5.0 + heightSummary + 5.0;
        return heightFinal;
    }
    else
    {
        NSMutableArray *arrSkills = [NSMutableArray array];
        for (NSDictionary *mySkills in postJob_ModelClass.arrSkills)
        {
            [arrSkills addObject:mySkills[@"Skill"]];
        }
        
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
        rectLBL.size.height = [postJob_ModelClass.Responsibilities getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width-20.0];
        lblSummary.frame = rectLBL;
        lblSummary.text = postJob_ModelClass.Responsibilities;
        return cell;
    }
    else
    {
        NSMutableArray *arrSkills = [NSMutableArray array];
        for (NSDictionary *mySkills in postJob_ModelClass.arrSkills)
        {
            [arrSkills addObject:mySkills[@"Skill"]];
        }
        
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
#pragma mark - UPDATE JOB NOW

-(void)updateJobNow
{
    @try
    {
        showHUD_with_Title(@"Job updating");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [dictPostNewJob setValue:userInfoGlobal.UserId forKey:@"UserID"];
//            [dictPostNewJob setValue:userInfoGlobal.Token forKey:@"UserToken"];
//            
//            [dictPostNewJob setValue:@"0" forKey:@"JobID"];
//            [dictPostNewJob setValue:@"" forKey:@"Qualifications"];
//            [dictPostNewJob setValue:@"" forKey:@"EmployerIntroduction"];
            
            NSLog(@"%@",[self getDictParam]);
            parser = [[JSONParser alloc]initWith_withURL:Web_POST_JOB withParam:[self getDictParam] withData:nil withType:kURLPost withSelector:@selector(getDataDone:) withObject:self];
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
            [CommonMethods displayAlertwithTitle:@"Job Updated" withMessage:nil withViewController:self];

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


#pragma mark - Get Updated Dictionary
-(NSDictionary *)getDictParam
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userInfoGlobal.UserId forKey:@"UserID"];
    [dict setValue:userInfoGlobal.Token forKey:@"UserToken"];
    [dict setValue:postJob_ModelClass.JobID forKey:@"JobID"];
    [dict setValue:postJob_ModelClass.Title forKey:@"Title"];
    [dict setValue:postJob_ModelClass.Company forKey:@"Company"];
    [dict setValue:postJob_ModelClass.Industry forKey:@"Industry"];
    [dict setValue:postJob_ModelClass.Industry2 forKey:@"Industry2"];

    [dict setValue:postJob_ModelClass.LocationCity forKey:@"LocationCity"];
    [dict setValue:postJob_ModelClass.LocationState forKey:@"LocationState"];
    [dict setValue:postJob_ModelClass.LocationCountry forKey:@"LocationCountry"];
    
    [dict setValue:postJob_ModelClass.ExperienceLevel forKey:@"ExperienceLevel"];
    [dict setValue:postJob_ModelClass.Responsibilities forKey:@"Responsibilities"];
    [dict setValue:postJob_ModelClass.URL forKey:@"JobURL"];
    
    [dict setValue:postJob_ModelClass.EmployerIntroduction forKey:@"EmployerIntroduction"];
    [dict setValue:postJob_ModelClass.Qualifications forKey:@"Qualifications"];

    [dict setObject:postJob_ModelClass.arrSkills forKey:@"Skills"];
    return dict;
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end