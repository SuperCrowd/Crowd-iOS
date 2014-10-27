//
//  C_OtherUserProfileVC.m
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_OtherUserProfileVC.h"
#import "AppConstant.h"

//all cell
#import "C_Header_ProfilePreview.h"
#import "C_Cell_PositionProfile.h"
#import "C_Cell_RecommendationProfile.h"
#import "C_Cell_EducationProfile.h"
#import "C_Cell_SkillsProfile.h"
#import "DWTagList.h"

#import "C_MyUser.h"

#import "C_JobsOther.h"

#import "C_MessageView.h"
#import "C_MessageModel.h"
#import "MHFacebookImageViewer.h"

#define PROFFESSIONAL_SUMMARY @"Professional Summary"
#define WORK_EXPERIENCE @"Work Experience"
#define RECOMMENDATION @"Recommendations"
#define EDUCATION @"Education"
#define SKILLS @"Skills"
@interface C_OtherUserProfileVC ()<UITableViewDataSource,UITableViewDelegate,MHFacebookImageViewerDatasource>
{
    __weak IBOutlet UITableView *tblView;
    
    /*--- Header View outlets ---*/
    __weak IBOutlet UILabel *lbl_Name;
    __weak IBOutlet UILabel *lbl_JobTitle;
    __weak IBOutlet UILabel *lbl_Location;
    __weak IBOutlet UILabel *lbl_Company;
    __weak IBOutlet UILabel *lbl_School;
    
    __weak IBOutlet UIImageView *imgVUserPic;
    
    __weak IBOutlet UIButton *btnFollow_unFollow;
    __weak IBOutlet UIImageView *imgVFavourite;
    
    /*--- Section Header Table ---*/
    NSMutableArray *arrSectionHeader;
    
    JSONParser *parser;
    
    C_MyUser *otherUserDetail;
    BOOL isFollow;
}


@end

@implementation C_OtherUserProfileVC
-(void)back
{
    popView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Profile";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
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
    
    imgVFavourite.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //getdata
        [self getData];
    });
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}
-(void)setFonts
{
    lbl_Name.font = kFONT_LIGHT(14.0);
    lbl_JobTitle.font = kFONT_LIGHT(14.0);
    lbl_Location.font = kFONT_LIGHT(14.0);
    lbl_Company.font = kFONT_LIGHT(14.0);
    lbl_School.font = kFONT_LIGHT(14.0);
}


