//
//  C_MessageView.m
//  Crowd
//
//  Created by MAC107 on 13/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MessageView.h"
#import "AppConstant.h"
#import "C_MessageModel.h"
#import "MessageDetailModel.h"

#import "MDMultilineTextView.h"

//link to job
#import "C_MyJobsVC.h"
#import "C_JobListModel.h"
#import "C_PostJob_UpdateVC.h"
#import "C_JobViewVC.h"
#import "C_MyCrowdVC.h"

//link to website
#import "C_WebVC.h"

//link to user
#import "C_OtherUserProfileVC.h"
#import "C_MyProfileVC.h"


#import "C_Cell_Chat_Me.h"
#import "C_Cell_Chat_Other.h"
#import "C_TwilioClient.h"
#import "C_CallViewController.h"

#define MESSAGE_COUNT @"30"

@interface C_MessageView ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate,selectJobProtocol,selectUserProtocol,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    IBOutlet UIView *viewChat;// chat view
    IBOutlet NSLayoutConstraint *const_hpgrowing;//bottom layout
    __weak IBOutlet UIButton *btnPlus;
    __weak IBOutlet UIButton *btnSend;
    __weak IBOutlet MDMultilineTextView *multiTextView;
    
    NSMutableArray *arrContent;
    JSONParser *parser;
    JSONParser *parserForCallAvailability;
    
    /*--- To check if service is calling or not ---*/
    BOOL isCallingService;
    BOOL isAllDataRetrieved;
    
    /*--- Pangesture is used to drag view when drag table ---*/
    id keyboardShowObserver;
    id keyboardHideObserver;
    UIPanGestureRecognizer *panGest;
    
    /*--- used when add button link ---*/
    NSString *strTextMessage;
    NSString *strLink_JobID;
    NSString *strLink_JobCreaterID;
    NSString *strLink_UserID;
    NSString *strLink_Website;
    
    NSString *OtherUserPhotoURL;
    
    
    BOOL isNotificationReceived;
}
@property (assign, nonatomic) CGFloat originalKeyboardY;//keyboard Y Axis
@property(nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic, strong)UIBarButtonItem* callBarButtonItem;
@property(nonatomic, strong)NSTimer* timerCallAvailability;
@property(nonatomic, strong)NSNumber* secondsToWaitToCheckAvailability;
@property BOOL isAvailableForCall;
@end

@implementation C_MessageView
@synthesize timerCallAvailability;
@synthesize secondsToWaitToCheckAvailability;
@synthesize isAvailableForCall;

-(void)back
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_GetMessage object:nil];
    popView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Messages";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    
    arrContent = [[NSMutableArray alloc]init];
    isCallingService = YES;
    isAllDataRetrieved = NO;
    isNotificationReceived = NO;
    
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Load Earlier"];
    [tblView addSubview:self.refreshControl];
    
    /*--- multi line text view ---*/
    multiTextView.layer.cornerRadius = 5.0;
    multiTextView.layer.borderWidth = 0.25;
    multiTextView.layer.borderColor = RGBCOLOR(38, 38, 38).CGColor;
    [multiTextView setClipsToBounds:YES];
    
    /*----call button bar item --*/
    self.callBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"message-call"] style:UIBarButtonItemStylePlain target:self action:@selector(onCallButtonPressed:)];
    
    [self updateCallAvailabilityBasedOnCachedPresenceUpdates];
    if (self.isAvailableForCall)
    {
            self.callBarButtonItem.enabled = YES;
    }
    else
    {
            self.callBarButtonItem.enabled = NO;
    }
    self.navigationItem.rightBarButtonItem = self.callBarButtonItem;
    
    /*--- add line on top ---*/
    [CommonMethods addTOPLine_to_View:viewChat];
    
    strLink_Website = @"";
    strLink_JobID = @"";
    strLink_UserID = @"";
    strLink_JobCreaterID = @"";
    
    /*--- Register Cell ---*/
    tblView.alpha = 0.0;
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Chat_Me" bundle:nil] forCellReuseIdentifier:cellChatMEID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Chat_Other" bundle:nil] forCellReuseIdentifier:cellChatOtherID];
    
    /*--- Code to Show Default Refresh when view appear ---*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getRecentMessages_withHUD:YES];
        

        
    });
    
    /*--- set defaults ---*/
    btnSend.enabled = NO;
    btnSend.alpha = 0.5;
    panGest = tblView.panGestureRecognizer;
    [panGest addTarget:self action:@selector(handlePanGesture:)];
    
    /*--- notification when send new message ---*/
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_GetMessage object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getMessageNotification) name:kNotification_GetMessage object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:WTPresenceUpdateForClient object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPresenceUpdateForClientNotification:) name:WTPresenceUpdateForClient object:nil];
    
}

#pragma mark - Call Availability Methods
- (void) updateCallAvailabilityBasedOnCachedPresenceUpdates
{
    NSString* activityName = @"updateCallAvailabilityBasedOnCachedPresenceUpdates:";
    C_TwilioClient* twilioClient = [C_TwilioClient sharedInstance];
    NSNumber* presenceObject = [twilioClient getPresenceForClient:_message_UserInfo.SenderID];
    
    if (presenceObject == nil)
    {
        //no data in the presence cache
        LOG_TWILIO(0,@"%@No cached presence data available for client %@",activityName,_message_UserInfo.SenderID);
    }
    else
    {
        //we do have data
        BOOL isAvailable = [presenceObject boolValue];
        
        if (isAvailable)
        {
            LOG_TWILIO(0,@"%@User %@ is available for calling based on cached twilio presence update",activityName, _message_UserInfo.SenderID);
            self.isAvailableForCall = NO;
        }
        else
        {
            LOG_TWILIO(0,@"%@User %@ is NOT available for calling based on cached twilio presence update",activityName, _message_UserInfo.SenderID);
            self.isAvailableForCall = NO;

        }
    }
}

