//
//  C_JobsOther.m
//  Crowd
//
//  Created by Mac009 on 10/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_JobsOther.h"
#import "AppConstant.h"
#import "C_Cell_FindAJobList.h"
#import "C_Cell_FindAJobList_Info.h"
#import "C_Header_ProfilePreview.h"
#import "C_JobListModel.h"
#import "C_MyJobsVC.h"
#import "CustomBtn.h"

#import "C_JobViewVC.h"
@interface C_JobsOther ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    JSONParser *parser;
    NSMutableArray *arrPosted;
    BOOL isCallingService;
    BOOL isAllDataRetrieved;
    NSInteger pageNum;

}
@property(nonatomic, strong)UIRefreshControl *refreshControl;


@end

@implementation C_JobsOther

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    //self.title = self.titleName;
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    arrPosted = [[NSMutableArray alloc]init];
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
-(void)back{
    popView;
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
        showHUD_with_Title(@"Getting Jobs");
        isCallingService = YES;
        
        
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum],
                                    @"OtherUserID":self.OtherUserID};
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
            NSLog(@"%@",[dictResult objectForKey:@"FollowingMeUser"]);// Following users
            NSLog(@"%@",[dictResult objectForKey:@"IAmFollowingUser"]);// Followed users
            if (pageNum==1)
            {
                [arrPosted removeAllObjects];
            }
            
            NSArray *arrPost= [dictResult objectForKey:@"PostedByMe"];
            [arrPost enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [arrPosted addObject:[C_JobListModel addJobListModel:obj]];
            }];
            
            
            
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
                if (pageNum==1)
                {
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
#pragma mark - TblViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrPosted count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_JobListModel *myJob = (C_JobListModel *)arrPosted[indexPath.row];
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
    C_JobListModel *myJob = (C_JobListModel *)arrPosted[indexPath.row];
    
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
        cell.lblTime.text = [NSString stringWithFormat:@"Posted:%@",myJob.dateStr];
        
        cell.btnInfo.tag = indexPath.row;
        cell.btnInfo.indexofBtn = indexPath;
        [cell.btnInfo addTarget:self action:@selector(btnInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_JobListModel *myJob = (C_JobListModel *)arrPosted[indexPath.row];
    C_JobViewVC *obj = [[C_JobViewVC alloc]initWithNibName:@"C_JobViewVC" bundle:nil];
    obj.obj_myJob = myJob;
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark - Info + Edit
-(void)btnInfoClicked:(CustomBtn *)btnInfo
{
    NSLog(@"%@",btnInfo.indexofBtn);
    if (btnInfo.indexofBtn!=nil) {
        C_JobListModel *myJob = (C_JobListModel *)arrPosted[btnInfo.indexofBtn.row];
        myJob.isShowDescription = YES;
        [tblView reloadData];
    }
    
}
-(void)btnEdit_LocationClicked:(CustomBtn *)btnInfo
{
    NSLog(@"%@",btnInfo.indexofBtn);
    if (btnInfo.indexofBtn!=nil) {
        C_JobListModel *myJob = (C_JobListModel *)arrPosted[btnInfo.indexofBtn.row];
        myJob.isShowDescription = NO;
        [tblView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
