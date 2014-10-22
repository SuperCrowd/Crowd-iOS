//
//  C_MyCrowdVC.m
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MyCrowdVC.h"
#import "AppConstant.h"
#import "C_Header_ProfilePreview.h"
#import "C_Cell_Follower.h"
#import "C_FollowUser.h"


#import "C_OtherUserProfileVC.h"
@interface C_MyCrowdVC ()<UITableViewDataSource,UITableViewDelegate>
{
     __weak IBOutlet UITableView *tblView;
    JSONParser *parser;
    NSArray *arrSectionHeader;
    NSMutableArray *arrFollwing,*arrFollowers;
    BOOL isCallingService;
    BOOL isAllDataRetrieved;
    NSInteger pageNum;
}
@property(nonatomic, strong)UIRefreshControl *refreshControl;
@end

@implementation C_MyCrowdVC
-(void)dismissME
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Crowd";
    if (_isPresented)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem =  [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(dismissME)];
    }
    else
    {
        self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    }
    
    
    arrSectionHeader = @[@"I Am Following",@"Following Me"];
    arrFollwing = [[NSMutableArray alloc]init];
    arrFollowers = [[NSMutableArray alloc]init];
    
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh) forControlEvents:UIControlEventValueChanged];
    [tblView addSubview:self.refreshControl];
    
    isCallingService = YES;
    isAllDataRetrieved = NO;
    
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.alpha = 0.0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerClass:[C_Header_ProfilePreview class] forHeaderFooterViewReuseIdentifier:cellHeaderProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Follower" bundle:nil] forCellReuseIdentifier:cellFollowerID];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //getdata
        [tblView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self refreshControlRefresh];
    });

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isPresented)
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    else
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}

-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
#pragma mark - Get data
-(void)refreshControlRefresh
{
    pageNum = 1;
    isAllDataRetrieved = NO;
    [self.refreshControl beginRefreshing];
    [self getData];
}

-(void)getData
{
    @try
    {
         showHUD_with_Title(@"Getting My Crowd");
        isCallingService = YES;
       
        
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum]};
        parser = [[JSONParser alloc]initWith_withURL:Web_MY_CROWD withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
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
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }
    else if([objResponse objectForKey:@"GetMyCrowdResult"])
    {
        /*--- Save data here ---*/
        BOOL isJobList = [[objResponse valueForKeyPath:@"GetMyCrowdResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            NSDictionary *dictResult = [objResponse objectForKey:@"GetMyCrowdResult"];
            //got
            //user’s name, Current Job Title, Current Employer, and Location (City and State only)
            //NSLog(@"%@",[dictResult objectForKey:@"FollowingMeUser"]);// Following users
            //NSLog(@"%@",[dictResult objectForKey:@"IAmFollowingUser"]);// Followed users
            if (pageNum==1)
            {
                [arrFollwing removeAllObjects];
                [arrFollowers removeAllObjects];
            }
            NSArray *arrFollow = [dictResult objectForKey:@"FollowingMeUser"];
            [arrFollow enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                C_FollowUser *user = [C_FollowUser addNewUser:obj];
                [arrFollowers addObject:user];
            }];
            
            NSArray *arrMyFollowers = [dictResult objectForKey:@"IAmFollowingUser"];
            [arrMyFollowers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                C_FollowUser *user = [C_FollowUser addNewUser:obj];
                [arrFollwing addObject:user];
            }];
            tblView.alpha = 1.0;
            
            [tblView reloadData];
            hideHUD;
            isCallingService = NO;
            
        }
        else
        {
            isCallingService = NO;
            hideHUD;
            NSString *strR = [objResponse valueForKeyPath:@"GetMyCrowdResult.ResultStatus.StatusMessage"];
            if ([strR isEqualToString:@"No Records!"])
            {
                isAllDataRetrieved = YES;
                if (pageNum == 1) {
                    [CommonMethods displayAlertwithTitle:strR withMessage:@"No Records found" withViewController:self];
                }
            }
            else if ([strR isEqualToString:@"No Records on this Page Number!"])
            {
                isAllDataRetrieved = YES;
            }
            else
            {
                [CommonMethods displayAlertwithTitle:strR withMessage:nil withViewController:self];
            }

        }
    }
    else
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
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

#pragma mark - TblViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionHeader.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return [arrFollwing count];
    
    else if(section==1)
        return [arrFollowers count];
    
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
    return 91.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        C_FollowUser *followerUser = arrFollwing[indexPath.row];
        C_Cell_Follower *myFollowCell = (C_Cell_Follower *)[tblView dequeueReusableCellWithIdentifier:cellFollowerID];
        myFollowCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        C_Model_Work_Follower *JobModel ;
        if (followerUser.arr_WorkALL.count>0) {
            JobModel = followerUser.arr_WorkALL[0];
        }
        /*--- settext ---*///
        myFollowCell.lblJobTitle.text = JobModel.Title;
        NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
        if (JobModel.LocationCity.length>0) {
            [arrLoc addObject:JobModel.LocationCity];
        }
        
        if (JobModel.LocationState.length>0) {
            [arrLoc addObject:JobModel.LocationState];
        }
        myFollowCell.lblLocation.text = [arrLoc componentsJoinedByString:@","] ;
        myFollowCell.lblCompanyName.text = [JobModel.EmployerName isNull];
        myFollowCell.lblName.text = [NSString stringWithFormat:@"%@,%@",followerUser.FirstName,followerUser.LastName];
        [myFollowCell.ivPhoto sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:followerUser.PhotoURL]]];
        return myFollowCell;
    }
    
    else if(indexPath.section==1)
    {
        C_FollowUser *followerUser = arrFollowers[indexPath.row];
        C_Cell_Follower *myFollowCell = (C_Cell_Follower *)[tblView dequeueReusableCellWithIdentifier:cellFollowerID];
        myFollowCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        /*--- settext ---*/
        C_Model_Work_Follower *JobModel ;
        if (followerUser.arr_WorkALL.count>0) {
            JobModel = followerUser.arr_WorkALL[0];
        }
        /*--- settext ---*/
        myFollowCell.lblJobTitle.text = JobModel.Title;
        NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
        if (JobModel.LocationCity.length>0) {
            [arrLoc addObject:JobModel.LocationCity];
        }
        
        if (JobModel.LocationState.length>0) {
            [arrLoc addObject:JobModel.LocationState];
        }
        myFollowCell.lblLocation.text = [arrLoc componentsJoinedByString:@","] ;
        myFollowCell.lblCompanyName.text = [JobModel.EmployerName isNull];
        myFollowCell.lblName.text = [NSString stringWithFormat:@"%@,%@",followerUser.FirstName,followerUser.LastName];
        [myFollowCell.ivPhoto sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:followerUser.PhotoURL]]];
        return myFollowCell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strOtherUserID ;
    if (indexPath.section==0)
    {
        C_FollowUser *followerUser = arrFollwing[indexPath.row];
        strOtherUserID = followerUser.UserId;
    }
    else
    {
        C_FollowUser *followerUser = arrFollowers[indexPath.row];
        strOtherUserID = followerUser.UserId;
    }
    if (_isPresented)
    {
        /*--- Dismiss view with delegate ---*/
        if ([_strReceiverID isEqualToString:strOtherUserID])
        {
            showHUD_with_error(@"You can not select user with whom you are chatting.");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                hideHUD;
            });
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(userSelected:)])
            {
                [self.delegate userSelected:strOtherUserID];
                [self dismissME];
            }
        }
        
    }
    else
    {
        C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
        obj.OtherUserID = strOtherUserID;
        [self.navigationController pushViewController:obj animated:YES];
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