- (void) onPresenceUpdateForClientNotification:(NSNotification*)notification
{
    NSString* activityName = @"OnPresenceUpdateForClientNotification:";
    NSDictionary* userInfo = notification.userInfo;
    
    NSString* clientName = [userInfo objectForKey:@"Name"];
    
    if ([clientName isEqualToString:_message_UserInfo.SenderID])
    {
        NSNumber* availability = [userInfo objectForKey:@"Available"];
        LOG_TWILIO(0,@"%@Received Twilio presence update notification for client %@ who's presence is %@",activityName,clientName,availability);
        
        if ([availability boolValue] == YES)
        {
            //client is available
            self.callBarButtonItem.enabled = YES;
            self.isAvailableForCall = YES;
        }
        else
        {
            //client is not available
            self.callBarButtonItem.enabled = NO;
            self.isAvailableForCall = NO;
            
            
        }
        

    }
    
}

- (void) checkCallAvailability
{
    NSString* activityName = @"checkCallAvailability:";
    LOG_TWILIO(0,@"%@Checking user %@  availibility for a call",activityName,_message_UserInfo.SenderID);
    
    NSDictionary *dictParam = @{@"UserID":_message_UserInfo.SenderID};
    [self.timerCallAvailability invalidate];
    self.timerCallAvailability = nil;
    
    parserForCallAvailability = [[JSONParser alloc]initWith_withURL:Web_GET_CALLAVAILABILITY withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(onCheckCallAvailabilitySuccessful:) withObject:self];
    
}

- (void) onCheckCallAvailabilitySuccessful:(id)objResponse
{
    NSString* activityName = @"onCheckCallAvailabilitySuccessful:";
    LOG_TWILIO(0,@"%@Successfully received GetCallAvailability result %@",activityName,objResponse);
    
    NSDictionary* responseDictionary = (NSDictionary*)objResponse;
    
    if (responseDictionary != nil)
    {
        NSDictionary* setAvailableForCallResult = [responseDictionary objectForKey:@"GetCallAvailabilityResult"];
        
        NSNumber* isAvailableForCallObj = [setAvailableForCallResult objectForKey:@"IsAvailableForCall"];
        self.isAvailableForCall = [isAvailableForCallObj boolValue];
        
        if (isAvailableForCall)
        {
            LOG_TWILIO(0,@"%@ User %@ is available for a call at this time",activityName, _message_UserInfo.SenderID);
            self.callBarButtonItem.enabled = YES;
            
            
        }
        else
        {
            LOG_TWILIO(0,@"%@ User %@ is unavailable for a call at this time",activityName, _message_UserInfo.SenderID);
            self.callBarButtonItem.enabled = NO;
            
            //we also inform the TwilioClient to mark the user as unavailable for call
            [[C_TwilioClient sharedInstance]setCallAvailbilityForClient:_message_UserInfo.SenderID isAvailable:NO];
        }
        self.secondsToWaitToCheckAvailability = [NSNumber numberWithInt: CALL_AVAILABILITY_HEARTBEAT_INTERVAL];
        
        
        //now we schedule the timer to renew in the specified number of seconds
        self.timerCallAvailability = [NSTimer scheduledTimerWithTimeInterval:[self.secondsToWaitToCheckAvailability doubleValue] target:self selector:@selector(checkCallAvailability) userInfo:nil repeats:NO];
        
        LOG_TWILIO(0,@"%@Successfully scheduled re-check of call availability to happen in %@ seconds",activityName,self.secondsToWaitToCheckAvailability);
    }
    else
    {
        LOG_TWILIO(1,@"%@Received null response from availibility method, unable to update user's call availability",activityName);
    }
}


-(void)getMessageNotification
{
    isNotificationReceived = YES;
    [self getRecentMessages_withHUD:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    /*--- set notification for keyboard open/close ---*/
    [self keyboardHandling];
    
    [self updateCallAvailabilityBasedOnCachedPresenceUpdates];
    if (self.isAvailableForCall)
    {
        self.callBarButtonItem.enabled = YES;
    }
    else
    {
        self.callBarButtonItem.enabled = NO;
    }
    

    [self checkCallAvailability];
  
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    /*--- remove notification ---*/
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:keyboardShowObserver];
    [center removeObserver:keyboardHideObserver];
    
    keyboardShowObserver = nil;
    keyboardHideObserver = nil;
    
    [self.timerCallAvailability invalidate];
    self.timerCallAvailability = nil;
}


#pragma mark - Call Related Methods
- (void) onCallButtonPressed:(id)sender
{
    NSString* activityName = @"onCallButtonPressed:";
    NSString* otherUserID = _message_UserInfo.SenderID;
    LOG_TWILIO(0,@"%@Attempting to place call to user %@",activityName,otherUserID);
    
    C_TwilioClient* twilioClient = [C_TwilioClient sharedInstance];
    [twilioClient connect:otherUserID];
    
    NSString* userCalling = [NSString stringWithFormat:@"%@ %@",_message_UserInfo.FirstName,_message_UserInfo.LastName];
    
    C_CallViewController* cvc = [C_CallViewController createForDialing:userCalling];
    [self presentViewController:cvc animated:YES completion:nil];
    
}
#pragma mark - Get RecentMessages
-(void)refreshControlRefresh
{
    isAllDataRetrieved = NO;
    [self.refreshControl beginRefreshing];
    [self getEarlier];
}

