//
//  C_Find_CandidateListingVC.m
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_Find_CandidateListingVC.h"
#import "AppConstant.h"
#import "C_CandidateModel.h"

#import "C_Cell_Find_CandidateList.h"
#import "C_Cell_Find_Candidate_Info.h"
#import "C_CallViewController.h"
#import "C_TwilioClient.h"
#import "C_OtherUserProfileVC.h"
#import "C_MyProfileVC.h"
@interface C_Find_CandidateListingVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    NSMutableArray *arrContent;
    JSONParser *parser;
    NSInteger pageNum;
    /*--- To check if service is calling or not ---*/
    BOOL isCallingService;
    BOOL isAllDataRetrieved;
}
@property(nonatomic, strong)UIRefreshControl *refreshControl;
@end

@implementation C_Find_CandidateListingVC
-(void)back
{
    popView;
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isComingFromLeft)
    {
        self.title = @"Suggested Candidates";
        self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    }
    else
    {
        self.title = @"Search Results";
        self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(back)];
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }
    
    
    
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh) forControlEvents:UIControlEventValueChanged];
    [tblView addSubview:self.refreshControl];
    
    
    arrContent = [[NSMutableArray alloc]init];
    isCallingService = YES;
    isAllDataRetrieved = NO;
    
    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tblView.alpha = 0.0;
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Find_CandidateList" bundle:nil] forCellReuseIdentifier:cellFindCandidate];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Find_Candidate_Info" bundle:nil] forCellReuseIdentifier:cellFindCandidate_INFO_ID];
    
    
    /*--- Code to Show Default Refresh when view appear ---*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tblView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self refreshControlRefresh];
    });
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]removeObserver:self name:WTPresenceUpdateForClient object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPresenceUpdateForClientNotification:) name:WTPresenceUpdateForClient object:nil];
    if (_isComingFromLeft)
    {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    }
    [self updateCallAvailabilityBasedOnCachedPresenceUpdates];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:WTPresenceUpdateForClient object:nil];
}


#pragma mark - Presence Update Notification Handler
- (void) updateCallAvailabilityBasedOnCachedPresenceUpdates
{
    NSString* activityName = @"C_Find_CandidateListingVC.updateCallAvailabilityBasedOnCachedPresenceUpdates:";
    C_TwilioClient* twilioClient = [C_TwilioClient sharedInstance];
    NSMutableArray* arrayOfIndexPathsToReload = [[NSMutableArray alloc]init];
    
    //we need to loop through all of the search results and update them
    int i = 0;
    for(C_CandidateModel* searchResult in arrContent)
    {
        NSNumber* presenceObject = [twilioClient getPresenceForClient:searchResult.UserId];
        if (presenceObject != nil)
        {
            //we do have data
            BOOL isAvailable = [presenceObject boolValue];
            BOOL currentAvailbility = [searchResult.IsAvailableForCall boolValue];
            
            if (isAvailable != currentAvailbility)
            {
                //we need to reload this index path
                LOG_TWILIO(0,@"%@Reloading search result at index %d based on updated presence information",activityName,i);
                searchResult.IsAvailableForCall = presenceObject;
                [arrayOfIndexPathsToReload addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        i++;
    }
    
    //lets reload these cells
    [tblView reloadRowsAtIndexPaths:arrayOfIndexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
}
- (void) onPresenceUpdateForClientNotification:(NSNotification*)notification
{
    NSString* activityName = @"C_Find_CandidateListingVC.OnPresenceUpdateForClientNotification:";
    NSDictionary* userInfo = notification.userInfo;
    
    NSString* clientName = [userInfo objectForKey:@"Name"];
    
    C_CandidateModel* candidate = [self candidateForClientName:clientName];
    
    if (candidate != nil)
    {
        NSNumber* availability = [userInfo objectForKey:@"Available"];
        LOG_TWILIO(0,@"%@Received Twilio presence update notification for client in search result %@ who's presence is %@",activityName,clientName,availability);
        
        int indexOfCandidate = [arrContent indexOfObject:candidate];
        
        //we update our internal model with the user's availibility
        if ([availability boolValue] == YES)
        {
            //client is available
            candidate.IsAvailableForCall = [NSNumber numberWithBool:YES];
        }
        else
        {
            //client is not available
            candidate.IsAvailableForCall = [NSNumber numberWithBool:NO];
            
            
        }
        
        LOG_TWILIO(0,@"%@Reloading table index %d to reflect update in client's availibility",activityName,indexOfCandidate);
        [tblView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfCandidate inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
}

- (C_CandidateModel*)candidateForClientName:(NSString*)clientID
{
    C_CandidateModel* retVal = nil;
    
    if ([self isClientInSearchResult:clientID])
    {
        for (C_CandidateModel* searchResult in arrContent)
        {
            if ([searchResult.UserId isEqualToString:clientID])
            {
                retVal = searchResult;
                return retVal;
            }
        }
    }
    return retVal;
}

- (BOOL) isClientInSearchResult:(NSString*)clientID
{
    BOOL retVal = NO;
    
    for (C_CandidateModel* searchResult in arrContent)
    {
        if ([searchResult.UserId isEqualToString:clientID])
        {
            retVal = YES;
            return retVal;
        }
    }
    return retVal;
}

#pragma mark - Get Data
-(void)refreshControlRefresh
{
    pageNum = 1;
    isAllDataRetrieved = NO;
    [self.refreshControl beginRefreshing];
    [self getData];
}
-(void)getData
{
    /*
     <xs:element minOccurs="0" name="UserID" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="UserToken" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="Industry" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="Industry2" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="ExperienceLevel" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="LocationCity" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="LocationState" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="LocationCountry" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="Company" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="PageNumber" nillable="true" type="xs:string"/>
     @"Industry":[_dictInfoJob[@"Industry"] isNull],
     @"Industry2":[_dictInfoJob[@"Industry2"] isNull],
     @"ExperienceLevel":[_dictInfoJob[@"Experience"] isNull],
     @"Position":[_dictInfoJob[@"Position"] isNull],
     @"LocationCity":[_dictInfoJob[@"LocationCity"] isNull],
     @"LocationState":[_dictInfoJob[@"LocationState"] isNull],
     @"LocationCountry":[_dictInfoJob[@"LocationCountry"] isNull],
     @"Company":[_dictInfoJob[@"Company"] isNull],
     */
    @try
    {
        NSLog(@"%@",_dictInfoCandidate);

        NSLog(@"page Num : %ld",(long)pageNum);
        isCallingService = YES;
        showHUD_with_Title(@"Getting Candidate List");
        NSDictionary *dictParam;
        if (_isComingFromLeft)
        {
            NSString *strCompany = @"";
            if (userInfoGlobal.arr_WorkALL.count > 0) {
                C_Model_Work *myRecentWork = userInfoGlobal.arr_WorkALL[0];
                strCompany = myRecentWork.EmployerName;
            }
            dictParam = @{@"UserID":userInfoGlobal.UserId,
                          @"UserToken":userInfoGlobal.Token,
                          @"Industry":[userInfoGlobal.Industry isNull],
                          @"Industry2":[userInfoGlobal.Industry2 isNull],
                          @"ExperienceLevel":[userInfoGlobal.ExperienceLevel isNull],
                          @"LocationCity":[userInfoGlobal.LocationCity isNull],
                          @"LocationState":[userInfoGlobal.LocationState isNull],
                          @"LocationCountry":[userInfoGlobal.LocationCountry isNull],
                          @"Company":[strCompany isNull],
                          @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum]};
        }
        else
            dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"Industry":[_dictInfoCandidate[@"Industry"] isNull],
                                    @"Industry2":[_dictInfoCandidate[@"Industry2"] isNull],
                                    @"ExperienceLevel":[_dictInfoCandidate[@"ExperienceLevel"] isNull],
                                    @"LocationCity":[_dictInfoCandidate[@"LocationCity"] isNull],
                                    @"LocationState":[_dictInfoCandidate[@"LocationState"] isNull],
                                    @"LocationCountry":[_dictInfoCandidate[@"LocationCountry"] isNull],
                                    @"Company":[_dictInfoCandidate[@"Company"] isNull],
                                    @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum]};
        parser = [[JSONParser alloc]initWith_withURL:Web_CANDIDATE_LIST withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
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
    [self.refreshControl endRefreshing];
    NSLog(@"Response > %@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        //isCallingService = NO;
        hideHUD;
        [self showAlert_withTitle:@"Please Try Again"];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        //isCallingService = NO;
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
    }
    else if([objResponse objectForKey:@"SearchCandidatesResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isJobList = [[objResponse valueForKeyPath:@"SearchCandidatesResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            //got
            if (pageNum==1)
            {
                [arrContent removeAllObjects];
            }
            __weak UITableView *weaktbl = (UITableView *)tblView;
            [self setData:[objResponse valueForKeyPath:@"SearchCandidatesResult.UserDetail"] withHandler:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    hideHUD;
                });
                weaktbl.alpha = 1.0;
                [weaktbl reloadData];
            }];
            isCallingService = NO;
            
        }
        else
        {
            isCallingService = NO;
            hideHUD;
            NSString *strR = [objResponse valueForKeyPath:@"SearchCandidatesResult.ResultStatus.StatusMessage"];
            if ([strR isEqualToString:@"No Records!"])
            {
                isAllDataRetrieved = YES;
                [self showAlert_OneButton:@"No Records found"];
            }
            else if ([strR isEqualToString:@"No Records on this Page Number!"])
            {
                isAllDataRetrieved = YES;
            }
            else
            {
                isAllDataRetrieved = YES;
                [CommonMethods displayAlertwithTitle:strR withMessage:nil withViewController:self];
            }
        }
    }
    else
    {
        //isCallingService = NO;
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
    }
    
}
-(void)setData:(NSMutableArray *)arrTemp withHandler:(void(^)())compilation
{
    @try
    {
        for (NSDictionary *dict in arrTemp)
        {
            @try
            {
                [arrContent addObject:[C_CandidateModel addCandidateListModel:dict]];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
        }
        
        compilation();
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!isAllDataRetrieved)
    {
        if (!isCallingService)
        {
            CGFloat offsetY = scrollView.contentOffset.y;
            CGFloat contentHeight = scrollView.contentSize.height;
            if (offsetY > contentHeight - scrollView.frame.size.height)
            {
                pageNum = pageNum + 1;
                [self getData];
            }
        }
    }
}
-(void)showAlert_withTitle:(NSString *)title
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                           if (pageNum == 1)
                                           {
                                               popView;
                                           }
                                           
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                      {
                                          [self getData];
                                      }];
        [alert addAction:okAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        alertView.tag = 101;
        [alertView show];
    }
}
-(void)showAlert_OneButton:(NSString *)title
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                           if (pageNum == 1)
                                           {
                                               popView;
                                           }
                                       }];
        [alert addAction:CancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];[alertView show];
        alertView.tag = 102;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        switch (buttonIndex) {
            case 0:
                if (pageNum == 1)
                {
                    popView;
                }
                break;
            case 1:
                [self getData];
                break;
                
            default:
                break;
        }
    }
    else
    {
        popView;
    }
    
}


