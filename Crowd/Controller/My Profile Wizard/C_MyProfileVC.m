//
//  C_MyProfileVCViewController.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MyProfileVC.h"

#import "AppConstant.h"
#import "C_MyUser.h"

// all cells
#import "C_Header_ProfilePreview.h"
#import "C_Cell_PositionProfile.h"
#import "C_Cell_RecommendationProfile.h"
#import "C_Cell_EducationProfile.h"
#import "C_Cell_SkillsProfile.h"
#import "DWTagList.h"

#import "C_MP_NameVC.h"


#import "C_MP_SkillsVC.h"
#import "C_MP_WorkHistoryVC.h"
#import "C_MP_EducationHistory.h"
#import "C_MP_ProffesionalSummaryVC.h"

#import "MHFacebookImageViewer.h"

#define PROFFESSIONAL_SUMMARY @"Professional Summary"
#define WORK_EXPERIENCE @"Work Experience"
#define RECOMMENDATION @"Recommendations"
#define EDUCATION @"Education"
#define SKILLS @"Skills"
@interface C_MyProfileVC ()<UITableViewDataSource,UITableViewDelegate,MHFacebookImageViewerDatasource>
{
    __weak IBOutlet UITableView *tblView;
    
    /*--- Header View outlets ---*/
    __weak IBOutlet UILabel *lbl_Name;
    __weak IBOutlet UILabel *lbl_JobTitle;
    __weak IBOutlet UILabel *lbl_Location;
    __weak IBOutlet UILabel *lbl_Company;
    __weak IBOutlet UILabel *lbl_School;
        
    __weak IBOutlet UIImageView *imgVUserPic;
    
    
    /*--- Section Header Table ---*/
    NSMutableArray *arrSectionHeader;
    
    JSONParser *parser;
    
    C_MyUser *obj_profileUpdate;
}

@end