-(void)getRecentMessages_withHUD:(BOOL)isShowHUd
{
    @try
    {
        isCallingService = YES;
        if (isShowHUd) {
            showHUD_with_Title(@"Getting Messages");
        }
        
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"SenderID":_message_UserInfo.SenderID,
                                    @"MessageCount":MESSAGE_COUNT};
        parser = [[JSONParser alloc]initWith_withURL:Web_GET_MESSAGES_RECENT withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getRecentMessagesSuccessfull:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
}
-(void)getRecentMessagesSuccessfull:(id)objResponse
{
    //NSLog(@"Response > %@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        hideHUD;
        [self showAlert_withTitle:@"Please Try Again" withTag:101];
        isCallingService = NO;
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail] withTag:101];
        isCallingService = NO;
    }
    else if([objResponse objectForKey:@"GetMessageThreadResult"])
    {
        /*--- Save data here ---*/
        tblView.alpha = 1.0;
        BOOL isMessageList = [[objResponse valueForKeyPath:@"GetMessageThreadResult.ResultStatus.Status"] boolValue];
        if (isMessageList)
        {
            //got
            //[arrContent removeAllObjects];
            
            /*
             OtherUserFirstName = Tatva;
             OtherUserLastName = Third;
             OtherUserPhotoURL = "Profilee781e95a-aa73-43a7-a172-b4cfdcfffe43.PNG";
             */
            OtherUserPhotoURL = [[NSString stringWithFormat:@"%@",[objResponse valueForKeyPath:@"GetMessageThreadResult.OtherUserPhotoURL"]] isNull];
            __weak UITableView *weaktbl = (UITableView *)tblView;
            __weak C_MessageView *selfweak = self;
            [self setData:[objResponse valueForKeyPath:@"GetMessageThreadResult.MesssageList"]
                 isRecent:YES
              withHandler:^{
                weaktbl.alpha = 1.0;
                [weaktbl reloadData];
                [selfweak scrolltoBottomTable];

            } ];
            isCallingService = NO;
            
            /*--- when get response get unread count ---*/
            [appDel getMessageUnreadCount];
        }
        else
        {
            hideHUD;
            NSString *strR = [objResponse valueForKeyPath:@"GetMessageThreadResult.ResultStatus.StatusMessage"];
            if (![strR isEqualToString:@"No Records"])
            {
                [CommonMethods displayAlertwithTitle:strR withMessage:nil withViewController:self];
            }
            isCallingService = NO;
        }
    }
    else
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail] withTag:101];
    }
    
}
-(void)setData:(NSMutableArray *)arrTemp isRecent:(BOOL)isRecent withHandler:(void(^)())compilation
{
    @try
    {
        /*--- First reverse array then add in main array ---*/
        if (isRecent)
        {
            arrTemp = [[[arrTemp reverseObjectEnumerator] allObjects] mutableCopy];
            for (NSDictionary *dict in arrTemp)
            {
                @try
                {
                    NSString *msgID = [[NSString stringWithFormat:@"%@",dict[@"ID"]] isNull];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.msgID == %@",msgID];
                    NSArray *arr = [arrContent filteredArrayUsingPredicate:pred];
                    if (arr.count == 0)
                    {
                        //NSLog(@"Recent Message : %@    : %@",dict[@"Message"],msgID);
                        [arrContent addObject:[MessageDetailModel addMessageDetail:dict]];

                    }
//                    if (![[arrContent valueForKey:@"msgID"] containsObject:msgID]) {
//                        [arrContent addObject:[MessageDetailModel addMessageDetail:dict]];
//                    }
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                }
            }
        }
        else
        {
            for (NSDictionary *dict in arrTemp)
            {
                @try
                {
                    [arrContent insertObject:[MessageDetailModel addMessageDetail:dict] atIndex:0];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                }
            }
        }
        
        if (!isNotificationReceived)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    hideHUD;
            });
        }
        compilation();
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}


