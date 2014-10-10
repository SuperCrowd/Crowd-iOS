//
//  C_DashBoardVC.m
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_DashBoardVC.h"
#import "AppConstant.h"
#import "C_PostJob_NameVC.h"
#import "C_Cell_Dashboard.h"
#import "DashBoardModel.h"

#import "C_OtherUserProfileVC.h"
@interface C_DashBoardVC ()<UITableViewDataSource,UITableViewDelegate>
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

@implementation C_DashBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Dashboard";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    arrContent = [[NSMutableArray alloc]init];
    isCallingService = YES;
    isAllDataRetrieved = NO;
    
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh:) forControlEvents:UIControlEventValueChanged];
    [tblView addSubview:self.refreshControl];
    /*--- Register Cell ---*/
    tblView.alpha = 0.0;
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Dashboard" bundle:nil] forCellReuseIdentifier:cellDashboardID];
    
    
    /*--- Code to Show Default Refresh when view appear ---*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tblView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        if (_isGointToJobPostVC)
        {
            [self refreshControlRefresh:NO];
        }
        else
            [self refreshControlRefresh:YES];
        
    });
   
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];

    
    if (_isGointToJobPostVC)
    {
        C_PostJob_NameVC *obj = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
        is_PostJob_Edit_update = @"no";
        obj.isComeFromTutorial = YES;
        [self.navigationController pushViewController:obj animated:NO];
        return;
    }
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}

-(void)btnMenuClicked:(id)sender
{
//    [UserDefaults removeObjectForKey:APP_USER_INFO];
//    [UserDefaults removeObjectForKey:PROFILE_PREVIEW];
//    [UserDefaults synchronize];
//    
//    [appDel.navC popToRootViewControllerAnimated:YES];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
#pragma mark - Get Data
-(void)refreshControlRefresh:(BOOL)isShowHUd
{
    pageNum = 1;
    isAllDataRetrieved = NO;
    [self.refreshControl beginRefreshing];
    [self getData:isShowHUd];
}
-(void)getData:(BOOL)isShowHUd
{
    /*
     {
       "UserID": "3",
       "UserToken": "Dbr/k5trWmO3XRTk3AWfX90E9jwpoh59w/EaiU9df/OkFa6bxluaKsQmBtKDNDHbBpplmFe2Zo06m6TOpxxDc0mhb1DzDq0EzXjBFsfQRVTewDXwdZZ5mxNdEp4HEdrIlx43DPPRh+5uQzOzP8bob7ckkNvE7yB9HbeZVS5I1BhjHA3/8Ac2Qf0+sjkHb8mKk/bSO1NammUBSEHHCQ0u3MNYOiR1PU+Uc1gRIkGm4CmEcYZVEdD1D1i9i26QwQSqMSs/hBy6V9wgcbrApOiKrRXOcQDv7r93",
       "PageNumber": "1",
     }
     */
    @try
    {
        isCallingService = YES;
        showHUD_with_Title(@"Getting Feeds");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum]};
        parser = [[JSONParser alloc]initWith_withURL:Web_DASHBOARD withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
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
        [self showAlert_withTitle:@"Please Try Again"];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
    }
    else if([objResponse objectForKey:@"GetActivityFeedsResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isJobList = [[objResponse valueForKeyPath:@"GetActivityFeedsResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            //got
            if (pageNum==1)
            {
                [arrContent removeAllObjects];
            }
            __weak UITableView *weaktbl = (UITableView *)tblView;
            [self setData:[objResponse valueForKeyPath:@"GetActivityFeedsResult.GetActivityFeeds"] withHandler:^{
                
                weaktbl.alpha = 1.0;
                [weaktbl reloadData];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    hideHUD;
                });
            }];
            isCallingService = NO;
            
        }
        else
        {
            isCallingService = NO;
            hideHUD;
            NSString *strR = [objResponse valueForKeyPath:@"GetActivityFeedsResult.ResultStatus.StatusMessage"];
            if ([strR isEqualToString:@"No feeds!"])
            {
                isAllDataRetrieved = YES;
                if (!_isGointToJobPostVC) {
                    [self showAlert_OneButton:@"No Records found"];
                }
                
            }
            else if ([strR isEqualToString:@"No feeds on this Page Number!"])
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
                [arrContent addObject:[DashBoardModel addDashBoardListModel:dict]];
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
                [self getData:YES];
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
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                   {
                                       [self getData:YES];
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

                break;
            case 1:
                [self getData:YES];
                break;
                
            default:
                break;
        }
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
    DashBoardModel *myDash = (DashBoardModel *)arrContent[indexPath.row];

//        //13+49+13
    CGFloat heightCell = 0;
    CGFloat txtH = [myDash.strDisplayText getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 75.0];
    heightCell = 13.0 + txtH + 13.0;
    return MAX(76.0, heightCell);
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DashBoardModel *myDash = (DashBoardModel *)arrContent[indexPath.row];
    C_Cell_Dashboard *cell = (C_Cell_Dashboard *)[tblView dequeueReusableCellWithIdentifier:cellDashboardID];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.lblDesc.font = kFONT_LIGHT(14.0);
    cell.lblDesc.text = myDash.strDisplayText;

    cell.imgVOtherUser.layer.borderColor = RGBCOLOR_GREEN.CGColor;
    [cell.imgVOtherUser sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:myDash.PhotoURL ]]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DashBoardModel *myDash = (DashBoardModel *)arrContent[indexPath.row];

    C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
    obj.OtherUserID = myDash.OtherUserID;
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
