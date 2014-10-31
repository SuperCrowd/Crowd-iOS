//
//  C_JobViewVC.m
//  Crowd
//
//  Created by MAC107 on 30/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_JobViewVC.h"
#import "AppConstant.h"
#import "C_JobListModel.h"
#import "DWTagList.h"
#import "C_Header_ProfilePreview.h"
#import "C_Cell_SkillsProfile.h"

#import "C_WebVC.h"

#import "C_OtherUserProfileVC.h"

#define MORE @"More Information"
#define ROLES @"Roles and Responsibilities"
#define SKILLS @"Skills Requirements"
#define EXPERIENCE @"Required Experience"
@interface C_JobViewVC ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    
    /*--- Header View outlets ---*/
    __weak IBOutlet UILabel *lbl_Company;
    __weak IBOutlet UILabel *lbl_JobTitle;
    __weak IBOutlet UILabel *lbl_City_State;
    __weak IBOutlet UILabel *lbl_Country;
    
    __weak IBOutlet UIView *viewBtnContainer;

    __weak IBOutlet UIImageView *imgVFavourite;
    __weak IBOutlet UIButton *btnFavourite;
    //__weak IBOutlet NSLayoutConstraint *con_viewContainerWidth;
    //__weak IBOutlet NSLayoutConstraint *con_btnFavourite;
    
    __weak IBOutlet UIButton *btnApply;
    
    /*--- Section Header Table ---*/
    NSArray *arrSectionHeader;
    
    JSONParser *parser;
}
@end