-(void)showAlert_withTitle:(NSString *)title withTag:(NSInteger)tagAlert
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
                                       if (tagAlert == 101) {
                                          [self getRecentMessages_withHUD:YES];
                                       }
                                       else if(tagAlert == 102)
                                       {
                                           [self sendNow];
                                       }
                                   }];
        [alert addAction:okAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        alertView.tag = tagAlert;
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
                [self getRecentMessages_withHUD:YES];
                break;
                
            default:
                break;
        }
    }
    else if(alertView.tag == 102)
    {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                [self sendNow];
                break;
                
            default:
                break;
        }
    }
    else if(alertView.tag == 103)
    {
        switch (buttonIndex) {
            case 0:
                strLink_Website = @"";
                break;
            case 1:
                strLink_Website = [alertView textFieldAtIndex:0].text;
                [self checkURLValidation_and_send];
                break;
                
            default:
                break;
        }
    }
    else if(alertView.tag == 104)
    {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                strLink_JobID = @"";
                strLink_UserID = @"";
                strLink_Website = @"";
                strLink_JobCreaterID = @"";
                [btnPlus setImage:[UIImage imageNamed:@"btnPlusGreen"] forState:UIControlStateNormal];
                if (![multiTextView.text isEqualToString:@""])
                {
                    btnSend.enabled = YES;
                    btnSend.alpha = 1.0;
                }
                else
                {
                    btnSend.enabled = NO;
                    btnSend.alpha = 0.5;
                }
                break;
            default:
                break;
        }
    }
}
#pragma mark -
#pragma mark - Get Earlier Message
-(void)getEarlier
{
    @try
    {
        if (arrContent.count>0)
        {
            MessageDetailModel *myMessage = arrContent[0];
            NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                        @"UserToken":userInfoGlobal.Token,
                                        @"SenderID":_message_UserInfo.SenderID,
                                        @"Message_Count":MESSAGE_COUNT,
                                        @"MessageID":myMessage.msgID};
            parser = [[JSONParser alloc]initWith_withURL:Web_GET_MESSAGES_PAST withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getEarlierSuccessfull:) withObject:self];
        }
        else
        {
            [self.refreshControl endRefreshing];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)getEarlierSuccessfull:(id)objResponse
{
    NSLog(@"Response > %@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        [self.refreshControl endRefreshing];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        [self.refreshControl endRefreshing];
    }
    else if([objResponse objectForKey:@"GetPastMessagesResult"])
    {
        /*--- Save data here ---*/
        BOOL isMessageList = [[objResponse valueForKeyPath:@"GetPastMessagesResult.ResultStatus.Status"] boolValue];
        if (isMessageList)
        {
            //got
            __weak UITableView *weaktbl = (UITableView *)tblView;
            UIRefreshControl *weakRef = self.refreshControl;
            
            /*--- Get array count and reload that index after table reload ---*/
            NSInteger last = [NSArray arrayWithArray:[objResponse valueForKeyPath:@"GetPastMessagesResult.MesssageList"]].count;
            if (last > 0)
            {
                last = last - 1;
            }
            
            [self setData:[objResponse valueForKeyPath:@"GetPastMessagesResult.MesssageList"]
                 isRecent:NO
              withHandler:^{
                @try
                {
                    [weakRef endRefreshing];
                    [weaktbl reloadData];
                    /*--- Now scroll to that index ---*/
                    [weaktbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:last inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                }
                
            }];
            
        }
        else
            [self.refreshControl endRefreshing];
    }
    else
    {
        [self.refreshControl endRefreshing];
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail] withTag:103];
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
    MessageDetailModel *myMessage = (MessageDetailModel *)arrContent[indexPath.row];
    if ([myMessage.SenderID isEqualToString:userInfoGlobal.UserId])
    {
        CGFloat heightCell = 0;
        
        if (![myMessage.Message isEqualToString:@""]) {
            heightCell = 32.0 + myMessage.heightText;
        }
        if (![myMessage.LincJobID isEqualToString:@""] ||
            ![myMessage.LincURL isEqualToString:@""] ||
            ![myMessage.LincUserID isEqualToString:@""])
        {
            
            heightCell = 7.0 + heightCell + 17.0 + 10.0;
        }
        else
        {
            heightCell =  heightCell + 17.0;
        }
        return MAX(64.0, heightCell);
    }
    else
    {
//        CGFloat heightCell = 0;
//        heightCell = 32.0 + myMessage.heightText + 17.0;
//        return MAX(64.0, heightCell);
        
        
        CGFloat heightCell = 0;
        
        if (![myMessage.Message isEqualToString:@""]) {
            heightCell = 32.0 + myMessage.heightText;
        }
        if (![myMessage.LincJobID isEqualToString:@""] ||
            ![myMessage.LincURL isEqualToString:@""] ||
            ![myMessage.LincUserID isEqualToString:@""])
        {
            
            heightCell = 7.0 + heightCell + 17.0 + 10.0;
        }
        else
        {
            heightCell =  heightCell + 17.0;
        }
        return MAX(64.0, heightCell);
        
    }
    
    return 64.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDetailModel *myMessage = (MessageDetailModel *)arrContent[indexPath.row];

    if ([myMessage.SenderID isEqualToString:userInfoGlobal.UserId])
    {
        // my cell (loggedin user cell)
        C_Cell_Chat_Me *cell = (C_Cell_Chat_Me *)[tblView dequeueReusableCellWithIdentifier:cellChatMEID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([myMessage.Message isEqualToString:@""])
            cell.lblText_Me.hidden = YES;
        else
            cell.lblText_Me.hidden = NO;
        
        if (![myMessage.LincJobID isEqualToString:@""] ||
            ![myMessage.LincURL isEqualToString:@""] ||
            ![myMessage.LincUserID isEqualToString:@""])
        {
            if (![myMessage.LincJobID isEqualToString:@""]) {
                cell.btnLink.accessibilityHint = @"LincJobID";
                [cell.btnLink setTitle:@"Link to Job" forState:UIControlStateNormal];
            }
            else if (![myMessage.LincURL isEqualToString:@""]) {
                cell.btnLink.accessibilityHint = @"LincURL";
                [cell.btnLink setTitle:@"Link to URL" forState:UIControlStateNormal];
            }
            else {
                cell.btnLink.accessibilityHint = @"LincUserID";
                [cell.btnLink setTitle:@"Link to User" forState:UIControlStateNormal];
            }
            cell.btnLink.hidden = NO;
            cell.const_lblText_Me.constant = 10.0;
            cell.btnLink.tag = indexPath.row;
            [cell.btnLink addTarget:self action:@selector(btnLinkClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            cell.btnLink.hidden = YES;
            cell.const_lblText_Me.constant = 238.0;
        }
        
        cell.lblText_Me.font = kFONT_LIGHT(14.0);
        cell.lblText_Me.text = myMessage.Message;
        cell.lblTime_Me.text = myMessage.strDisplayDate;
        
        cell.imgV_MeProfilePic.layer.borderColor = RGBCOLOR_GREY.CGColor;
        [cell.imgV_MeProfilePic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:userInfoGlobal.PhotoURL ]]];
        
        UIImage *bubble = [UIImage imageNamed:@"chat_black_cell"];//t/l/b/r
        bubble = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 3.0, 3.0, 14.0)];
        cell.imgV_Me.image = bubble;
        
        return cell;
    }
    else
    {
        //Other user
        C_Cell_Chat_Other *cell = (C_Cell_Chat_Other *)[tblView dequeueReusableCellWithIdentifier:cellChatOtherID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([myMessage.Message isEqualToString:@""])
            cell.lblText_Other.hidden = YES;
        else
            cell.lblText_Other.hidden = NO;
        
        if (![myMessage.LincJobID isEqualToString:@""] ||
            ![myMessage.LincURL isEqualToString:@""] ||
            ![myMessage.LincUserID isEqualToString:@""])
        {
            if (![myMessage.LincJobID isEqualToString:@""]) {
                cell.btnLink.accessibilityHint = @"LincJobID";
                [cell.btnLink setTitle:@"Link to Job" forState:UIControlStateNormal];
            }
            else if (![myMessage.LincURL isEqualToString:@""]) {
                cell.btnLink.accessibilityHint = @"LincURL";
                [cell.btnLink setTitle:@"Link to URL" forState:UIControlStateNormal];
            }
            else {
                cell.btnLink.accessibilityHint = @"LincUserID";
                [cell.btnLink setTitle:@"Link to User" forState:UIControlStateNormal];
            }
            
            cell.btnLink.hidden = NO;
            cell.const_imgV_Other.constant = 10.0;
            cell.btnLink.tag = indexPath.row;
            [cell.btnLink addTarget:self action:@selector(btnLinkClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            cell.btnLink.hidden = YES;
            cell.const_imgV_Other.constant = 238.0;
        }
        
        cell.lblText_Other.font = kFONT_LIGHT(14.0);
        cell.lblText_Other.text = myMessage.Message;
        cell.lblTime_Other.text = myMessage.strDisplayDate;
        
        cell.imgV_OtherProfilePic.layer.borderColor = RGBCOLOR_GREEN.CGColor;
        [cell.imgV_OtherProfilePic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:OtherUserPhotoURL]]];
        
        //cell.const_imgV_Width.constant = cell.lblText_Other.frame.size.width + 11.0;
        UIImage *bubble = [UIImage imageNamed:@"chat_green_cell"];
        bubble = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 14.0, 3.0, 3.0)];
        cell.imgV_Other.image = bubble;

        return cell;
    }
    return nil;

}
#pragma mark - LINK CLICKED
-(void)btnLinkClicked:(UIButton *)btnLink
{
    MessageDetailModel *myMessage = (MessageDetailModel *)arrContent[btnLink.tag];
    //NSLog(@"%@ : %@",btnLink.accessibilityHint,myMessage.Message);
    if ([btnLink.accessibilityHint isEqualToString:@"LincJobID"])
    {
        if ([myMessage.LinkJobCreatorID isEqualToString:userInfoGlobal.UserId])
        {
            //my own job
            C_JobListModel *myJob = [[C_JobListModel alloc]init];
            myJob.JobID = myMessage.LincJobID;
            C_PostJob_UpdateVC *objD = [[C_PostJob_UpdateVC alloc]initWithNibName:@"C_PostJob_UpdateVC" bundle:nil];
            objD.obj_JobListModel = myJob;
            objD.strComingFrom = @"FindAJob";
            [self.navigationController pushViewController:objD animated:YES];
        }
        else
        {
            //other user job
            C_JobListModel *myJob = [[C_JobListModel alloc]init];
            myJob.JobID = myMessage.LincJobID;
            C_JobViewVC *obj = [[C_JobViewVC alloc]initWithNibName:@"C_JobViewVC" bundle:nil];
            obj.obj_myJob = myJob;
            [self.navigationController pushViewController:obj animated:YES];
        }
    }
    else if([btnLink.accessibilityHint isEqualToString:@"LincURL"])
    {
        C_WebVC *obj = [[C_WebVC alloc]initWithNibName:@"C_WebVC" bundle:nil];
        obj.strURL = myMessage.LincURL;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else
    {
        //open other user's profile
        C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
        obj.OtherUserID = myMessage.LincUserID;
        [self.navigationController pushViewController:obj animated:YES];
    }
}
#pragma mark - Send
-(IBAction)btnSendClicked:(id)sender
{
    if (![strLink_JobID isEqualToString:@""] ||
        ![strLink_UserID isEqualToString:@""] ||
        ![strLink_Website isEqualToString:@""])
    {
        [self sendNow];
    }
    else
    {
        /*--- if no attachment fount then check text is not null ---*/
        if (![[multiTextView.text isNull] isEqualToString:@""]) {
            [self sendNow];
        }
        else
        {
            showHUD_with_error(@"Please add text");
            multiTextView.text = @"";
            btnSend.enabled = NO;
            btnSend.alpha = 0.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                hideHUD;
            });
        }
    }
}

