//
//  C_MyJobsVC.m
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//


#import "AppConstant.h"
#import "C_Cell_FindAJobList.h"
#import "C_Cell_FindAJobList_Info.h"
#import "C_Header_ProfilePreview.h"
#import "C_JobListModel.h"
#import "C_MyJobsVC.h"
#import "CustomBtn.h"


#import "C_PostJob_UpdateVC.h"
#import "C_JobViewVC.h"

#import "C_PostJob_NameVC.h"

#define APPLIED @"Jobs Applied To"
#define FAVORITE @"Favorites"
#define POSTED @"Posted By Me"

@interface C_MyJobsVC ()<UITableViewDataSource,UITableViewDelegate,postJobProtocol>
{
    __weak IBOutlet UITableView *tblView;
    JSONParser *parser;
    NSMutableArray *arrSectionHeader;
    NSMutableArray *arrPosted,*arrApplied,*arrFavorites;
    BOOL isCallingService;
    BOOL isAllDataRetrieved;
    NSInteger pageNum;
    
    __weak IBOutlet NSLayoutConstraint *constraing_table_bottom;
    __weak IBOutlet UIButton *btnNewJobListing;
}
@property(nonatomic, strong)UIRefreshControl *refreshControl;
@end

@implementation C_MyJobsVC
-(void)dismissME
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Jobs";
    if (_isPresented)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem =  [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(dismissME)];
    }
    else
    {
        self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    }
    
    arrSectionHeader = [[NSMutableArray alloc]init];
    arrApplied = [[NSMutableArray alloc]init];
    arrPosted = [[NSMutableArray alloc]init];
    arrFavorites = [[NSMutableArray alloc]init];
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh) forControlEvents:UIControlEventValueChanged];
    [tblView addSubview:self.refreshControl];
    
    
    isCallingService = YES;
    isAllDataRetrieved = NO;
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tblView.alpha = 0.0;
    [tblView registerClass:[C_Header_ProfilePreview class] forHeaderFooterViewReuseIdentifier:cellHeaderProfilePreviewID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_FindAJobList" bundle:nil] forCellReuseIdentifier:cellFindJobListID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_FindAJobList_Info" bundle:nil] forCellReuseIdentifier:cellFindJobList_INFO_ID];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tblView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self refreshControlRefresh];
    });

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tblView reloadData];
    if (_isPresented)
    {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        constraing_table_bottom.constant = 0.0;
        btnNewJobListing.hidden = YES;
    }
    else
    {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        constraing_table_bottom.constant = 105.0;
        btnNewJobListing.hidden = NO;
    }
    
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(IBAction)btnNewJobListingClicked:(id)sender
{
    is_PostJob_Edit_update = @"no";
    C_PostJob_NameVC *obj = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
    obj.isComeFromRegularView = YES;
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark - Get data
-(void)refreshControlRefresh
{
    pageNum = 1;
    isAllDataRetrieved = NO;
    [self.refreshControl beginRefreshing];
    [self getData];
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

-(void)getData
{
    @try
    {
        showHUD_with_Title(@"Getting My Jobs");
        isCallingService = YES;
        
        
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum],
                                    @"OtherUserID":userInfoGlobal.UserId};
        parser = [[JSONParser alloc]initWith_withURL:Web_MY_JOBS withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
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
    else if([objResponse objectForKey:@"GetUserJobsResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        

        BOOL isJobList = [[objResponse valueForKeyPath:@"GetUserJobsResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            NSDictionary *dictResult = [objResponse objectForKey:@"GetUserJobsResult"];
            //got
            //user’s name, Current Job Title, Current Employer, and Location (City and State only)
            //NSLog(@"%@",[dictResult objectForKey:@"FollowingMeUser"]);// Following users
            //NSLog(@"%@",[dictResult objectForKey:@"IAmFollowingUser"]);// Followed users
            if (pageNum==1)
            {
                [arrPosted removeAllObjects];
                [arrFavorites removeAllObjects];
                [arrApplied removeAllObjects];
            }
            [arrSectionHeader removeAllObjects];

           NSArray *arrPost= [dictResult objectForKey:@"PostedByMe"];
           [arrPost enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               [arrPosted addObject:[C_JobListModel addJobListModel:obj]];
           }];
           
           NSArray *arrFav = [dictResult objectForKey:@"JobFavorited"];
           [arrFav enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               [arrFavorites addObject:[C_JobListModel addJobListModel:obj]];
           }];
            
            /*--- If this flag is YES do not show job applied ---*/
            if (!_isPresented)
            {
                NSArray *arrAppl = [dictResult objectForKey:@"JobApplied"];
                [arrAppl enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [arrApplied addObject:[C_JobListModel addJobListModel:obj]];
                }];
            }
            

            if (arrPosted.count>0) {
                [arrSectionHeader addObject:POSTED];
            }
            if (arrFavorites.count>0) {
                [arrSectionHeader addObject:FAVORITE];
            }
            if (arrApplied.count>0) {
                [arrSectionHeader addObject:APPLIED];
            }

            
            [tblView reloadData];
            hideHUD;
            isCallingService = NO;
            
        }
        else
        {
            isCallingService = NO;
            hideHUD;
            NSString *strR = [objResponse valueForKeyPath:@"GetMyCrowdResult.ResultStatus.StatusMessage"];
            if (strR.length==0) {
                strR = @"No Records!";
            }
            if ([strR isEqualToString:@"No Records!"])
            {
                isAllDataRetrieved = YES;
                if (pageNum == 1) {
                    [CommonMethods displayAlertwithTitle:strR withMessage:@"You have not favorited or posted any jobs yet." withViewController:self];
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
#pragma mark - TblViewDatasource
-(NSMutableArray*)getArrayForIndexPath:(NSIndexPath*)index{
    NSString *strTitle = [arrSectionHeader objectAtIndex:index.section];
    if ([strTitle isEqualToString:POSTED])
        return arrPosted ;
    else if([strTitle isEqualToString:APPLIED])
        return arrApplied ;
    else if([strTitle isEqualToString:FAVORITE])
        return arrFavorites ;
    else
        return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionHeader.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    NSString *strTitle = [arrSectionHeader objectAtIndex:section];
    if ([strTitle isEqualToString:POSTED])
        return [arrPosted count];
    else if([strTitle isEqualToString:APPLIED])
        return [arrApplied count];
    else if([strTitle isEqualToString:FAVORITE])
        return [arrFavorites count];
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
    NSArray *arr = [self getArrayForIndexPath:indexPath];
    C_JobListModel *myJob = (C_JobListModel *)arr[indexPath.row];
    if (myJob.isShowDescription)
    {
        //13+49+13
        CGFloat heightCell = 0;
        CGFloat txtH = [myJob.Responsibilities getHeight_withFont:kFONT_LIGHT(12.0) widht:screenSize.size.width - 44.0];
        heightCell = 13.0 + txtH + 13.0;
        return MAX(76.0, heightCell);
    }

    return 75.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrList = [self getArrayForIndexPath:indexPath];
    C_JobListModel *myJob = (C_JobListModel *)arrList[indexPath.row];
    
    if (myJob.isShowDescription)
    {
        C_Cell_FindAJobList_Info *cell = (C_Cell_FindAJobList_Info *)[tblView dequeueReusableCellWithIdentifier:cellFindJobList_INFO_ID ];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblDescription.text = myJob.Responsibilities;
        cell.btnEditJob.tag = indexPath.row;
        cell.btnLocation.tag = indexPath.row;
        cell.btnLocation.indexofBtn = indexPath;
        cell.btnEditJob.indexofBtn = indexPath;
        [cell.btnEditJob addTarget:self action:@selector(btnEdit_LocationClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnLocation addTarget:self action:@selector(btnEdit_LocationClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        C_Cell_FindAJobList *cell = (C_Cell_FindAJobList *)[tblView dequeueReusableCellWithIdentifier:cellFindJobListID];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblTitle.text = myJob.Title;
        cell.lblCompany.text = myJob.Company;
        if ([myJob.LocationState isEqualToString:@""])
        {
            cell.lblCity_State.text = myJob.LocationCity;
        }
        else
        {
            cell.lblCity_State.text = [NSString stringWithFormat:@"%@, %@",myJob.LocationCity,myJob.LocationState];
        }
        cell.lblCountry.text = myJob.LocationCountry;
        cell.lblTime.text = [NSString stringWithFormat:@"Posted: %@",myJob.dateStr];
        
        cell.btnInfo.tag = indexPath.row;
        cell.btnInfo.indexofBtn = indexPath;
        [cell.btnInfo addTarget:self action:@selector(btnInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrList = [self getArrayForIndexPath:indexPath];
    C_JobListModel *myJob = (C_JobListModel *)arrList[indexPath.row];
    
    if (_isPresented)
    {
        /*--- Dismiss view with delegate ---*/
        if ([self.delegate respondsToSelector:@selector(jobSelected:withJobCreaterID:)])
        {
            [self.delegate jobSelected:myJob.JobID withJobCreaterID:myJob.UserId];
            [self dismissME];
        }
    }
    else
    {
        if ([myJob.UserId isEqualToString:userInfoGlobal.UserId])
        {
            //postJob_ModelClass = [C_PostJobModel addPostJobModel:[objResponse valueForKeyPath:@"AddEditJobResult.JobDetailsWithSkills"]];
            
            /*--- Send current object and get data then fill object after that if user press update then replace object so this will appear here ---*/
            C_PostJob_UpdateVC *objD = [[C_PostJob_UpdateVC alloc]initWithNibName:@"C_PostJob_UpdateVC" bundle:nil];
            objD.delegate = self;
            objD.obj_JobListModel = myJob;
            objD.strComingFrom = @"FindAJob";
            [self.navigationController pushViewController:objD animated:YES];
            
        }
        else
        {
            C_JobViewVC *obj = [[C_JobViewVC alloc]initWithNibName:@"C_JobViewVC" bundle:nil];
            obj.obj_myJob = myJob;
            [self.navigationController pushViewController:obj animated:YES];
        }
    }
}

#pragma mark - Info + Edit
-(void)btnInfoClicked:(CustomBtn *)btnInfo
{
    NSLog(@"%@",btnInfo.indexofBtn);
    if (btnInfo.indexofBtn!=nil) {
        NSArray *arrList = [self getArrayForIndexPath:btnInfo.indexofBtn];
        C_JobListModel *myJob = (C_JobListModel *)arrList[btnInfo.indexofBtn.row];
        myJob.isShowDescription = YES;
        [tblView reloadData];
    }
    
}
-(void)btnEdit_LocationClicked:(CustomBtn *)btnInfo
{
    NSLog(@"%@",btnInfo.indexofBtn);
    if (btnInfo.indexofBtn!=nil) {
        NSArray *arrList = [self getArrayForIndexPath:btnInfo.indexofBtn];
        C_JobListModel *myJob = (C_JobListModel *)arrList[btnInfo.indexofBtn.row];
        myJob.isShowDescription = NO;
        [tblView reloadData];
    }
}
#pragma mark - Custom Protocol
-(void)deletedJobProtocol_with_JobID:(NSString *)jobID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.JobID == %@", jobID];
    NSUInteger indexFromMainArray = [arrPosted indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [predicate evaluateWithObject:obj];
    }];
    
    @try
    {
        [arrPosted removeObjectAtIndex:indexFromMainArray];
        [tblView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
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