@implementation C_JobViewVC
-(void)back
{
    popView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Job Posting";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    
    if ([_obj_myJob.URL isEqualToString:@""])
    {
        arrSectionHeader = @[ROLES,SKILLS,EXPERIENCE];
    }
    else
    {
        arrSectionHeader = @[MORE,ROLES,SKILLS,EXPERIENCE];
    }

    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerClass:[C_Header_ProfilePreview class] forHeaderFooterViewReuseIdentifier:cellHeaderProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_SkillsProfile" bundle:nil] forCellReuseIdentifier:cellSkillsProfilePreviewID];
    
    
    imgVFavourite.hidden = YES;
    [self showData];
    
    if (_obj_myJob.arrSkills.count>0)
    {
        [self showViewContainer];
        [tblView reloadData];
    }
    else
    {
        viewBtnContainer.alpha = 0.0;
        tblView.alpha = 0.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getData];
        });
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
#pragma mark - Get Data
-(void)getData
{
    @try
    {
        showHUD_with_Title(@"Getting Job Details");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"JobID":_obj_myJob.JobID};
        parser = [[JSONParser alloc]initWith_withURL:Web_JOB_DETAIL withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)getDataSuccessfull:(id)objResponse
{
    NSLog(@"Response > %@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        hideHUD;
        [self showAlert_withTitle:@"Please Try Again"];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
    }
    else if([objResponse objectForKey:@"GetJobDetailsResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isJobList = [[objResponse valueForKeyPath:@"GetJobDetailsResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            @try
            {
                NSLog(@"%@",[objResponse valueForKeyPath:@"GetJobDetailsResult.JobDetailsWithSkills"]);
                _obj_myJob = [C_JobListModel addJobListModel:[objResponse valueForKeyPath:@"GetJobDetailsResult.JobDetailsWithSkills"]];//[C_JobListModel updateModel:_obj_myJob withDict:[objResponse objectForKey:@"GetJobDetailsResult"] ];
                
                _obj_myJob = [C_JobListModel updateModel:_obj_myJob withDict:[objResponse objectForKey:@"GetJobDetailsResult"] ];
                tblView.alpha = 1.0;
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            hideHUD;
            [self showData];
            [self showViewContainer];
            [tblView reloadData];
        }
        else
        {
            hideHUD;
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"SearchJobResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
    }
}


-(void)showData
{
    /*--- Show Header Data ---*/
    lbl_Company.text = [[NSString stringWithFormat:@"%@",_obj_myJob.Company] isNull];
    lbl_JobTitle.text = [[NSString stringWithFormat:@"%@",_obj_myJob.Title] isNull];
    
    NSString *strCity = [[NSString stringWithFormat:@"%@",_obj_myJob.LocationCity] isNull];
    NSString *strState = [[NSString stringWithFormat:@"%@",_obj_myJob.LocationState] isNull];
    
    if ([strState isEqualToString:@""])
        lbl_City_State.text = strCity;
    else
        lbl_City_State.text = [NSString stringWithFormat:@"%@, %@",strCity,strState];
    
    lbl_Country.text = [[NSString stringWithFormat:@"%@",_obj_myJob.LocationCountry] isNull];
}
-(void)showViewContainer
{
#warning - ADD UNFavourite Image
    if (_obj_myJob.IsJobFavorite)
    {
        imgVFavourite.hidden = NO;
        //con_btnFavourite.constant = 10.0;
        //con_viewContainerWidth.constant = 193.0;
        
        //Unfavoutire image
        [btnFavourite setTitle:@"NO" forState:UIControlStateNormal];
        [btnFavourite setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    else
    {
        //con_btnFavourite.constant = 71.0;
        //con_viewContainerWidth.constant = 254.0;
        
        imgVFavourite.hidden = YES;;
        [btnFavourite setImage:[UIImage imageNamed:@"favorite-btn"] forState:UIControlStateNormal];
    }
    
    if (_obj_myJob.IsJobApplied)
        [btnApply setImage:[UIImage imageNamed:@"applied-btn"] forState:UIControlStateNormal];
    else
        [btnApply setImage:[UIImage imageNamed:@"apply-btn"] forState:UIControlStateNormal];
    
    viewBtnContainer.alpha = 1.0;
}
#pragma mark - IBAction Method
-(void)btnMoreClicked
{
    C_WebVC *obj = [[C_WebVC alloc]initWithNibName:@"C_WebVC" bundle:nil];
    obj.strURL = _obj_myJob.URL;
    [self.navigationController pushViewController:obj animated:YES];
}
-(IBAction)btnFavouriteClicked:(id)sender
{
    //FavoriteJob
    [self favouriteNow];
}
-(IBAction)btnApplyClicked:(id)sender
{
    if (!_obj_myJob.IsJobApplied)
    {
        [self showApplyJobTitle:@"Would you like to apply for this job?"];
    }

    //ApplyToJob
    //[self applyNow];
    
}

#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionHeader.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([arrSectionHeader[section] isEqualToString:MORE])
    {
        return 0;
    }
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
    if ([arrSectionHeader[section] isEqualToString:MORE])
    {
        //213 × 28 p
        UIView *viewH = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenSize.size.width, 35.0)];
        UIButton *btnMoreInfo = [[UIButton alloc]initWithFrame:CGRectMake((screenSize.size.width/2)-(213/2), 3.0, 213.0, 28.0)];
        [btnMoreInfo setBackgroundImage:[UIImage imageNamed:@"more_info_btn"] forState:UIControlStateNormal];
        [btnMoreInfo setTitle:@"More Information" forState:UIControlStateNormal];
        btnMoreInfo.titleLabel.font = kFONT_THIN(20.0);
        [btnMoreInfo addTarget:self action:@selector(btnMoreClicked) forControlEvents:UIControlEventTouchUpInside];
        [viewH addSubview:btnMoreInfo];
        return viewH;
    }
    C_Header_ProfilePreview *myHeader = (C_Header_ProfilePreview *)[tblView dequeueReusableHeaderFooterViewWithIdentifier:cellHeaderProfilePreviewID];
    myHeader.lblHeader.text = arrSectionHeader[section];
    myHeader.btnEditHeader.alpha = 0.0;
    return myHeader;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = arrSectionHeader[indexPath.section];
    CGFloat heightFinal = 0;
    
    if ([sectionTitle isEqualToString:ROLES])
    {
        CGFloat heightSummary = [_obj_myJob.Responsibilities getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 5.0 + heightSummary + 5.0;
        return heightFinal;
    }
    else if ([sectionTitle isEqualToString:EXPERIENCE])
    {
        return 45.0;
    }
    else
    {
        NSArray *arrSkills = [_obj_myJob.arrSkills valueForKey:@"Skill"];
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
        rectLBL.size.height = [_obj_myJob.Responsibilities getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width-20.0];
        lblSummary.frame = rectLBL;
        lblSummary.text = _obj_myJob.Responsibilities;
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
        switch ([_obj_myJob.ExperienceLevel integerValue]) {
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

        NSArray *arrSkills = [_obj_myJob.arrSkills valueForKey:@"Skill"];

        C_Cell_SkillsProfile *mySkillCell = (C_Cell_SkillsProfile *)[tblView dequeueReusableCellWithIdentifier:cellSkillsProfilePreviewID];
        
        [mySkillCell.tagList setTags:arrSkills];
        mySkillCell.tagList.scrollEnabled = NO;
        [mySkillCell.tagList setCornerRadius:4.0f];
        [mySkillCell.tagList setHighlightedBackgroundColor:RGBCOLOR_DARK_BROWN];
        [mySkillCell.tagList setTextColor:[UIColor blackColor]];
        [mySkillCell.tagList setTagBackgroundColor:RGBCOLOR_DARK_BROWN];
        [mySkillCell.tagList setBorderWidth:0.0f];
        [mySkillCell.tagList setTextShadowOffset:CGSizeMake(0, 0)];
        
        mySkillCell.tagList.translatesAutoresizingMaskIntoConstraints = NO;
        return mySkillCell;
    }
    return nil;
}


#pragma mark - Favourite
-(void)favouriteNow
{
    @try
    {
        NSString *strYes = @"1";
        if (_obj_myJob.IsJobFavorite)
        {
            strYes = @"0";
        }
        showHUD_with_Title(@"Favouriting Job");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"JobID":_obj_myJob.JobID,
                                    @"Status":strYes};
        parser = [[JSONParser alloc]initWith_withURL:Web_JOB_FAVOURITE withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(favouriteSuccessful:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)favouriteSuccessful:(id)objResponse
{
    NSLog(@"Response > %@",objResponse);
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
    else if([objResponse objectForKey:@"FavoriteJobResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isJobList = [[objResponse valueForKeyPath:@"FavoriteJobResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            @try
            {
                _obj_myJob.IsJobFavorite = !_obj_myJob.IsJobFavorite;
                [self showViewContainer];;
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            hideHUD;
        }
        else
        {
            hideHUD;
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"FavoriteJobResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
    
}


#pragma mark - Apply
-(void)applyNow
{
    @try
    {
        NSString *strYes = @"1";
        if (_obj_myJob.IsJobApplied)
        {
            strYes = @"0";
        }
        showHUD_with_Title(@"Please wait");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"JobID":_obj_myJob.JobID,
                                    @"Status":strYes};
        parser = [[JSONParser alloc]initWith_withURL:Web_JOB_APPLY withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(applyNowSuccessful:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)applyNowSuccessful:(id)objResponse
{
    NSLog(@"Response > %@",objResponse);
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
    else if([objResponse objectForKey:@"ApplyToJobResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isJobList = [[objResponse valueForKeyPath:@"ApplyToJobResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            //hideHUD;
            @try
            {
                _obj_myJob.IsJobApplied = !_obj_myJob.IsJobApplied;
                [self showViewContainer];;
                
                NSString *strT = [NSString stringWithFormat:@"Your application has been submitted to %@ %@",_obj_myJob.FirstName,_obj_myJob.LastName];
                showHUD_with_Success(strT);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    hideHUD;
                });
                
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            
        }
        else
        {
            hideHUD;
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"ApplyToJobResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
    
}
#pragma mark - Poster
-(IBAction)btnPosterClicked:(id)sender
{
    C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
    obj.OtherUserID = _obj_myJob.UserId;
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark - UIAlert Delegate
-(void)showAlert_withTitle:(NSString *)title
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                   {
                                       [self applyNow];
                                   }];
        [alert addAction:okAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        alertView.tag = 102;
        [alertView show];
    }
}


-(void)showApplyJobTitle:(NSString *)title
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Apply for this job" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                   {
                                       [self applyNow];
                                   }];
        [alert addAction:okAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Apply for this job",nil];
        alertView.tag = 101;
        [alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                [self applyNow];
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                [self getData];
                break;
                
            default:
                break;
        }
    }
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