#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrContent.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_CandidateModel *myCan = (C_CandidateModel *)arrContent[indexPath.row];
    if (myCan.isShowDescription)
    {
        //13+49+13
        CGFloat heightCell = 0;
        CGFloat txtH = [myCan.Summary getHeight_withFont:kFONT_LIGHT(12.0) widht:screenSize.size.width - 44.0];
        heightCell = 13.0 + txtH + 13.0;
        return MAX(76.0, heightCell);
    }
    return 75.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_CandidateModel *myCan = (C_CandidateModel *)arrContent[indexPath.row];
    
    if (myCan.isShowDescription)
    {
        C_Cell_Find_Candidate_Info *cell = (C_Cell_Find_Candidate_Info *)[tblView dequeueReusableCellWithIdentifier:cellFindCandidate_INFO_ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblDescription.text = myCan.Summary;
        cell.btnCandidate.tag = indexPath.row;
        cell.btnLocation.tag = indexPath.row;
        
        [cell.imgVCandidate sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:myCan.PhotoURL]]];

        [cell.btnCandidate addTarget:self action:@selector(btnEdit_LocationClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnLocation addTarget:self action:@selector(btnEdit_LocationClicked:) forControlEvents:UIControlEventTouchUpInside];
        

        return cell;
    }
    else
    {
        C_Cell_Find_CandidateList *cell = (C_Cell_Find_CandidateList *)[tblView dequeueReusableCellWithIdentifier:cellFindCandidate];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblName.text = [NSString stringWithFormat:@"%@ %@",myCan.FirstName,myCan.LastName];
        cell.lblCompany.text = myCan.EmployerName;
        if ([myCan.LocationState isEqualToString:@""])
        {
            cell.lblCity_State.text = myCan.LocationCity;
        }
        else
        {
            cell.lblCity_State.text = [NSString stringWithFormat:@"%@, %@",myCan.LocationCity,myCan.LocationState];
        }
        cell.lblCountry.text = myCan.LocationCountry;
        
        [cell.imgVUserPic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:myCan.PhotoURL]]];
        
        cell.btnInfo.tag = indexPath.row;
        [cell.btnInfo addTarget:self action:@selector(btnInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([myCan.IsAvailableForCall boolValue])
        {
            cell.btnCall.enabled = YES;
        }
        else
        {
            cell.btnCall.enabled = NO;
        }
        cell.delegate = self;
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_CandidateModel *myJob = (C_CandidateModel *)arrContent[indexPath.row];
    
    if (![myJob.UserId isEqualToString:userInfoGlobal.UserId]) {
        C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
        obj.OtherUserID = myJob.UserId;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else
    {
        
        //[CommonMethods displayAlertwithTitle:@"Under construction remove from server" withMessage:nil withViewController:self];
        C_MyProfileVC *obj = [[C_MyProfileVC alloc]initWithNibName:@"C_MyProfileVC" bundle:nil];
        obj.isPush = YES;
        [self.navigationController pushViewController:obj animated:YES];
    }

}

#pragma mark - Call Enabled Cell Delegate
- (void) onCellCallButtonPressed:(UITableViewCell*)cell
{
    NSString* activityName = @"onCellCallButtonPressed:";
    
    NSIndexPath* indexForCell = [tblView indexPathForCell:cell];
    
    C_CandidateModel* user = [arrContent objectAtIndex:[indexForCell row]];;
    
   
    LOG_TWILIO(0,@"%@Call button pressed on index path [%ld,%ld] which corresponds to user %@",activityName,(long)[indexForCell section],(long)[indexForCell row],user.UserId);
    
    if ([user.IsAvailableForCall boolValue])
    {
        LOG_TWILIO(0,@"%@Attempting to place call to user %@",activityName,user.UserId);
        
        C_TwilioClient* twilioClient = [C_TwilioClient sharedInstance];
        [twilioClient connect:user.UserId];

        //launch the call view controller
        C_CallViewController* cvc = [C_CallViewController createForDialing:user.UserId];
        [self presentViewController:cvc animated:YES completion:nil];
    }
    else
    {
        //user i snot available
        LOG_TWILIO(0,@"%@User is not available for call, skipping launching of view controller",activityName);
    }
    
    
}
#pragma mark - Info + Edit
-(void)btnInfoClicked:(UIButton *)btnInfo
{
    C_CandidateModel *myCan = (C_CandidateModel *)arrContent[btnInfo.tag];
    myCan.isShowDescription = YES;
    [tblView reloadData];
}
-(void)btnEdit_LocationClicked:(UIButton *)btnInfo
{
    C_CandidateModel *myCan = (C_CandidateModel *)arrContent[btnInfo.tag];
    myCan.isShowDescription = NO;
    [tblView reloadData];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
