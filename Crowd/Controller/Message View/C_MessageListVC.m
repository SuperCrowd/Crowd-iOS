//
//  C_MessageListVC.m
//  Crowd
//
//  Created by MAC107 on 13/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MessageListVC.h"
#import "AppConstant.h"

#import "C_Cell_Message_Job.h"
#import "C_Cell_Message_Simple.h"
#import "C_MessageModel.h"

#import "C_OtherUserProfileVC.h"
#import "C_MessageView.h"
@interface C_MessageListVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    NSMutableArray *arrContent;
    JSONParser *parser;
    NSInteger pageNum;
    /*--- To check if service is calling or not ---*/
    BOOL isCallingService;
    BOOL isAllDataRetrieved;
    
    NSInteger index_accept_decline;
    BOOL isAccept;
}
@property(nonatomic, strong)UIRefreshControl *refreshControl;
@end

@implementation C_MessageListVC
#pragma mark - NOTIFICATION
-(void)updateMessageListNotification:(NSNotification *)notif
{
    if ([notif.object isKindOfClass:[NSString class]])
    {
        NSString *strMSGID = [NSString stringWithFormat:@"%@",notif.object];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SenderID == %@ AND (Type == '1')", strMSGID];
        NSArray *arr = [arrContent filteredArrayUsingPredicate:predicate];
        if (arr.count>0)
        {
            NSUInteger indexFromArr= [arrContent indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                return [predicate evaluateWithObject:obj];
            }];
            
            @try
            {
                if (indexFromArr < arrContent.count) {
                    C_MessageModel *myMessage = (C_MessageModel *)arrContent[indexFromArr];
                    myMessage.IsUnreadMessages = YES;
                    [tblView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexFromArr inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
                
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
        }
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_Update_MessageList object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMessageListNotification:) name:kNotification_Update_MessageList object:nil];
}
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Messages";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    arrContent = [[NSMutableArray alloc]init];
    isCallingService = YES;
    isAllDataRetrieved = NO;
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh) forControlEvents:UIControlEventValueChanged];
    [tblView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_Update_MessageList object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMessageListNotification:) name:kNotification_Update_MessageList object:nil];
    
    
    /*--- Register Cell ---*/
    tblView.alpha = 0.0;
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Message_Simple" bundle:nil] forCellReuseIdentifier:cellMessageSimpleID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Message_Job" bundle:nil] forCellReuseIdentifier:cellMessageJOBID];
    
    /*--- Code to Show Default Refresh when view appear ---*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tblView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self refreshControlRefresh];
    });
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
     0 = regular
     1 = accept/decline
     2 = accept
     3 = decline
     */
    @try
    {
        isCallingService = YES;
        showHUD_with_Title(@"Getting Messages");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"PageNumber":[NSString stringWithFormat:@"%ld",(long)pageNum]};
        parser = [[JSONParser alloc]initWith_withURL:Web_GET_MESSAGES_LIST withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
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
        isCallingService = NO;
        [self showAlert_withTitle:@"Please Try Again"];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        isCallingService = NO;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
    }
    else if([objResponse objectForKey:@"GetMessageListResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isMessageList = [[objResponse valueForKeyPath:@"GetMessageListResult.ResultStatus.Status"] boolValue];
        if (isMessageList)
        {
            //got
            if (pageNum==1)
            {
                [arrContent removeAllObjects];
            }
            __weak UITableView *weaktbl = (UITableView *)tblView;
            [self setData:[objResponse valueForKeyPath:@"GetMessageListResult.MesssageList"] withHandler:^{
                
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
            hideHUD;
            NSString *strR = [objResponse valueForKeyPath:@"GetMessageListResult.ResultStatus.StatusMessage"];
            if ([strR isEqualToString:@"No Records"])
            {
                isAllDataRetrieved = YES;
                [self showAlert_OneButton:@"Your inbox is empty, search for jobs and candidates to make new connections."];
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
            isCallingService = NO;
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
                [arrContent addObject:[C_MessageModel addMessageList:dict]];
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
                                       }];
        [alert addAction:CancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];[alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                [self getData];
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
    C_MessageModel *myMessage = (C_MessageModel *)arrContent[indexPath.row];
    if ([myMessage.Type isEqualToString:@"1"])
    {
        CGFloat heightCell = 0;
        CGFloat txtH = [myMessage.strDisplayText getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 95.0];
        heightCell = 13.0 + txtH + 26.0;
        return MAX(90.0, heightCell);
    }
    else
    {
        CGFloat heightCell = 0;
        CGFloat txtH = [myMessage.strDisplayText getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 95.0];
        heightCell = 13.0 + txtH + 60.0;
        return MAX(90.0, heightCell);
    }
    return 90.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* Type
     1 = regular
     2 = accept/decline
     3 = accept
     4 = decline
     */
    C_MessageModel *myMessage = (C_MessageModel *)arrContent[indexPath.row];
    if ([myMessage.Type isEqualToString:@"1"])
    {
        C_Cell_Message_Simple *cell = (C_Cell_Message_Simple *)[tblView dequeueReusableCellWithIdentifier:cellMessageSimpleID];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblText.font = kFONT_LIGHT(14.0);
        cell.lblText.text = myMessage.strDisplayText;
        
        cell.lblTime.text = myMessage.strDisplayDate;
        
        cell.imgVUserPic.layer.borderColor = RGBCOLOR_GREEN.CGColor;
        [cell.imgVUserPic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:myMessage.PhotoURL ]]];
        
        if (myMessage.IsUnreadMessages)
            cell.imgVUnreadMSG.alpha = 1.0;
        else
            cell.imgVUnreadMSG.alpha = 0.0;
    
        return cell;
    }
    else
    {
        C_Cell_Message_Job *cell = (C_Cell_Message_Job *)[tblView dequeueReusableCellWithIdentifier:cellMessageJOBID];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblText.font = kFONT_LIGHT(14.0);
        cell.lblText.text = myMessage.strDisplayText;
        cell.lblTime.text = myMessage.strDisplayDate;
        
        cell.imgVUserPic.layer.borderColor = RGBCOLOR_GREEN.CGColor;
        [cell.imgVUserPic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:myMessage.PhotoURL ]]];

        if (!myMessage.State)
            cell.imgVUnreadMSG.alpha = 1.0;
        else
            cell.imgVUnreadMSG.alpha = 0.0;
        
        /*
         1 = regular
         2 = accept/decline
         3 = accept
         4 = decline
         */
        if ([myMessage.Type isEqualToString:@"2"])
        {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewUserProfileTapped:)];
            cell.imgVUserPic.userInteractionEnabled = YES;
            cell.imgVUserPic.tag = indexPath.row;
            [cell.imgVUserPic addGestureRecognizer:tap];
            
            cell.lblDeclined.alpha = 0.0;
            cell.btnViewProfile.alpha = 0.0;
            cell.btnAccept.alpha = 1.0;
            cell.btnDeclined.alpha = 1.0;
        }
        else if([myMessage.Type isEqualToString:@"3"])
        {
            cell.lblDeclined.alpha = 0.0;
            cell.btnViewProfile.alpha = 1.0;
            cell.btnAccept.alpha = 0.0;
            cell.btnDeclined.alpha = 0.0;
        }
        else
        {
            cell.lblDeclined.alpha = 1.0;
            cell.btnViewProfile.alpha = 0.0;
            cell.btnAccept.alpha = 0.0;
            cell.btnDeclined.alpha = 0.0;
        }
        
        
        cell.btnAccept.tag = indexPath.row;
        cell.btnDeclined.tag = indexPath.row;
        cell.btnViewProfile.tag = indexPath.row;
        
        [cell.btnAccept addTarget:self action:@selector(btnAcceptClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnDeclined addTarget:self action:@selector(btnDeclinedClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnViewProfile addTarget:self action:@selector(btnViewProfileClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_MessageModel *myMessage = (C_MessageModel *)arrContent[indexPath.row];
    if ([myMessage.Type isEqualToString:@"1"])
    {
        myMessage.IsUnreadMessages = NO;
        NSArray *arr = @[indexPath];
        //[tblView reloadData];
        [tblView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
        
        C_MessageView *obj = [[C_MessageView alloc]initWithNibName:@"C_MessageView" bundle:nil];
        obj.message_UserInfo = myMessage;
        [self.navigationController pushViewController:obj animated:YES];
    }
}

#pragma mark - Accept - Decline - View profile
-(void)btnAcceptClicked:(UIButton *)btnAccept
{
    index_accept_decline = btnAccept.tag;
    isAccept = YES;
    C_MessageModel *myMessage = (C_MessageModel *)arrContent[btnAccept.tag];
    [self accept_or_decline:myMessage withStatus:@"1"];
}
-(void)btnDeclinedClicked:(UIButton *)btnDecline
{
    index_accept_decline = btnDecline.tag;
    isAccept = NO;
    C_MessageModel *myMessage = (C_MessageModel *)arrContent[btnDecline.tag];
    [self accept_or_decline:myMessage withStatus:@"0"];
}

- (void)viewUserProfileTapped:(UITapGestureRecognizer *)recognizer
{
    UIImageView *imgView = (UIImageView *)recognizer.view;

    C_MessageModel *myMessage = (C_MessageModel *)arrContent[imgView.tag];
    C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
    obj.OtherUserID = myMessage.SenderID;
    [self.navigationController pushViewController:obj animated:YES];
}

-(void)btnViewProfileClicked:(UIButton *)btnViewProfile
{
    C_MessageModel *myMessage = (C_MessageModel *)arrContent[btnViewProfile.tag];
    C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
    obj.OtherUserID = myMessage.SenderID;
    [self.navigationController pushViewController:obj animated:YES];
}

#pragma mark - Accept - Decline
-(void)accept_or_decline:(C_MessageModel *)myMessage withStatus:(NSString *)status
{
    /*
     {
     <xs:element minOccurs="0" name="UserID" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="UserToken" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="MessageID" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="JobID" nillable="true" type="xs:string"/>
     <xs:element minOccurs="0" name="Status" nillable="true" type="xs:string"/>
     }
     */
    @try
    {
        showHUD_with_Title(@"Please wait");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"MessageID":myMessage.msgID,
                                    @"JobID":myMessage.LincJobID,
                                    @"Status":status,
                                    @"IsRequiredFeedCreated":@"1"
                                    };
        parser = [[JSONParser alloc]initWith_withURL:Web_JOB_ACCEPT_DECLINE withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(accept_decline_Successfull:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)accept_decline_Successfull:(id)objResponse
{
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
    else if([objResponse objectForKey:@"AcceptDeclineJobApplicationResult"])
    {
        /*--- Save data here ---*/
        BOOL isAcceptDeclineSuccess = [[objResponse valueForKeyPath:@"AcceptDeclineJobApplicationResult.ResultStatus.Status"] boolValue];
        if (isAcceptDeclineSuccess)
        {
            //got
            C_MessageModel *myMessage = (C_MessageModel *)arrContent[index_accept_decline];
            if (isAccept)
                myMessage.Type = @"3";
            else
                myMessage.Type = @"4";
            
            myMessage.State = YES;
            hideHUD;
            [tblView reloadData];
            
            /*--- when get response get unread count ---*/
            [appDel getMessageUnreadCount];
        }
        else
        {
            hideHUD;
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"AcceptDeclineJobApplicationResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
    }
    
}


#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