-(void)sendNow
{
    @try
    {
        if (![strLink_Website isEqualToString:@""] && ![strLink_Website hasPrefix:@"http".uppercaseString])
        {
            strLink_Website = [NSString stringWithFormat:@"http://%@",strLink_Website];
        }
        strTextMessage = [[NSString stringWithFormat:@"%@",multiTextView.text] isNull];
        showHUD_with_Title(@"Sending Message");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"ReceiverID":_message_UserInfo.SenderID,
                                    @"Message":strTextMessage,
                                    @"LinkURL":[strLink_Website isNull],
                                    @"LinkUserID":[strLink_UserID isNull],
                                    @"LinkJobID":[strLink_JobID isNull]};
        parser = [[JSONParser alloc]initWith_withURL:Web_MESSAGES_SEND withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(sendMessagesSuccessfull:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)sendMessagesSuccessfull:(id)objResponse
{
    //NSLog(@"Response > %@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        hideHUD;
        [self showAlert_withTitle:@"Please Try Again" withTag:102];
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail] withTag:102];
    }
    else if([objResponse objectForKey:@"SendMessageResult"])
    {
        /*--- Save data here ---*/
        BOOL isMessageList = [[objResponse valueForKeyPath:@"SendMessageResult.ResultStatus.Status"] boolValue];
        if (isMessageList)
        {
            //got
            
            /*
             ID
             SenderID
             Message
             LincURL
             LincJobID
             LincUserID
             LinkJobCreatorID
             DateCreated
             */
            //10/13/2014 9:42:48 AM
            NSString *strMSGID = [[NSString stringWithFormat:@"%@",[objResponse valueForKeyPath:@"SendMessageResult.MessageID"]]isNull];

            NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.msgID == %@",strMSGID];
            NSArray *arr = [arrContent filteredArrayUsingPredicate:pred];
            //            if (![[arrContent valueForKey:@"msgID"] containsObject:strMSGID])
            
            
            multiTextView.text = @"";
            [self textViewDidChange:multiTextView];
            //[multiTextView resignFirstResponder];
            [multiTextView layoutIfNeeded];
            [viewChat layoutIfNeeded];
            
            
            
            if (arr.count == 0)
            {
                NSLog(@"SEND Message : %@    : %@",multiTextView.text,strMSGID);

                NSString *strDateGMT = [[NSDate date] getGMTDateString:@"MM/dd/yyyy h:mm:ss a"];
                NSDictionary *dictTemp = @{@"ID":[objResponse valueForKeyPath:@"SendMessageResult.MessageID"],
                                           @"SenderID":userInfoGlobal.UserId,
                                           @"ID":strMSGID,
                                           @"Message":[strTextMessage isNull],
                                           @"LincURL":[strLink_Website isNull],
                                           @"LincJobID":[strLink_JobID isNull],
                                           @"LinkJobCreatorID":[strLink_JobCreaterID isNull],
                                           @"LincUserID":[strLink_UserID isNull],
                                           @"DateCreated":strDateGMT};
                @try
                {
                    [arrContent addObject:[MessageDetailModel addMessageDetail:dictTemp]];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                    //[self getRecentMessages];
                }
                @finally {
                }
            }
            
            strLink_JobID = @"";
            strLink_JobCreaterID = @"";
            strLink_UserID = @"";
            strLink_Website = @"";
            strTextMessage = @"";
            [btnPlus setImage:[UIImage imageNamed:@"btnPlusGreen"] forState:UIControlStateNormal];
            btnSend.enabled = NO;
            btnSend.alpha = 0.5;
            
            [tblView reloadData];
            [self scrolltoBottomTable];
            
            
            hideHUD;
        }
        else
        {
            
            hideHUD;
            
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"SendMessageResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail] withTag:102];
    }
    
}
-(void)scrolltoBottomTable
{
    @try
    {
        if (arrContent.count > 0) {
            [tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tblView numberOfRowsInSection:0]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}
#pragma mark -
#pragma mark - MultilineText + Hide Text ON Drag

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    if (!viewChat)
    {
        return;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    UIWindow *panWindow = [[UIApplication sharedApplication] keyWindow];
    CGPoint location = [pan locationInView:panWindow];
    CGPoint velocity = [pan velocityInView:panWindow];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            self.originalKeyboardY = screenSize.size.height - const_hpgrowing.constant;
            break;
        case UIGestureRecognizerStateEnded:
            if(velocity.y > 0 && viewChat.frame.origin.y > self.originalKeyboardY) {
                
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                         [self keyboardWillBeDismissed];
                                 }
                                 completion:^(BOOL finished) {

                                 }];
            }
            else { // gesture ended with no flick or a flick upwards, snap keyboard back to original position
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                         [self keyboardWillSnapBackToPoint:CGPointMake(0.0f, self.originalKeyboardY)];
                                     
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
            break;
            
            // gesture is currently panning, match keyboard y to touch y
        default:
           
            if(location.y > viewChat.frame.origin.y || viewChat.frame.origin.y != self.originalKeyboardY) {
                
                CGFloat newKeyboardY = self.originalKeyboardY + (location.y - self.originalKeyboardY);
                newKeyboardY = newKeyboardY < self.originalKeyboardY ? self.originalKeyboardY : newKeyboardY;
                newKeyboardY = newKeyboardY > screenHeight ? screenHeight : newKeyboardY;
                
                viewChat.frame = CGRectMake(0.0f,
                                                 newKeyboardY,
                                                 viewChat.frame.size.width,
                                                 viewChat.frame.size.height);
                
                    [self keyboardDidScrollToPoint:CGPointMake(0.0f, newKeyboardY)];
            }
            break;
    }
}

