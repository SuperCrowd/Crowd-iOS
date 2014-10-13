//
//  C_FindJobVC.m
//  Crowd
//
//  Created by MAC107 on 29/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_FindAJobListingVC.h"
#import "AppConstant.h"

#import "C_Cell_FindAJobList.h"
#import "C_Cell_FindAJobList_Info.h"
#import "C_JobListModel.h"

#import "C_JobViewVC.h"
#import "C_PostJobModel.h"

#import "C_PostJob_UpdateVC.h"
@interface C_FindAJobListingVC ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,postJobProtocol>
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

@implementation C_FindAJobListingVC
-(void)back
{
    popView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search Results";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(back)];
    
    
    
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
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_FindAJobList" bundle:nil] forCellReuseIdentifier:cellFindJobListID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_FindAJobList_Info" bundle:nil] forCellReuseIdentifier:cellFindJobList_INFO_ID];


    /*--- Code to Show Default Refresh when view appear ---*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tblView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self refreshControlRefresh];
    });
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    if (arrContent.count > 0)
    {
        [tblView reloadData];
    }
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

    @try
    {
        isCallingService = YES;
        showHUD_with_Title(@"Getting Job List");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"Industry":[_dictInfoJob[@"Industry"] isNull],
                                    @"Industry2":[_dictInfoJob[@"Industry2"] isNull],
                                    @"ExperienceLevel":[_dictInfoJob[@"ExperienceLevel"] isNull],
                                    @"Position":[_dictInfoJob[@"Position"] isNull],
                                    @"LocationCity":[_dictInfoJob[@"LocationCity"] isNull],
                                    @"LocationState":[_dictInfoJob[@"LocationState"] isNull],
                                    @"LocationCountry":[_dictInfoJob[@"LocationCountry"] isNull],
                                    @"Company":[_dictInfoJob[@"Company"] isNull],
                                    @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum]};
        parser = [[JSONParser alloc]initWith_withURL:Web_JOB_LIST withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
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
    else if([objResponse objectForKey:@"SearchJobResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isJobList = [[objResponse valueForKeyPath:@"SearchJobResult.ResultStatus.Status"] boolValue];
        if (isJobList)
        {
            //got
            if (pageNum==1)
            {
                [arrContent removeAllObjects];
            }
            __weak UITableView *weaktbl = (UITableView *)tblView;
            [self setData:[objResponse valueForKeyPath:@"SearchJobResult.JobDetails"] withHandler:^{
                
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
            NSString *strR = [objResponse valueForKeyPath:@"SearchJobResult.ResultStatus.StatusMessage"];
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
                [arrContent addObject:[C_JobListModel addJobListModel:dict]];
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
        
        UIAlertAction* LeaveAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                      {
                                          [self getData];
                                      }];
        [alert addAction:LeaveAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];[alertView show];
        alertView.tag = 101;
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
    C_JobListModel *myJob = (C_JobListModel *)arrContent[indexPath.row];
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
    C_JobListModel *myJob = (C_JobListModel *)arrContent[indexPath.row];

    if (myJob.isShowDescription)
    {
        C_Cell_FindAJobList_Info *cell = (C_Cell_FindAJobList_Info *)[tblView dequeueReusableCellWithIdentifier:cellFindJobList_INFO_ID ];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.lblDescription.text = myJob.Responsibilities;
        cell.btnEditJob.tag = indexPath.row;
        cell.btnLocation.tag = indexPath.row;
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
        [cell.btnInfo addTarget:self action:@selector(btnInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_JobListModel *myJob = (C_JobListModel *)arrContent[indexPath.row];
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
#pragma mark - Info + Edit
-(void)btnInfoClicked:(UIButton *)btnInfo
{
    C_JobListModel *myJob = (C_JobListModel *)arrContent[btnInfo.tag];
    myJob.isShowDescription = YES;
    [tblView reloadData];
}
-(void)btnEdit_LocationClicked:(UIButton *)btnInfo
{
    C_JobListModel *myJob = (C_JobListModel *)arrContent[btnInfo.tag];
    myJob.isShowDescription = NO;
    [tblView reloadData];
}
#pragma mark - Custom Protocol
-(void)deletedJobProtocol_with_JobID:(NSString *)jobID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.JobID == %@", jobID];
    NSUInteger indexFromMainArray = [arrContent indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [predicate evaluateWithObject:obj];
    }];
    
    @try
    {
        [arrContent removeObjectAtIndex:indexFromMainArray];
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
    // Dispose of any resources that can be recreated.
}
@end