#pragma mark - Get data
-(void)getData
{
    /*
       "UserID": "3",
       "UserToken": "Dbr/k5trWmO3XRTk3AWfX90E9jwpoh59w/EaiU9df/OkFa6bxluaKsQmBtKDNDHbBpplmFe2Zo06m6TOpxxDc0mhb1DzDq0EzXjBFsfQRVTewDXwdZZ5mxNdEp4HEdrIlx43DPPRh+5uQzOzP8bob7ckkNvE7yB9HbeZVS5I1BhjHA3/8Ac2Qf0+sjkHb8mKk/bSO1NammUBSEHHCQ0u3MNYOiR1PU+Uc1gRIkGm4CmEcYZVEdD1D1i9i26QwQSqMSs/hBy6V9wgcbrApOiKrRXOcQDv7r93",
       "OtherUserID": "3",
     */
    @try
    {
        showHUD_with_Title(@"Getting Profile");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"OtherUserID":_OtherUserID};
        parser = [[JSONParser alloc]initWith_withURL:Web_GET_USER_DETAILS withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
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
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
    else if([objResponse objectForKey:@"GetUserDetailsResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;

        NSString *strFollow = [[NSString stringWithFormat:@"%@",[[objResponse objectForKey:@"GetUserDetailsResult"] objectForKey:@"UserFollowStatus"]] isNull];
        if ([strFollow isEqualToString:@"True"])
        {
            isFollow = YES;
        }
        else
        {
            isFollow = NO;
            
        }
        [self showFollowUnFollow];
        BOOL isJobList = [[objResponse valueForKeyPath:@"GetUserDetailsResult.UserDetailResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            //got
            otherUserDetail = [C_MyUser addNewUser:[objResponse valueForKeyPath:@"GetUserDetailsResult.UserDetailResult"]];
            
            hideHUD;
            [self showData];
            [tblView reloadData];
            
        }
        else
        {
            hideHUD;
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"GetUserDetailsResult.UserDetailResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
    
}

#pragma mark - Show Data
-(void)showData
{
    /*--- Show Header Data ---*/
    lbl_Name.text = [[NSString stringWithFormat:@"%@ %@",otherUserDetail.FirstName,otherUserDetail.LastName] isNull];
    if (otherUserDetail.arr_WorkALL.count > 0) {
        C_Model_Work *myRecentWork = otherUserDetail.arr_WorkALL[0];
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
    
    if (otherUserDetail.arr_EducationALL.count > 0) {
        C_Model_Education *myRecentEducation = otherUserDetail.arr_EducationALL[0];
        lbl_School.text = myRecentEducation.Name;
    }
    else
        lbl_School.text = @"";
    
    
    [imgVUserPic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:otherUserDetail.PhotoURL]]];
    
    /*--- Now show Table Data ---*/
    [self setupTableViewData];
}
-(void)setupTableViewData
{
    //    PROFFESSIONAL_SUMMARY @"Professional Summary"
    //    WORK_EXPERIENCE @"Work Experience"
    //    RECOMMENDATION @"Recommendations"
    //    EDUCATION @"Education"
    //    SKILLS @"Skills"
    [arrSectionHeader removeAllObjects];
    if (![otherUserDetail.Summary isEqualToString:@""])
    {
        [arrSectionHeader addObject:PROFFESSIONAL_SUMMARY];
    }
    if (otherUserDetail.arr_WorkALL.count > 0)
    {
        [arrSectionHeader addObject:WORK_EXPERIENCE];
    }
    if (otherUserDetail.arr_RecommendationALL.count>0)
    {
        [arrSectionHeader addObject:RECOMMENDATION];
    }
    if (otherUserDetail.arr_EducationALL.count > 0)
    {
        [arrSectionHeader addObject:EDUCATION];
    }
    if (otherUserDetail.arr_SkillsALL.count > 0)
    {
        [arrSectionHeader addObject:SKILLS];
    }
    
    [tblView reloadData];
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
        return otherUserDetail.arr_WorkALL.count;
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
        return otherUserDetail.arr_RecommendationALL.count;
    
    else if([sectionTitle isEqualToString:EDUCATION])
        return otherUserDetail.arr_EducationALL.count;
    
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
    //myHeader.contentView.backgroundColor = [UIColor redColor];
    myHeader.lblHeader.text = arrSectionHeader[section];
    myHeader.btnEditHeader.alpha = 0.0;
    return myHeader;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = arrSectionHeader[indexPath.section];
    CGFloat heightFinal = 0;
    
    if ([sectionTitle isEqualToString:PROFFESSIONAL_SUMMARY])
    {
        CGFloat heightSummary = [otherUserDetail.Summary getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 20.0];
        heightFinal = 12.0 + heightSummary + 5.0;
        return heightFinal;
    }
    
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE])
    {
        C_Model_Work *myWork = otherUserDetail.arr_WorkALL[indexPath.row];
        CGFloat heightSummary = [myWork.Summary getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 20.0];
        heightFinal = 58.0 + heightSummary + 16.0 + 2.0;
        return MAX(heightFinal, 90.0);
    }
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
    {
        C_Model_Recommendation *myRec = otherUserDetail.arr_RecommendationALL[indexPath.row];
        CGFloat heightText = [myRec.Recommendation getHeight_withFont:kFONT_REGULAR(17.0) widht:screenSize.size.width - 20.0];
        
        NSString *strName = [NSString stringWithFormat:@"%@",myRec.RecommenderName];
        CGFloat heightName = [strName getHeight_withFont:kFONT_ITALIC_LIGHT(14.0) widht:screenSize.size.width - 20.0];
        
        heightFinal =  12.0 + heightText + 5.0 + heightName + 4.0;
        return MAX(52.0, heightFinal);
    }
    
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        C_Model_Education *myEducation = otherUserDetail.arr_EducationALL[indexPath.row];
        CGFloat heightSummary = [myEducation.Degree getHeight_withFont:kFONT_LIGHT(15.0) widht:screenSize.size.width - 20.0];
        heightFinal = 35.0 + heightSummary + 12.0;
        return MAX(heightFinal, 66.0);
    }
    
    else if([sectionTitle isEqualToString:SKILLS])
    {
        NSMutableArray *arrSkills = [NSMutableArray array];
        for (C_Model_Skills *mySkills in otherUserDetail.arr_SkillsALL)
        {
            [arrSkills addObject:mySkills.Skills];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        lblSummary = (UILabel *)[cell.contentView viewWithTag:100];
        rectLBL.size.height = [otherUserDetail.Summary getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width-20.0];
        lblSummary.frame = rectLBL;
        lblSummary.text = otherUserDetail.Summary;
        return cell;
    }
    
    else if([sectionTitle isEqualToString:WORK_EXPERIENCE])
    {
        C_Model_Work *myWork = otherUserDetail.arr_WorkALL[indexPath.row];
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
    
    else if([sectionTitle isEqualToString:RECOMMENDATION])
    {
        C_Model_Recommendation *myRec = otherUserDetail.arr_RecommendationALL[indexPath.row];
        
        C_Cell_RecommendationProfile *myRecCell = (C_Cell_RecommendationProfile *)[tblView dequeueReusableCellWithIdentifier:cellRecommendationProfilePreviewID];
        myRecCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        myRecCell.lblDescriptionText.font = kFONT_REGULAR(17.0);
        myRecCell.lblName.font = kFONT_ITALIC_LIGHT(14.0);
        
        myRecCell.lblDescriptionText.text = myRec.Recommendation;
        myRecCell.lblName.text = [NSString stringWithFormat:@"%@",myRec.RecommenderName];
        return myRecCell;
    }
    else if([sectionTitle isEqualToString:EDUCATION])
    {
        C_Model_Education *myEducation = otherUserDetail.arr_EducationALL[indexPath.row];
        C_Cell_EducationProfile *myEduCell = (C_Cell_EducationProfile *)[tblView dequeueReusableCellWithIdentifier:cellEducationProfilePreviewID];
        myEduCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        myEduCell.lblSchoolName.text = myEducation.Name;
        myEduCell.lblYear.text = [NSString stringWithFormat:@"%@ to %@",myEducation.StartYear,([myEducation.EndYear isEqualToString:@""]?@"Present":myEducation.EndYear)];
        myEduCell.lblDegree.text = myEducation.Degree;
        
        return myEduCell;
    }
    else if([sectionTitle isEqualToString:SKILLS])
    {
        NSMutableArray *arrSkills = [NSMutableArray array];
        for (C_Model_Skills *mySkills in otherUserDetail.arr_SkillsALL)
        {
            [arrSkills addObject:mySkills.Skills];
        }
        
        C_Cell_SkillsProfile *mySkillCell = (C_Cell_SkillsProfile *)[tblView dequeueReusableCellWithIdentifier:cellSkillsProfilePreviewID];
        mySkillCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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




#pragma mark - FOLLOW
-(void)showFollowUnFollow
{
    if (isFollow)
    {
        imgVFavourite.hidden = NO;
        [btnFollow_unFollow setImage:[UIImage imageNamed:@"unfollow-btn"] forState:UIControlStateNormal];
    }
    else
    {
        imgVFavourite.hidden = YES;
        [btnFollow_unFollow setImage:[UIImage imageNamed:@"follow-btn"] forState:UIControlStateNormal];
    }
}
-(IBAction)btn_Follow_unFollow_Clicked:(id)sender
{
    if (isFollow)
        [self Follow_unFollow:@"0"];
    else
        [self Follow_unFollow:@"1"];
}
-(void)Follow_unFollow:(NSString *)followUnfollow
{
    @try
    {
        showHUD_with_Title(@"Please wait");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"FollowUserID":_OtherUserID,
                                    @"Status":followUnfollow};
        parser = [[JSONParser alloc]initWith_withURL:Web_FOLLOW_UNFOLLOW withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(follow_unFollow_Successful:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)follow_unFollow_Successful:(id)objResponse
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
    else if([objResponse objectForKey:@"FollowUnfollowUserResult"])
    {
        /*--- Save data here ---*/
        BOOL isFollowRes = [[objResponse valueForKeyPath:@"FollowUnfollowUserResult.ResultStatus.Status"] boolValue];
        if (isFollowRes)
        {
            @try
            {
                isFollow = !isFollow;
                [self showFollowUnFollow];
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
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"FollowUnfollowUserResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
    
}
#pragma mark - JOBS
-(IBAction)btnJobClicked:(id)sender
{
    C_JobsOther *objP = [[C_JobsOther alloc]initWithNibName:@"C_JobsOther" bundle:nil];
    objP.title = [NSString stringWithFormat:@"%@'s job",otherUserDetail.FirstName];
    objP.OtherUserID= otherUserDetail.UserId;
    [self.navigationController pushViewController:objP animated:YES];
//    UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objP];
//    navvv.navigationBar.translucent = NO;
//    [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
//                        
//                    }];
}


#pragma mark - Message
-(IBAction)btnMessageClicked:(id)sender
{
    
    NSDictionary *dictTemp = @{@"UserId":otherUserDetail.UserId,@"PhotoURL":otherUserDetail.PhotoURL};
    NSDictionary *dictSender = @{@"SenderDetail":dictTemp};
    C_MessageModel *model = [C_MessageModel addMessageList:dictSender];
    C_MessageView *obj = [[C_MessageView alloc]initWithNibName:@"C_MessageView" bundle:nil];
    obj.message_UserInfo = model;
    [self.navigationController pushViewController:obj animated:YES];
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
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,otherUserDetail.PhotoURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
