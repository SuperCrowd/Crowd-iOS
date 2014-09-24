//
//  C_ProfilePreviewVC.m
//  Crowd
//
//  Created by MAC107 on 16/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_ProfilePreviewVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#import "UserHandler_LoggedIn.h"

#import "C_Header_ProfilePreview.h"
#import "C_Cell_PositionProfile.h"
#import "C_Cell_RecommendationProfile.h"
#import "C_Cell_EducationProfile.h"
#import "C_Cell_SkillsProfile.h"
#import "DWTagList.h"


#import "C_ProffessionalSummaryVC.h"
#import "C_WorkHistory.h"
#import "C_EducationHistory.h"
#import "C_SkillsVC.h"

#import "C_WelcomeVC.h"
#import "DownloadManager.h"

#import "C_TutorialVC.h"
#define PROFFESSIONAL_SUMMARY @"Professional Summary"
#define WORK_EXPERIENCE @"Work Experience"
#define RECOMMENDATION @"Recommendations"
#define EDUCATION @"Education"
#define SKILLS @"Skills"

@interface C_ProfilePreviewVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    
    /*--- Header View outlets ---*/
    __weak IBOutlet UILabel *lbl_Name;
    __weak IBOutlet UILabel *lbl_JobTitle;
    __weak IBOutlet UILabel *lbl_Location;
    __weak IBOutlet UILabel *lbl_Company;
    __weak IBOutlet UILabel *lbl_School;
    
    __weak IBOutlet UILabel *lbl_Congratulation;
    __weak IBOutlet UIButton *btn_StartUsingCrowd;

    __weak IBOutlet UIImageView *imgVUserPic;

    
    /*--- Section Header Table ---*/
    NSMutableArray *arrSectionHeader;
    
    
    JSONParser *parser;
}
@end

@implementation C_ProfilePreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Profile";
    self.navigationItem.hidesBackButton = YES;
    