@implementation C_MyProfileVC
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Profile";
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    arrSectionHeader = [[NSMutableArray alloc]init];
    
    /*--- Round Imageview and load---*/
    imgVUserPic.layer.cornerRadius = (imgVUserPic.bounds.size.width)/2.0;
    imgVUserPic.layer.borderWidth = 1.25;
    imgVUserPic.layer.borderColor = RGBCOLOR_GREEN.CGColor;
    [imgVUserPic setContentMode:UIViewContentModeScaleAspectFill];
    [imgVUserPic setClipsToBounds:YES];
    [imgVUserPic setupImageViewerWithDatasource:self onOpen:^{
        
    } onClose:^{
        
    }];
    
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
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
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
    
}
#pragma mark - Show Data
-(void)showData
{
    /*--- Show Header Data ---*/
    lbl_Name.text = [[NSString stringWithFormat:@"%@ %@",userInfoGlobal.FirstName,userInfoGlobal.LastName] isNull];
    
    /*--- show most recent work history ---*/
    if (userInfoGlobal.arr_WorkALL.count > 0)
    {
        C_Model_Work *myRecentWork = userInfoGlobal.arr_WorkALL[0];
        lbl_JobTitle.text = myRecentWork.Title;
        lbl_Company.text = myRecentWork.EmployerName;
        
        NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
        if (![[myRecentWork.LocationCity isNull]isEqualToString:@""])
            [arrLoc addObject:[myRecentWork.LocationCity isNull]];
        if (![[myRecentWork.LocationState isNull]isEqualToString:@""])
            [arrLoc addObject:[myRecentWork.LocationState isNull]];
        if (![[myRecentWork.LocationCountry isNull]isEqualToString:@""])
            [arrLoc addObject:[myRecentWork.LocationCountry isNull]];
        NSString *strLoc = [arrLoc componentsJoinedByString:@","];
        lbl_Location.text = [strLoc stringByReplacingOccurrencesOfString:@"," withString:@", "];
    }
    else
    {
        lbl_JobTitle.text = @"";
        lbl_Company.text = @"";
        lbl_Location.text = @"";
    }
    
    
    /*--- show last education ---*/
    if (userInfoGlobal.arr_EducationALL.count>0) {
        C_Model_Education *myRecentEducation = userInfoGlobal.arr_EducationALL[0];
        lbl_School.text = myRecentEducation.Name;
    }
    else
       lbl_School.text = @"";
    
 
    [imgVUserPic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:userInfoGlobal.PhotoURL]]];
    
    /*--- Now show Table Data ---*/
    [self setupTableViewData];
}
-(void)setupTableViewData
{
    /*--- add data as per user's info ---*/
    [arrSectionHeader removeAllObjects];
    if (![userInfoGlobal.Summary isEqualToString:@""])
    {
        [arrSectionHeader addObject:PROFFESSIONAL_SUMMARY];
    }
    if (userInfoGlobal.arr_WorkALL.count > 0)
    {
        [arrSectionHeader addObject:WORK_EXPERIENCE];
    }
    if (userInfoGlobal.arr_RecommendationALL.count>0)
    {
        [arrSectionHeader addObject:RECOMMENDATION];
    }
    if (userInfoGlobal.arr_EducationALL.count > 0)
    {
        [arrSectionHeader addObject:EDUCATION];
    }
    if (userInfoGlobal.arr_SkillsALL.count > 0)
    {
        [arrSectionHeader addObject:SKILLS];
    }
    
    [tblView reloadData];
}
#pragma mark - IBAction
-(IBAction)btnEditClicked:(id)sender
{
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    obj_profileUpdate = [[C_MyUser alloc]init];
    obj_profileUpdate = [UserHandler_LoggedIn getMyUser_LoggedIN];
    C_MP_NameVC *obj = [[C_MP_NameVC alloc]initWithNibName:@"C_MP_NameVC" bundle:nil];
    obj.obj_ProfileUpdate = obj_profileUpdate;
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)btnEditHeaderClicked:(UIButton *)btnEditSection
{
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];

    obj_profileUpdate = [[C_MyUser alloc]init];
    obj_profileUpdate = [UserHandler_LoggedIn getMyUser_LoggedIN];
    NSString *sectionTitle = arrSectionHeader[btnEditSection.tag];
    NSLog(@"Choose Section : %@",sectionTitle);

    if ([sectionTitle isEqualToString:PROFFESSIONAL_SUMMARY])
    {
        C_MP_ProffesionalSummaryVC *obj = [[C_MP_ProffesionalSummaryVC alloc]initWithNibName:@"C_MP_ProffesionalSummaryVC" bundle:nil];
        obj.obj_ProfileUpdate = obj_profileUpdate;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE]||
            [sectionTitle isEqualToString:RECOMMENDATION])
    {
        C_MP_WorkHistoryVC *obj = [[C_MP_WorkHistoryVC alloc]initWithNibName:@"C_MP_WorkHistoryVC" bundle:nil];
        obj.obj_ProfileUpdate = obj_profileUpdate;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        C_MP_EducationHistory *obj = [[C_MP_EducationHistory alloc]initWithNibName:@"C_MP_EducationHistory" bundle:nil];
        obj.obj_ProfileUpdate = obj_profileUpdate;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sectionTitle isEqualToString:SKILLS])
    {
        C_MP_SkillsVC *obj = [[C_MP_SkillsVC alloc]initWithNibName:@"C_MP_SkillsVC" bundle:nil];
        obj.obj_ProfileUpdate = obj_profileUpdate;
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
        return userInfoGlobal.arr_WorkALL.count;
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
        return userInfoGlobal.arr_RecommendationALL.count;
    
    else if([sectionTitle isEqualToString:EDUCATION])
        return userInfoGlobal.arr_EducationALL.count;
    
    else if([sectionTitle isEqualToString:SKILLS])
        return 1;
    
    return 0;
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
    
    if ([sectionTitle isEqualToString:PROFFESSIONAL_SUMMARY])
    {
        CGFloat heightSummary = [userInfoGlobal.Summary getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 12.0 + heightSummary + 5.0;
        return heightFinal;
    }
    
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE])
    {
        C_Model_Work *myWork = userInfoGlobal.arr_WorkALL[indexPath.row];
        CGFloat heightSummary = [myWork.Summary getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 20.0];
        heightFinal = 58.0 + heightSummary + 16.0 + 2.0;
        return MAX(heightFinal, 90.0);
    }
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
    {
        C_Model_Recommendation *myRec = userInfoGlobal.arr_RecommendationALL[indexPath.row];
        CGFloat heightText = [myRec.Recommendation getHeight_withFont:kFONT_REGULAR(17.0) widht:screenSize.size.width - 20.0];
        
        NSString *strName = [NSString stringWithFormat:@"%@",myRec.RecommenderName];
        CGFloat heightName = [strName getHeight_withFont:kFONT_ITALIC_LIGHT(14.0) widht:screenSize.size.width - 20.0];
        
        heightFinal =  12.0 + heightText + 5.0 + heightName + 4.0;
        return MAX(52.0, heightFinal);
    }
    
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        C_Model_Education *myEducation = userInfoGlobal.arr_EducationALL[indexPath.row];
        CGFloat heightSummary = [myEducation.Degree getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 35.0 + heightSummary + 12.0;
        return MAX(heightFinal, 66.0);
    }
    
    else if([sectionTitle isEqualToString:SKILLS])
    {
        /*--- get array of skills ---*/
        NSArray *arrSkills = [userInfoGlobal.arr_SkillsALL valueForKey:@"Skills"];
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
    /*--- 1. Proffessional Summary ---*/
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        lblSummary = (UILabel *)[cell.contentView viewWithTag:100];
        rectLBL.size.height = [userInfoGlobal.Summary getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width-20.0];
        lblSummary.frame = rectLBL;
        lblSummary.text = userInfoGlobal.Summary;
        return cell;
    }
    /*--- 2. work history ---*/
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE])
    {
        C_Model_Work *myWork = userInfoGlobal.arr_WorkALL[indexPath.row];
        C_Cell_PositionProfile *myEduCell = (C_Cell_PositionProfile *)[tblView dequeueReusableCellWithIdentifier:cellPositionProfilePreviewID];
        myEduCell.selectionStyle = UITableViewCellSelectionStyleNone;
        /*--- setfonts ---*/
        myEduCell.lblJobTitle.font = kFONT_ITALIC_LIGHT(15.0);
        myEduCell.lblYear.font = kFONT_ITALIC_LIGHT(15.0);
        myEduCell.lblCompanyName.font = kFONT_REGULAR(15.0);
        myEduCell.lblSummary.font = kFONT_LIGHT(14.0);
        
        /*--- settext ---*/
        myEduCell.lblJobTitle.text = myWork.Title;
        myEduCell.lblYear.text = [NSString stringWithFormat:@"%@ to %@",myWork.StartYear,([myWork.EndYear isEqualToString:@""]?@"Present":myWork.EndYear)];
        myEduCell.lblCompanyName.text = myWork.EmployerName;
        myEduCell.lblSummary.text = myWork.Summary;
        
        return myEduCell;
    }
    /*--- 3. recommendation ---*/
    else if([sectionTitle isEqualToString:RECOMMENDATION])
    {
        C_Model_Recommendation *myRec = userInfoGlobal.arr_RecommendationALL[indexPath.row];
        C_Cell_RecommendationProfile *myRecCell = (C_Cell_RecommendationProfile *)[tblView dequeueReusableCellWithIdentifier:cellRecommendationProfilePreviewID];
        myRecCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        myRecCell.lblDescriptionText.font = kFONT_REGULAR(17.0);
        myRecCell.lblName.font = kFONT_ITALIC_LIGHT(14.0);
        
        myRecCell.lblDescriptionText.text = myRec.Recommendation;
        myRecCell.lblName.text = [NSString stringWithFormat:@"%@",myRec.RecommenderName];
        return myRecCell;
    }
    /*--- 4. education ---*/
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        C_Model_Education *myEducation = userInfoGlobal.arr_EducationALL[indexPath.row];
        C_Cell_EducationProfile *myEduCell = (C_Cell_EducationProfile *)[tblView dequeueReusableCellWithIdentifier:cellEducationProfilePreviewID];
        myEduCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        myEduCell.lblSchoolName.text = myEducation.Name;
        myEduCell.lblYear.text = [NSString stringWithFormat:@"%@ to %@",myEducation.StartYear,([myEducation.EndYear isEqualToString:@""]?@"Present":myEducation.EndYear)];
        myEduCell.lblDegree.text = myEducation.Degree;
        
        return myEduCell;
    }
    /*--- 5. skills ---*/
    else if([sectionTitle isEqualToString:SKILLS])
    {
        /*--- get array of skills ---*/
        NSArray *arrSkills = [userInfoGlobal.arr_SkillsALL valueForKey:@"Skills"];
        
        C_Cell_SkillsProfile *mySkillCell = (C_Cell_SkillsProfile *)[tblView dequeueReusableCellWithIdentifier:cellSkillsProfilePreviewID];
        mySkillCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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

#pragma mark - MHFacebookImageViewer Delegate
- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer
{
    return 1;
}
- (NSString*) copyRightAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer
{
    return @"";
}
- (NSString*) textAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer;
{
    return @"";
}
-  (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer
{
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,userInfoGlobal.PhotoURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer
{
    //NSLog(@"Index :: %ld",(long)index);
    return nil;
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
