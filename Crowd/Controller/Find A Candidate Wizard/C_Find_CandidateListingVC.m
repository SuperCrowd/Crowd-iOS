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

#import "C_OtherUserProfileVC.h"
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search Results";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(back)];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    
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
     */
    @try
    {
        NSLog(@"page Num : %ld",(long)pageNum);
        isCallingService = YES;
        showHUD_with_Title(@"Getting Candidate List");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"Industry":@"",
                                    @"Industry2":@"",
                                    @"ExperienceLevel":@"",
                                    @"LocationCity":@"",
                                    @"LocationState":@"",
                                    @"LocationCountry":@"",
                                    @"Company":@"",
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
                
                hideHUD;
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
            if ([strR isEqualToString:@"No Records on this Page Number!"])
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
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
        
        [cell.imgVCandidate sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,myCan.PhotoURL]];

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
        
        [cell.imgVUserPic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,myCan.PhotoURL]];
        
        cell.btnInfo.tag = indexPath.row;
        [cell.btnInfo addTarget:self action:@selector(btnInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    }
    
    
//    if ([myJob.UserId isEqualToString:userInfoGlobal.UserId])
//    {
//        //postJob_ModelClass = [C_PostJobModel addPostJobModel:[objResponse valueForKeyPath:@"AddEditJobResult.JobDetailsWithSkills"]];
//        
//        /*--- Send current object and get data then fill object after that if user press update then replace object so this will appear here ---*/
//        C_PostJob_UpdateVC *objD = [[C_PostJob_UpdateVC alloc]initWithNibName:@"C_PostJob_UpdateVC" bundle:nil];
//        objD.obj_JobListModel = myJob;
//        objD.strComingFrom = @"FindAJob";
//        [self.navigationController pushViewController:objD animated:YES];
//        
//    }
//    else
//    {
//        C_JobViewVC *obj = [[C_JobViewVC alloc]initWithNibName:@"C_JobViewVC" bundle:nil];
//        obj.obj_myJob = myJob;
//        [self.navigationController pushViewController:obj animated:YES];
//    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
