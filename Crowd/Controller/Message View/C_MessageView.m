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

#import "C_Cell_Chat_Me.h"
#import "C_Cell_Chat_Other.h"

#define MESSAGE_COUNT @"30"
@interface C_MessageView ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate>
{
    __weak IBOutlet UITableView *tblView;
    IBOutlet UIView *viewChat;
    IBOutlet NSLayoutConstraint *const_hpgrowing;//bottom layout
    
    NSMutableArray *arrContent;
    JSONParser *parser;
    /*--- To check if service is calling or not ---*/
    BOOL isCallingService;
    BOOL isAllDataRetrieved;
    
    
    __weak IBOutlet UIButton *btnSend;
    
    id keyboardShowObserver;
    id keyboardHideObserver;
    __weak IBOutlet MDMultilineTextView *multiTextView;
    
    
    UIPanGestureRecognizer *panGest;
    
    NSString *strLink_JobID;
    NSString *strLink_UserID;
    NSString *strLink_Website;
    
    
}
@property (assign, nonatomic) CGFloat originalKeyboardY;

@property(nonatomic, strong)UIRefreshControl *refreshControl;


@end

@implementation C_MessageView
-(void)back
{
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
    
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Load Earlier"];
    [tblView addSubview:self.refreshControl];
    
    //[self addGrowingTextView];
    //[self adddddddddddd];
    
    multiTextView.layer.cornerRadius = 5.0;
    multiTextView.layer.borderWidth = 0.25;
    multiTextView.layer.borderColor = RGBCOLOR(38, 38, 38).CGColor;
    [multiTextView setClipsToBounds:YES];
    
    [CommonMethods addTOPLine_to_View:viewChat];
    
    strLink_Website = @"";
    strLink_JobID = @"";
    strLink_UserID = @"";
    
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
        [self getRecentMessages];
    });
    
    btnSend.enabled = NO;
    panGest = tblView.panGestureRecognizer;
    [panGest addTarget:self action:@selector(handlePanGesture:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    [self keyboardHandling];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:keyboardShowObserver];
    [center removeObserver:keyboardHideObserver];
    
    keyboardShowObserver = nil;
    keyboardHideObserver = nil;
}

#pragma mark - Get RecentMessages
-(void)refreshControlRefresh
{
    isAllDataRetrieved = NO;
    [self.refreshControl beginRefreshing];
    [self getEarlier];
}

-(void)getRecentMessages
{
    @try
    {
        isCallingService = YES;
        showHUD_with_Title(@"Getting Messages");
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
    NSLog(@"Response > %@",objResponse);
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

            [arrContent removeAllObjects];
            __weak UITableView *weaktbl = (UITableView *)tblView;
            __weak C_MessageView *selfweak = self;
            [self setData:[objResponse valueForKeyPath:@"GetMessageThreadResult.MesssageList"]
                 isRecent:YES
              withHandler:^{
                weaktbl.alpha = 1.0;
                [weaktbl reloadData];
                [selfweak scrolltoBottomTable];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    hideHUD;
                });
            } ];
            isCallingService = NO;
            
        }
        else
        {
            
            hideHUD;
            NSString *strR = [objResponse valueForKeyPath:@"GetMessageThreadResult.ResultStatus.StatusMessage"];
            if ([strR isEqualToString:@"No Records"])
            {
            }
            else
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
                    [arrContent addObject:[MessageDetailModel addMessageDetail:dict]];
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
                                          [self getRecentMessages];
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
                [self getRecentMessages];
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
}
#pragma mark -
#pragma mark - Get Earlier Message
-(void)getEarlier
{
    @try
    {
        /*
         <xs:element minOccurs="0" name="UserID" nillable="true" type="xs:string"/>
         <xs:element minOccurs="0" name="UserToken" nillable="true" type="xs:string"/>
         <xs:element minOccurs="0" name="SenderID" nillable="true" type="xs:string"/>
         <xs:element minOccurs="0" name="MessageID" nillable="true" type="xs:string"/>
         <xs:element minOccurs="0" name="Message_Count" nillable="true" type="xs:string"/>
         */
        if (arrContent.count>0)
        {
            MessageDetailModel *myMessage = arrContent[0];
            NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                        @"UserToken":userInfoGlobal.Token,
                                        @"SenderID":_message_UserInfo.SenderID,
                                        @"MessageCount":MESSAGE_COUNT,
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
        heightCell = 32.0 + myMessage.heightText + 17.0;
        return MAX(64.0, heightCell);
    }
    else
    {
        CGFloat heightCell = 0;
        heightCell = 32.0 + myMessage.heightText + 17.0;
        return MAX(64.0, heightCell);
    }
    
    return 64.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDetailModel *myMessage = (MessageDetailModel *)arrContent[indexPath.row];

    if ([myMessage.SenderID isEqualToString:userInfoGlobal.UserId])
    {
        C_Cell_Chat_Me *cell = (C_Cell_Chat_Me *)[tblView dequeueReusableCellWithIdentifier:cellChatMEID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        //change here
        C_Cell_Chat_Other *cell = (C_Cell_Chat_Other *)[tblView dequeueReusableCellWithIdentifier:cellChatOtherID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblText_Other.font = kFONT_LIGHT(14.0);
        cell.lblText_Other.text = myMessage.Message;
        cell.lblTime_Other.text = myMessage.strDisplayDate;
        
        cell.imgV_OtherProfilePic.layer.borderColor = RGBCOLOR_GREEN.CGColor;
        [cell.imgV_OtherProfilePic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:_message_UserInfo.PhotoURL]]];
        
        //cell.const_imgV_Width.constant = cell.lblText_Other.frame.size.width + 11.0;
        UIImage *bubble = [UIImage imageNamed:@"chat_green_cell"];
        bubble = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 14.0, 3.0, 3.0)];
        cell.imgV_Other.image = bubble;
        
        //[cell.imgV_Other.image resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 14.0, 3.0, 3.0)];
        return cell;
    }
    return nil;

}