- (void)keyboardWillBeDismissed
{
//    CGRect inputViewFrame = viewChat.frame;
//    inputViewFrame.origin.y = self.view.bounds.size.height - inputViewFrame.size.height;
//    viewChat.frame = inputViewFrame;
    //const_hpgrowing.constant = self.view.bounds.size.height - inputViewFrame.size.height;
    const_hpgrowing.constant = 0.0;
}

- (void)keyboardWillSnapBackToPoint:(CGPoint)pt
{
    CGRect inputViewFrame = viewChat.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    //const_hpgrowing.constant = keyboardOrigin.y - inputViewFrame.size.height;
    viewChat.frame = inputViewFrame;
}
- (void)keyboardDidScrollToPoint:(CGPoint)pt
{
    CGRect inputViewFrame = viewChat.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    viewChat.frame = inputViewFrame;
}
- (void)keyboardHandling
{
    keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note)
    {
        NSDictionary *info = [note userInfo];
        CGSize kbSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        //self.bottomLayoutConstraint.constant += kbSize.height;
        
        NSTimeInterval duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        const_hpgrowing.constant = kbSize.height;
        [UIView animateWithDuration:duration animations:^{
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
            [tblView setContentInset:edgeInsets];
            [tblView setScrollIndicatorInsets:edgeInsets];
        }];

        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [self.view layoutIfNeeded];
        
        [UIView commitAnimations];
        
        [self scrolltoBottomTable];
 
    }];
    
    keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note)
    {
        //NSDictionary *info = [note userInfo];
        //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        //self.bottomLayoutConstraint.constant -= kbSize.height;
        
        NSTimeInterval duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        const_hpgrowing.constant = 0;
        [UIView animateWithDuration:duration animations:^{
            UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
            [tblView setContentInset:edgeInsets];
            [tblView setScrollIndicatorInsets:edgeInsets];
        }];
        
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [self.view layoutIfNeeded];
        
        [UIView commitAnimations];
        
    }];
}

#pragma mark - Text View Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    // Tell layout system that size changed
    if (textView.text.length == 0)
    {
        multiTextView.placeholder = @"Type Message Here";
        if (![strLink_JobID isEqualToString:@""] ||
            ![strLink_UserID isEqualToString:@""] ||
            ![strLink_Website isEqualToString:@""])
        {
            btnSend.enabled = YES;
            btnSend.alpha = 1.0;
        }
        else
        {
            btnSend.enabled = NO;
            btnSend.alpha = 0.5;
        }
    }
    else
    {
        multiTextView.placeholder = @"";
        btnSend.enabled = YES;
        btnSend.alpha = 1.0;
    }
    if (textView.contentSize.height < multiTextView.maxHeight || textView.text.length == 0)
    {
        [textView invalidateIntrinsicContentSize];
    }
    [textView scrollRectToVisible:CGRectMake(0.0, textView.contentSize.height - 1.0f, 1.0, 1.0) animated:NO];
}