#warning - Change this flag to done when press start on crowd
    [UserDefaults setValue:@"yes" forKey:PROFILE_PREVIEW];
    [UserDefaults synchronize];

    arrSectionHeader = [[NSMutableArray alloc]init];
    
    /*--- Round Imageview and load---*/
    imgVUserPic.layer.cornerRadius = (imgVUserPic.bounds.size.width)/2.0;
    imgVUserPic.layer.borderWidth = 0.25;
    imgVUserPic.layer.borderColor = [UIColor clearColor].CGColor;
    [imgVUserPic setContentMode:UIViewContentModeScaleAspectFill];
    [imgVUserPic setClipsToBounds:YES];
    
    
    
    /*--- Set fonts for all label and show data ---*/
    [self setFonts];
    
    
    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerClass:[C_Header_ProfilePreview class] forHeaderFooterViewReuseIdentifier:cellHeaderProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_PositionProfile" bundle:nil] forCellReuseIdentifier:cellPositionProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_RecommendationProfile" bundle:nil] forCellReuseIdentifier:cellRecommendationProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_EducationProfile" bundle:nil] forCellReuseIdentifier:cellEducationProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_SkillsProfile" bundle:nil] forCellReuseIdentifier:cellSkillsProfilePreviewID];

    /*--- Now show Table Data ---*/
    [self setupTableViewData];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showData];
    [tblView reloadData];
}
-(void)setFonts
{
    lbl_Name.font = kFONT_LIGHT(14.0);
    lbl_JobTitle.font = kFONT_LIGHT(14.0);
    lbl_Location.font = kFONT_LIGHT(14.0);
    lbl_Company.font = kFONT_LIGHT(14.0);
    lbl_School.font = kFONT_LIGHT(14.0);

    lbl_Congratulation.font = kFONT_REGULAR(11.0);
    
    btn_StartUsingCrowd.titleLabel.font = kFONT_THIN(18.0);
}
-(void)showData
{
    /*--- Show Header Data ---*/
    lbl_Name.text = [[NSString stringWithFormat:@"%@ %@",myUserModel.firstName,myUserModel.lastName] isNull];
    Positions *myRecentPosition = myUserModel.arrPositionUser[0];
    lbl_JobTitle.text = myRecentPosition.title;
    lbl_Company.text = myRecentPosition.company_name;
    
    
    NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
    if (![[myRecentPosition.location_city isNull]isEqualToString:@""])
        [arrLoc addObject:[myRecentPosition.location_city isNull]];
    if (![[myRecentPosition.location_state isNull]isEqualToString:@""])
        [arrLoc addObject:[myRecentPosition.location_state isNull]];
    if (![[myRecentPosition.location_country isNull]isEqualToString:@""])
        [arrLoc addObject:[myRecentPosition.location_country isNull]];
    
    NSString *strLoc = [arrLoc componentsJoinedByString:@","];
    lbl_Location.text = [strLoc stringByReplacingOccurrencesOfString:@"," withString:@", "];
    
    Education *myRecentEducation = myUserModel.arrEducationUser[0];
    lbl_School.text = myRecentEducation.schoolName;
    
    if (myUserModel.imgUserPic != nil)
        imgVUserPic.image = myUserModel.imgUserPic;
    else if((![myUserModel.pictureUrl isEqualToString:@""]))
    {
        [[DownloadManager sharedManager]downloadImagewithURL:myUserModel.pictureUrl];
        [imgVUserPic sd_setImageWithURL:myUserModel.pictureUrl];
    }
    else
        imgVUserPic.image = nil;
}
-(void)setupTableViewData
{
//    PROFFESSIONAL_SUMMARY @"Professional Summary"
//    WORK_EXPERIENCE @"Work Experience"
//    RECOMMENDATION @"Recommendations"
//    EDUCATION @"Education"
//    SKILLS @"Skills"

    if (![myUserModel.summary isEqualToString:@""])
    {
        [arrSectionHeader addObject:PROFFESSIONAL_SUMMARY];
    }
    if (myUserModel.arrPositionUser.count > 0)
    {
        [arrSectionHeader addObject:WORK_EXPERIENCE];
    }
    if (myUserModel.arrRecommendationsUser.count>0)
    {
        [arrSectionHeader addObject:RECOMMENDATION];
    }
    if (myUserModel.arrEducationUser.count > 0)
    {
        [arrSectionHeader addObject:EDUCATION];
    }
    if (myUserModel.arrSkillsUser.count > 0)
    {
        [arrSectionHeader addObject:SKILLS];
    }
    
    [tblView reloadData];
}
#pragma mark - IBAction Methods
-(IBAction)btnStartUsingCrowdClicked:(id)sender
{
#warning - Change this flag to done when press start on crowd
    [UserDefaults setValue:@"yes" forKey:PROFILE_PREVIEW];
    [UserDefaults synchronize];
    
    
    [self RegisterNOW];
}
-(IBAction)btnEditClicked:(id)sender
{
    C_WelcomeVC *obj = [[C_WelcomeVC alloc]initWithNibName:@"C_WelcomeVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)btnEditHeaderClicked:(UIButton *)btnEditSection
{
    NSString *sectionTitle = arrSectionHeader[btnEditSection.tag];
    NSLog(@"Choose Section : %@",sectionTitle);

    /*
     C_ProffessionalSummaryVC.h"
     C_WorkHistory.h"
     C_WorkHistory.h"
     C_EducationHistory.h"
     C_SkillsVC.h"
     */
    if ([sectionTitle isEqualToString:PROFFESSIONAL_SUMMARY])
    {
        C_ProffessionalSummaryVC *obj = [[C_ProffessionalSummaryVC alloc]initWithNibName:@"C_ProffessionalSummaryVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE]||
            [sectionTitle isEqualToString:RECOMMENDATION])
    {
        C_WorkHistory *obj = [[C_WorkHistory alloc]initWithNibName:@"C_WorkHistory" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        C_EducationHistory *obj = [[C_EducationHistory alloc]initWithNibName:@"C_EducationHistory" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sectionTitle isEqualToString:SKILLS])
    {
        C_SkillsVC *obj = [[C_SkillsVC alloc]initWithNibName:@"C_SkillsVC" bundle:nil];
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
    NSString *sectionTitle = arrSectionHeader[section];
    if ([sectionTitle isEqualToString:PROFFESSIONAL_SUMMARY])
        return 1;
    
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE])
        return myUserModel.arrPositionUser.count;
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
        return myUserModel.arrRecommendationsUser.count;
    
    else if([sectionTitle isEqualToString:EDUCATION])
        return myUserModel.arrEducationUser.count;
    
    else if([sectionTitle isEqualToString:SKILLS])
        return 1;
    
    return 0;//(section == arrSectionHeader.count-1)?myUserModel.arrRecommendationsUser.count:1;
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
    
    if ([sectionTitle isEqualToString:PROFFESSIONAL_SUMMARY])
    {
        CGFloat heightSummary = [myUserModel.summary getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 12.0 + heightSummary + 5.0;
        return heightFinal;
    }
    
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE])
    {
        Positions *myPosition = myUserModel.arrPositionUser[indexPath.row];
        CGFloat heightSummary = [myPosition.summary getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 20.0];
        heightFinal = 58.0 + heightSummary + 16.0 + 2.0;
        return MAX(heightFinal, 90.0);
    }
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
    {
        Recommendations *myRec = myUserModel.arrRecommendationsUser[indexPath.row];
        CGFloat heightText = [myRec.recommendationText getHeight_withFont:kFONT_REGULAR(17.0) widht:screenSize.size.width - 20.0];
        
        NSString *strName = [NSString stringWithFormat:@"%@ %@",myRec.recommender_firstName,myRec.recommender_lastName];
        CGFloat heightName = [strName getHeight_withFont:kFONT_ITALIC_LIGHT(14.0) widht:screenSize.size.width - 20.0];
        
        heightFinal =  12.0 + heightText + 5.0 + heightName + 4.0;
        return MAX(52.0, heightFinal);
    }
    
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        Education *myEducation = myUserModel.arrEducationUser[indexPath.row];
        CGFloat heightSummary = [myEducation.degree getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 35.0 + heightSummary + 12.0;
        return MAX(heightFinal, 66.0);
    }
    
    else if([sectionTitle isEqualToString:SKILLS])
    {
        NSMutableArray *arrSkills = [NSMutableArray array];
        for (Skills *mySkills in myUserModel.arrSkillsUser)
        {
            [arrSkills addObject:mySkills.name];
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
    
    if ([sectionTitle isEqualToString:PROFFESSIONAL_SUMMARY])
    {
        static NSString *cellID = @"Cell";
        UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
        UILabel *lblSummary ;
        CGRect rectLBL = CGRectMake(10.0, 12.0, screenSize.size.width-20.0,0.0);
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
        rectLBL.size.height = [myUserModel.summary getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width-20.0];
        lblSummary.frame = rectLBL;
        lblSummary.text = myUserModel.summary;
        return cell;
    }
    
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE])
    {
        Positions *myPositions = myUserModel.arrPositionUser[indexPath.row];
        C_Cell_PositionProfile *myEduCell = (C_Cell_PositionProfile *)[tblView dequeueReusableCellWithIdentifier:cellPositionProfilePreviewID];
        /*--- setfonts ---*/
        myEduCell.lblJobTitle.font = kFONT_ITALIC_LIGHT(15.0);
        myEduCell.lblYear.font = kFONT_ITALIC_LIGHT(15.0);
        myEduCell.lblCompanyName.font = kFONT_REGULAR(15.0);
        myEduCell.lblSummary.font = kFONT_LIGHT(14.0);

        /*--- settext ---*/
        myEduCell.lblJobTitle.text = myPositions.title;
        myEduCell.lblYear.text = [NSString stringWithFormat:@"%@ to %@",myPositions.startDate_year,([myPositions.endDate_year isEqualToString:@""]?@"Present":myPositions.endDate_year)];
        myEduCell.lblCompanyName.text = myPositions.company_name;
        myEduCell.lblSummary.text = myPositions.summary;

        return myEduCell;
    }
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
    {
        Recommendations *myRec = myUserModel.arrRecommendationsUser[indexPath.row];
        C_Cell_RecommendationProfile *myRecCell = (C_Cell_RecommendationProfile *)[tblView dequeueReusableCellWithIdentifier:cellRecommendationProfilePreviewID];
        
        
        myRecCell.lblDescriptionText.font = kFONT_REGULAR(17.0);
        myRecCell.lblName.font = kFONT_ITALIC_LIGHT(14.0);
        
        myRecCell.lblDescriptionText.text = myRec.recommendationText;
        myRecCell.lblName.text = [NSString stringWithFormat:@"%@ %@",myRec.recommender_firstName,myRec.recommender_lastName];
        return myRecCell;
    }
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        Education *myEducation = myUserModel.arrEducationUser[indexPath.row];
        C_Cell_EducationProfile *myEduCell = (C_Cell_EducationProfile *)[tblView dequeueReusableCellWithIdentifier:cellEducationProfilePreviewID];
        
        myEduCell.lblSchoolName.text = myEducation.schoolName;
        myEduCell.lblYear.text = [NSString stringWithFormat:@"%@ to %@",myEducation.startDate_year,([myEducation.endDate_year isEqualToString:@""]?@"Present":myEducation.endDate_year)];
        myEduCell.lblDegree.text = myEducation.degree;
        
        return myEduCell;
    }
    else if([sectionTitle isEqualToString:SKILLS])
    {
        NSMutableArray *arrSkills = [NSMutableArray array];
        for (Skills *mySkills in myUserModel.arrSkillsUser)
        {
            [arrSkills addObject:mySkills.name];
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
#pragma mark - Register
-(void)RegisterNOW
{
//    NSLog(@"%@",[UserHandler_LoggedIn getDict_To_RegisterUser]);
    
    @try
    {
        showHUD_with_Title(@"Register");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableDictionary *dictT = [UserHandler_LoggedIn getDict_To_RegisterUser];
            parser = [[JSONParser alloc]initWith_withURL:Web_IS_USER_REGISTER_OR_UPDATE withParam:dictT withData:nil withType:kURLPost withSelector:@selector(getDataDone:) withObject:self];
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
    else if([objResponse objectForKey:@"AddEditUserDetailsResult"])
    {
        /*--- Save data here ---*/
        BOOL isRegisterSuccess = [[objResponse valueForKeyPath:@"AddEditUserDetailsResult.ResultStatus.Status"] boolValue];
        if (isRegisterSuccess)
        {
            // save user now
            userInfoGlobal = [C_MyUser addNewUser:[objResponse objectForKey:@"AddEditUserDetailsResult"]];
            [UserHandler_LoggedIn saveMyUser_LoggedIN:userInfoGlobal];
            userInfoGlobal = [UserHandler_LoggedIn getMyUser_LoggedIN];
            
            [UserDefaults setValue:@"done" forKey:PROFILE_PREVIEW];
            [UserDefaults removeObjectForKey:USER_INFO];
            [UserDefaults synchronize];
            
            hideHUD;
            self.navigationController.navigationBarHidden = YES;
            C_TutorialVC *obj = [[C_TutorialVC alloc]initWithNibName:@"C_TutorialVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
        else
        {
            hideHUD;
            NSString *str = [objResponse valueForKeyPath:@"AddEditUserDetailsResult.ResultStatus.StatusMessage"];
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