#pragma mark - Send
-(IBAction)btnSendClicked:(id)sender
{
    [self sendNow];
}

-(void)sendNow
{
    @try
    {
        showHUD_with_Title(@"Sending Message");
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token,
                                    @"ReceiverID":_message_UserInfo.SenderID,
                                    @"Message":[multiTextView.text isNull],
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
    NSLog(@"Response > %@",objResponse);
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
             DateCreated
             */
            //10/13/2014 9:42:48 AM
            NSString *strDateGMT = [[NSDate date] getGMTDateString:@"MM/dd/yyyy h:mm:ss a"];
            NSDictionary *dictTemp = @{@"ID":[objResponse valueForKeyPath:@"SendMessageResult.MessageID"],
                                      @"SenderID":userInfoGlobal.UserId,
                                      @"Message":[multiTextView.text isNull],
                                      @"LincURL":[strLink_Website isNull],
                                      @"LincJobID":[strLink_JobID isNull],
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
            
            strLink_JobID = @"";
            strLink_UserID = @"";
            strLink_Website = @"";
            
            multiTextView.text = @"";
            [self textViewDidChange:multiTextView];
            //[multiTextView resignFirstResponder];
            [multiTextView layoutIfNeeded];
            [viewChat layoutIfNeeded];
            
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
//    keyboardChangeFrameObserver = [[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardDidChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//        NSLog(@"Called");
//        NSDictionary *info = [note userInfo];
//        CGSize kbSize = [info[UIKeyboardBoundsUserInfoKey] CGRectValue].size;
//        const_hpgrowing.constant = kbSize.height;
//    }];
    
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
        btnSend.enabled = NO;
    else
        btnSend.enabled = YES;
    
    if (textView.contentSize.height < multiTextView.maxHeight || textView.text.length == 0)
    {
        [textView invalidateIntrinsicContentSize];
    }
    [textView scrollRectToVisible:CGRectMake(0.0, textView.contentSize.height - 1.0f, 1.0, 1.0) animated:NO];
}


#pragma mark - Button (+) clicked

-(IBAction)btnPlusClicked:(id)sender
{
    NSString *strAddLink_Job = @"Add a Link to a Job";
    NSString *strAddLink_User = @"Add a Link to a User";
    NSString *strAddLink_Website = @"Add a Link to a Website";
//    UIActionSheet *actSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:strAddLink_Job,strAddLink_User,strAddLink_Website, nil];
//    
//    [actSheet showInView:self.view];
    
    
    
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *act_Job_1 = [UIAlertAction actionWithTitle:strAddLink_Job style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 [self link_Job_1];
                             }];
    
    UIAlertAction *act_User_2 = [UIAlertAction actionWithTitle:strAddLink_User style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    [self link_User_2];
                                }];
    
    UIAlertAction *act_Website_3 = [UIAlertAction actionWithTitle:strAddLink_Website style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
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
    
    //******** THIS IS THE IMPORTANT PART!!!  ***********
    actionSheetController.view.tintColor = RGBCOLOR_GREEN;
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

-(void)link_Job_1
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
-(void)link_User_2
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
-(void)link_Website_3
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Add Link" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                {
                                    [alertC dismissViewControllerAnimated:YES completion:nil];
                                }];
    UIAlertAction *AddWebsite = [UIAlertAction actionWithTitle:@"Add Website" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 UITextField *txt = alertC.textFields[0];
                                 NSLog(@"%@",txt.text);
                                 strLink_Website = txt.text;
                             }];
    
    [alertC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
       
        textField.text = @"";
        textField.placeholder = @"add Text";
        textField.font = kFONT_LIGHT(14.0);
    }];
    
    [alertC addAction:cancel];
    [alertC addAction:AddWebsite];
    [self presentViewController:alertC animated:YES completion:nil];
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