#pragma mark - Button (+) clicked
-(void)removeAttachment
{
    if (ios8)
    {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Would you like to remove attachment?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                 {
                                     [alertC dismissViewControllerAnimated:YES completion:nil];
                                 }];
        UIAlertAction *btnYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                     {
                                         strLink_JobID = @"";
                                         strLink_UserID = @"";
                                         strLink_Website = @"";
                                         strLink_JobCreaterID = @"";
                                         [btnPlus setImage:[UIImage imageNamed:@"btnPlusGreen"] forState:UIControlStateNormal];
                                         if (![multiTextView.text isEqualToString:@""])
                                         {
                                             btnSend.enabled = YES;
                                             btnSend.alpha = 1.0;
                                         }
                                         else
                                         {
                                             btnSend.enabled = NO;
                                             btnSend.alpha = 0.5;
                                         }
                                     }];
        
        [alertC addAction:cancel];
        [alertC addAction:btnYes];
        [self presentViewController:alertC animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Would you like to remove attachment?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.tag = 104;
        [alert show];
    }
}
-(IBAction)btnPlusClicked:(id)sender
{
    if (![strLink_JobID isEqualToString:@""] ||
        ![strLink_UserID isEqualToString:@""] ||
        ![strLink_Website isEqualToString:@""])
    {
        /*--- remove attachment when press (-) ---*/
        [self removeAttachment];
    }
    else
    {
        /*--- Add Attachment ---*/
        if (ios8)
        {
            UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *act_Job_1 = [UIAlertAction actionWithTitle:@"Add a Link to a Job" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                        {
                                            [self link_Job_1];
                                        }];
            
            UIAlertAction *act_User_2 = [UIAlertAction actionWithTitle:@"Add a Link to a User" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                         {
                                             [self link_User_2];
                                         }];
            
            UIAlertAction *act_Website_3 = [UIAlertAction actionWithTitle:@"Add a Link to a Website" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                            {
                                                [self link_Website_3];
                                            }];
            
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                     {
                                         [actionSheetController dismissViewControllerAnimated:YES completion:nil];
                                     }];
            
            [actionSheetController addAction:act_Job_1];
            [actionSheetController addAction:act_User_2];
            [actionSheetController addAction:act_Website_3];
            [actionSheetController addAction:cancel];
            
            actionSheetController.view.tintColor = RGBCOLOR_GREEN;
            
            [self presentViewController:actionSheetController animated:YES completion:nil];
        }
        else
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add a Link to a Job",@"Add a Link to a User",@"Add a Link to a Website",nil];
            [actionSheet showInView:self.view];
        }
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self link_Job_1];
            break;
        case 1:
            [self link_User_2];
            break;
        case 2:
            [self link_Website_3];
            break;
        default:
            break;
    }
}
-(void)link_Job_1
{
    C_MyJobsVC *objC_MyJobsVC = [[C_MyJobsVC alloc]initWithNibName:@"C_MyJobsVC" bundle:nil];
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:objC_MyJobsVC];
    navC.navigationBar.translucent = NO;
    objC_MyJobsVC.isPresented = YES;
    objC_MyJobsVC.delegate = self;
    [self presentViewController:navC animated:YES completion:^{
        
    }];
}
-(void)link_User_2
{
    C_MyCrowdVC *objC_MyCrowdVC = [[C_MyCrowdVC alloc]initWithNibName:@"C_MyCrowdVC" bundle:nil];
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:objC_MyCrowdVC];
    navC.navigationBar.translucent = NO;
    objC_MyCrowdVC.strReceiverID = _message_UserInfo.SenderID;
    objC_MyCrowdVC.isPresented = YES;
    objC_MyCrowdVC.delegate = self;
    [self presentViewController:navC animated:YES completion:^{
        
    }];
}
-(void)link_Website_3
{
    if (ios8)
    {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Add Link" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                    {
                                        strLink_Website = @"";
                                        [alertC dismissViewControllerAnimated:YES completion:nil];
                                    }];
        UIAlertAction *AddWebsite = [UIAlertAction actionWithTitle:@"Add Website" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                 {
                                     UITextField *txt = alertC.textFields[0];
                                     strLink_Website = txt.text;
                                     [self checkURLValidation_and_send];
                                 }];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
           
            textField.text = [strLink_Website isNull];
            textField.placeholder = @"add Text";
            textField.font = kFONT_LIGHT(14.0);
        }];
        
        [alertC addAction:cancel];
        [alertC addAction:AddWebsite];
        alertC.view.tintColor = RGBCOLOR_GREEN;
        [self presentViewController:alertC animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add Link" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add Website", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].placeholder = @"add Text";
        [alert textFieldAtIndex:0].text = [strLink_Website isNull];;
        [alert textFieldAtIndex:0].font = kFONT_LIGHT(14.0);
        alert.tag = 103;
        [alert show];
    }
}

#pragma mark - Validation + Custom Protocol
-(void)jobSelected:(NSString *)strJobID withJobCreaterID:(NSString *)strJobCreaterID
{
    /*--- Get Job id send now ---*/
    strLink_JobID = strJobID;
    strLink_JobCreaterID = strJobCreaterID;
    [btnPlus setImage:[UIImage imageNamed:@"btnMinusGreen"] forState:UIControlStateNormal];
    btnSend.enabled = YES;
    btnSend.alpha = 1.0;

}
-(void)userSelected:(NSString *)strUserID
{
    /*--- Get User id send now ---*/
    strLink_UserID = strUserID;
    [btnPlus setImage:[UIImage imageNamed:@"btnMinusGreen"] forState:UIControlStateNormal];
    btnSend.enabled = YES;
    btnSend.alpha = 1.0;
}
-(void)checkURLValidation_and_send
{
    /*--- Check if url is valid or not ---*/
    NSString *strURL = [[NSString stringWithFormat:@"%@",strLink_Website]isNull];;
    if (strURL.length > 0)
    {
        if (![CommonMethods isValidateUrl:strURL])
        {
            showHUD_with_error(@"Please Enter Valid URL");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                hideHUD;
                [self link_Website_3];
            });
        }
        else
        {
            [btnPlus setImage:[UIImage imageNamed:@"btnMinusGreen"] forState:UIControlStateNormal];
            btnSend.enabled = YES;
            btnSend.alpha = 1.0;
        }
        
    }
    else
    {
        showHUD_with_error(@"Please Enter URL");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hideHUD;
            [self link_Website_3];
        });
    }
}


