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
#define MESSAGE_COUNT @"30"
@interface C_MessageView ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
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
    IBOutlet MDMultilineTextView *multiTextView;
        
}
@property (nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

@property(nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic,strong)UITextView *textView;;
@property(nonatomic,strong)UITextView *tempTextView;;
@property (nonatomic, assign) float			previousTextFieldHeight;

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
    [tblView addSubview:self.refreshControl];
    
    //[self addGrowingTextView];
    //[self adddddddddddd];
    
    
    multiTextView.layer.cornerRadius = 5.0;
    multiTextView.layer.borderWidth = 0.25;
    multiTextView.layer.borderColor = RGBCOLOR(38, 38, 38).CGColor;
    [multiTextView setClipsToBounds:YES];
    
    /*--- Register Cell ---*/
    tblView.alpha = 0.0;
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //[tblView registerNib:[UINib nibWithNibName:@"C_Cell_Message_Simple" bundle:nil] forCellReuseIdentifier:cellMessageSimpleID];
    
    //[tblView registerNib:[UINib nibWithNibName:@"C_Cell_Message_Job" bundle:nil] forCellReuseIdentifier:cellMessageJOBID];
    
    /*--- Code to Show Default Refresh when view appear ---*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getRecentMessages];
    });
    
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
    [self.refreshControl endRefreshing];
    //[self getRecentMessages];
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
        [self showAlert_withTitle:@"Please Try Again"];
        isCallingService = NO;
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
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
            [self setData:[objResponse valueForKeyPath:@"GetMessageThreadResult.MesssageList"] withHandler:^{
                
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
            
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"GetMessageThreadResult.ResultStatus.StatusMessage"] withMessage:nil withViewController:self];
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
                [arrContent addObject:[MessageDetailModel addMessageDetail:dict]];
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
                                       [self getRecentMessages];
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
                [self getRecentMessages];
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
    return 10;//arrContent.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    C_MessageModel *myMessage = (C_MessageModel *)arrContent[indexPath.row];
//    if ([myMessage.Type isEqualToString:@"1"])
//    {
//        CGFloat heightCell = 0;
//        CGFloat txtH = [myMessage.strDisplayText getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 95.0];
//        heightCell = 13.0 + txtH + 26.0;
//        return MAX(90.0, heightCell);
//    }
//    else
//    {
//        CGFloat heightCell = 0;
//        CGFloat txtH = [myMessage.strDisplayText getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 95.0];
//        heightCell = 13.0 + txtH + 60.0;
//        return MAX(90.0, heightCell);
//    }
    return 90.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MessageDetailModel *myMessage = (MessageDetailModel *)arrContent[indexPath.row];
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        /*--- For Custom Cell ---*/
        //[[NSBundle mainBundle]loadNibNamed:@"" owner:self options:nil];
        //cell = myCell;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];//[NSString stringWithFormat:@"%@ - at %@",myMessage.Message,myMessage.strDisplayDate];
    return cell;

}

-(IBAction)btnSendClicked:(id)sender
{
    multiTextView.text = @"";
    [self textViewDidChange:multiTextView];
    [multiTextView resignFirstResponder];
    [multiTextView layoutIfNeeded];
    [viewChat layoutIfNeeded];
}

#pragma mark - 
#pragma mark - MultilineText
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
        
        @try
        {
            [tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tblView numberOfRowsInSection:0]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        
        
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
    if (textView.contentSize.height < multiTextView.maxHeight || textView.text.length == 0)
    {
        [textView invalidateIntrinsicContentSize];
    }
    [textView scrollRectToVisible:CGRectMake(0.0, textView.contentSize.height - 1.0f, 1.0, 1.0) animated:NO];
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