/*
 -(void)adddddddddddd
 {
 self.textView = [[UITextView alloc] initWithFrame:CGRectMake(60.0f, 3.0f, screenSize.size.width - 120.0, 30.0)];
 [self.textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
 [self.textView setScrollIndicatorInsets:UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f)];
 [self.textView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
 [self.textView setScrollsToTop:NO];
 [self.textView setUserInteractionEnabled:YES];
 [self.textView setFont:kFONT_LIGHT(14.0)];
 [self.textView setTextColor:[UIColor whiteColor]];
 [self.textView setBackgroundColor:[UIColor darkGrayColor]];
 [self.textView setKeyboardAppearance:UIKeyboardAppearanceDefault];
 [self.textView setKeyboardType:UIKeyboardTypeDefault];
 [self.textView setReturnKeyType:UIReturnKeyDefault];
 
 [self.textView setDelegate:self];
 
 // This text view is used to get the content size
 self.tempTextView = [[UITextView alloc] init];
 self.tempTextView.font = self.textView.font;
 self.tempTextView.text = @"";
 CGSize size = [self.tempTextView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)];
 self.previousTextFieldHeight = size.height;
 
 [viewChat addSubview:self.textView];
 }
 - (void)resizeView:(NSNotification*)notification
 {
 CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
 UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
 double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
 
 CGFloat viewHeight = (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? MIN(self.view.frame.size.width,self.view.frame.size.height) : MAX(self.view.frame.size.width,self.view.frame.size.height));
 CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
 CGFloat diff = keyboardY - viewHeight;
 
 // This check prevents an issue when the view is inside a UITabBarController
 if (diff > 0) {
 double fraction = diff/keyboardY;
 duration *= (1-fraction);
 keyboardY = viewHeight;
 }
 
 // Thanks to Raja Baz (@raja-baz) for the delay's animation fix.
 CGFloat delay = 0.0f;
 CGRect beginRect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
 diff = beginRect.origin.y - viewHeight;
 if (diff > 0) {
 double fraction = diff/beginRect.origin.y;
 delay = duration * fraction;
 duration -= delay;
 }
 
 void (^completition)(void) = ^{
 CGFloat inputViewFrameY = keyboardY - viewChat.frame.size.height;
 const_hpgrowing.constant = keyboardRect.size.height;
 //        viewChat.frame = CGRectMake(viewChat.frame.origin.x,
 //                                           inputViewFrameY,
 //                                           viewChat.frame.size.width,
 //                                           viewChat.frame.size.height);
 UIEdgeInsets insets = tblView.contentInset;
 insets.bottom = viewHeight - inputViewFrameY - 40.0;
 
 tblView.contentInset = insets;
 tblView.scrollIndicatorInsets = insets;
 };
 
 [UIView animateWithDuration:0.5
 delay:0
 usingSpringWithDamping:500.0f
 initialSpringVelocity:0.0f
 options:UIViewAnimationOptionCurveLinear
 animations:completition
 completion:nil];
 
 }
- (void)resizeTextViewByHeight:(CGFloat)delta
{
    int numLines = self.textView.contentSize.height / self.textView.font.lineHeight;
 
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 8 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 8 ? 4.0f : 0.0f),
                                                  0.0f);
    
    // Adjust table view's insets
    CGFloat viewHeight =  screenSize.size.height;
    
    UIEdgeInsets insets = tblView.contentInset;
    insets.bottom = viewHeight - viewChat.frame.origin.y - 40.0f;
    
    tblView.contentInset = insets;
    tblView.scrollIndicatorInsets = insets;
    
    // Slightly scroll the table
    [tblView setContentOffset:CGPointMake(0, tblView.contentOffset.y + delta) animated:YES];
}

- (void)handleTapGesture:(UIGestureRecognizer*)gesture
{
    [self.textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [btnSend setEnabled:([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)];
    
    CGFloat maxHeight = self.textView.font.lineHeight * 7;
    CGFloat textViewContentHeight = self.textView.contentSize.height;
    

    // Fixes the wrong content size computed by iOS7
    if (textView.text.UTF8String[textView.text.length-1] == '\n') {
        textViewContentHeight += textView.font.lineHeight;
    }
    
    if ([@"" isEqualToString:textView.text]) {
        self.tempTextView = [[UITextView alloc] init];
        self.tempTextView.font = self.textView.font;
        self.tempTextView.text = self.textView.text;
        
        CGSize size = [self.tempTextView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)];
        textViewContentHeight  = size.height;
    }
    
    CGFloat delta = textViewContentHeight - self.previousTextFieldHeight;
    BOOL isShrinking = textViewContentHeight < self.previousTextFieldHeight;
    
    delta = (textViewContentHeight + delta >= maxHeight) ? 0.0f : delta;
    
    if(!isShrinking)
        [self resizeTextViewByHeight:delta];
    
    if(delta != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             UIEdgeInsets insets = tblView.contentInset;
                             insets.bottom = tblView.contentInset.bottom + delta;
                             tblView.contentInset = insets;
                             tblView.scrollIndicatorInsets = insets;
                             
                             [self scrollToBottomAnimated:NO];
                             viewChat.frame = CGRectMake(0.0f,
                                                                viewChat.frame.origin.y - delta,
                                                                viewChat.frame.size.width,
                                                                viewChat.frame.size.height + delta);
                         }
                         completion:^(BOOL finished) {
                             if(isShrinking)
                                 [self resizeTextViewByHeight:delta];
                         }];
        
        self.previousTextFieldHeight = MIN(textViewContentHeight, maxHeight);
    }
    
    // This is a workaround for an iOS7 bug:
    // http://stackoverflow.com/questions/18070537/how-to-make-a-textview-scroll-while-editing
    
    if([textView.text hasSuffix:@"\n"]) {
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGPoint bottomOffset = CGPointMake(0, self.textView.contentSize.height - self.textView.bounds.size.height);
            [self.textView setContentOffset:bottomOffset animated:YES];
        });
    }
}
- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger bottomRow = [tblView numberOfRowsInSection:0] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [tblView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}*/



#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
