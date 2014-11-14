//
//  C_AppDelegate.m
//  Crowd
//
//  Created by MAC107 on 05/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_AppDelegate.h"
#import "AppConstant.h"
#import "C_LoginVC.h"
#import "Reachability.h"
#import "MMDrawerController.h"

#import "C_OtherUserProfileVC.h"
#import "C_MessageListVC.h"
#import "C_JobListModel.h"
#import "C_JobViewVC.h"
#import "C_PostJob_UpdateVC.h"

#import "C_MessageModel.h"

#import "C_MessageView.h"
#import "C_TwilioClient.h"
#import "C_CallViewController.h"


@interface C_AppDelegate()
{
    JSONParser *parser;
}
@end
@implementation C_AppDelegate
@synthesize twilioClient;
@synthesize alertIncomingCall;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString* activityName = @"application:didFinishLaunchingWithOptions:";
    
    /*--- com.symposium.crowd ---*/
    /*--- Create Initial Window ---*/
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    /*--- Setup Push Notification ---*/
    //For iOS 8
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)] && [UIApplication instancesRespondToSelector:@selector(registerForRemoteNotifications)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }
    //For iOS 7 & less
    else if ([UIApplication instancesRespondToSelector:@selector(registerForRemoteNotificationTypes:)])
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;


    
    /*--- Navigationbar setup ---*/    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:62.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           kFONT_THIN(20.0), NSFontAttributeName, nil]];

    /*--- SVprogressHUD Setup ---*/
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setFont:[UIFont fontWithName:@"HelveticaNueue-Thin" size:14.8f]];
    
    /*--- If user loggedin then get app user info
     else if user login with linkedin but not register ---*/
    if ([UserDefaults objectForKey:APP_USER_INFO])
    {
        LOG_TWILIO(0,@"%@Detected user is logged in, starting twilio client",activityName);
        userInfoGlobal = [UserHandler_LoggedIn getMyUser_LoggedIN];
        self.twilioClient = [C_TwilioClient sharedInstance];

    }
    else if ([UserDefaults objectForKey:USER_INFO])
    {
        LOG_TWILIO(0,@"%@User is not logged in, skipping initialization of Twilio client",activityName);
        myUserModel = [CommonMethods getMyUser];
    }
    if (![UserDefaults objectForKey:PROFILE_PREVIEW])
    {
        [UserDefaults setValue:@"no" forKey:PROFILE_PREVIEW];
        [UserDefaults synchronize];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pendingIncomingConnectionReceived:)
                                                 name:WTPendingIncomingConnectionReceived
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pendingIncomingConnectionDidDisconnect:)
                                                 name:WTPendingIncomingConnectionDidDisconnect
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserLoggedInNotification:)
                                                 name:kNotification_UserLoggedIn
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserLoggedOutNotification:)
                                                 name:kNotification_UserLoggedOut
                                               object:nil];
    
    /*--- SDWebImage setup ---*/
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"Crowd Image" forHTTPHeaderField:@"Crowd"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    /*--- Do Not Back Up code Execution ---*/
    [CommonMethods addSkipBackupAttributeToItemAtPath];
    
    self.window = [[UIWindow alloc]initWithFrame:screenSize];
    self.objLoginVC = [[C_LoginVC alloc]initWithNibName:@"C_LoginVC" bundle:nil];
    self.navC = [[UINavigationController alloc]initWithRootViewController:self.objLoginVC];
    self.window.rootViewController = self.navC;
    self.navC.navigationBar.translucent = NO;
    [self.window makeKeyAndVisible];
    
    
    /*--- open Specific notification ---*/
    NSDictionary* notifInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notifInfo)
    {
        [self SetUpActionWhenPushNotiClicked:notifInfo application:application PushPop:NO];
    }
    
    
    return YES;
}

- (void) onUserLoggedInNotification:(NSNotification*)notification
{
    NSString* activityName = @"onUserLoggedInNotification:";

    LOG_TWILIO(0,@"%@Received login notification, creating instance of TwilioClient to start call functionality",activityName);
    self.twilioClient = [C_TwilioClient sharedInstance];
    
    if (!self.twilioClient.loggedIn)
    {
        [self.twilioClient login];
    }
}

- (void) onUserLoggedOutNotification:(NSNotification*)notification
{
    NSString* activityName = @"onUserLoggedOutNotification:";
   
    LOG_TWILIO(0,@"%@Received logout notification, destroying instance of TwilioClient",activityName);
    
    self.twilioClient = nil;
}
//- (BOOL)setKeepAliveTimeout:(NSTimeInterval)timeout handler:
-(BOOL)isConnected
{
    /*--- Check Internet Connectivity ---*/
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*--- get unread message count when app come from bg ---*/
    if ([UserDefaults objectForKey:APP_USER_INFO]) {
        [self getMessageUnreadCount];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* activityName = @"alertView:clickedButtonAtIndex:";
    if (buttonIndex == 0)
    {
        LOG_TWILIO(0,@"%@User has chosen to accept incoming call",activityName);
        
        C_CallViewController* cvc = [C_CallViewController createForReceiving];
        [self.navC presentViewController:cvc animated:YES completion:nil];
        [[C_TwilioClient sharedInstance] acceptIncomingConnection];
        
    }
    else if (buttonIndex == 1)
    {
        LOG_TWILIO(0,@"%@User has chosen to ignore incoming call",activityName);
        [[C_TwilioClient sharedInstance] ignoreIncomingConnection];
    }
}
#pragma mark - Call Handling

-(void)constructAlert
{
    self.alertIncomingCall = [[UIAlertView alloc] initWithTitle:@"Incoming Call"
                                             message:@"Accept or Ignore?"
                                            delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:@"Accept",@"Ignore",nil];
    [self.alertIncomingCall show];
}

-(void)cancelAlert
{
    if ( self.alertIncomingCall )
    {
        [self.alertIncomingCall dismissWithClickedButtonIndex:1 animated:YES];
        self.alertIncomingCall = nil;
    }
}

-(BOOL)isForeground
{

    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    return (state==UIApplicationStateActive);
}

-(void)pendingIncomingConnectionReceived:(NSNotification*)notification
{
    NSString* activityName = @"pendingIncomingConnectionReceived:";
    LOG_TWILIO(0,@"%@Delegate received notification of incoming call",activityName);
    //Show alert view asking if user wants to accept or ignore call
    [self performSelectorOnMainThread:@selector(constructAlert) withObject:nil waitUntilDone:NO];
    
    //Check for background support
    if ( ![self isForeground] )
    {
        //App is not in the foreground, so send LocalNotification
        UIApplication* app = [UIApplication sharedApplication];
        UILocalNotification* notification = [[UILocalNotification alloc] init];
        NSArray* oldNots = [app scheduledLocalNotifications];
        
        if ([oldNots count]>0)
        {
            [app cancelAllLocalNotifications];
        }
        
        notification.alertBody = @"Incoming Call";
        LOG_TWILIO(0,@"%@App is not in foreground, displaying call notification",activityName);
        [app presentLocalNotificationNow:notification];
 
    }
    else
    {
        LOG_TWILIO(0,@"%@App is in foregound",activityName);
    }
    
}


-(void)pendingIncomingConnectionDidDisconnect:(NSNotification*)notification
{
    // Make sure to cancel any pending notifications/alerts
    [self performSelectorOnMainThread:@selector(cancelAlert) withObject:nil waitUntilDone:NO];
    if ( ![self isForeground] )
    {
        //App is not in the foreground, so kill the notification we posted.
        UIApplication* app = [UIApplication sharedApplication];
        [app cancelAllLocalNotifications];
    }
    
   
}

#pragma mark - Notification
#pragma mark - For Remote Notification
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    //    if ([identifier isEqualToString:@"declineAction"]){
    //    }
    //    else if ([identifier isEqualToString:@"answerAction"]){
    //    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *device_Token = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [UserDefaults setValue:device_Token forKey:DEVICE_TOKEN];
    [UserDefaults synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        [UserDefaults setValue:@"" forKey:DEVICE_TOKEN];
        [UserDefaults synchronize];
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"error : %@",error.localizedDescription);
        [UserDefaults setValue:@"" forKey:DEVICE_TOKEN];
        [UserDefaults synchronize];
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // push some specific view when notification received
    [self SetUpActionWhenPushNotiClicked:userInfo application:application PushPop:NO];
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //[self SetUpActionWhenPushNotiClicked:notification.userInfo application:application PushPop:NO];
}
#pragma mark - PUSH NOTIFICATION MANAGER
-(void)SetUpActionWhenPushNotiClicked:(NSDictionary*)userInfo application:(UIApplication *)application PushPop:(BOOL)pushpop
{
    NSLog(@"UserInfo : %@",userInfo);
    application.applicationIconBadgeNumber = 0;
    /*
     {
     1. Message
     aps =     {
         alert =         
         {
         body = xzczxczxcxcxc;
        "loc-args" = (NewMessage,61);
         };
    };
     
     
     2. Follow
     aps =     {
     alert =
         {
         body = xzczxczxcxcxc;
         "loc-args" = (FollowUser,61);
         };
     };
     
     3. Job Application
     aps =     {
     alert =
         {
         body = xzczxczxcxcxc;
         "loc-args" = (JobApplication,61,118);
         };
     };
     
     
     4. Approve Job
     aps =     {
     alert =
         {
         body = xzczxczxcxcxc;
         "loc-args" = (ApproveJobApplication,61,118);
         };
     };
     
     5. Decline Job
     aps =     {
     alert =
         {
         body = xzczxczxcxcxc;
         "loc-args" = (DeclineJobApplication,61,118);
         };
     };
     t
     6. Fill Job
     aps =     {
     alert =
         {
         body = xzczxczxcxcxc;
         "loc-args" = (FillJob,61,118);
         };
     };

     7. A job you posted has gone unfilled for 30 days.*
     aps =     {
     alert =
         {
         body = xzczxczxcxcxc;
         "loc-args" = (Unfilled30days,61,118);
         };
     };
     */
    //Get User Data
    if (userInfo)
    {
        //NSString *data =  [NSString stringWithFormat:@"%@", userInfo];0
        //NSLog(@"%@",data);
        if (application.applicationState == UIApplicationStateActive )
        {
            //NSLog(@"app is already open");

            if ([[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] objectForKey:@"loc-args"])
            {
                if ([[[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] objectForKey:@"loc-args"] isKindOfClass:[NSArray class]])
                {
                    NSArray *arr = [[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] objectForKey:@"loc-args"];
                    if (arr.count>1)
                    {
                        NSString *strType = arr[0];
                        //NSString *otherUserid = arr[1];
                        //lblNotificationTemp.text = [NSString stringWithFormat:@"%@",strType];
                        if ([strType isEqualToString:@"NewMessage"])
                        {
                            //go to message + get notification count
                            @try
                            {
                                NSString *otherUserid = arr[1];
                                [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_GetMessage object:nil];
                                [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_Update_MessageList object:otherUserid];
                                                            }
                            @catch (NSException *exception) {
                                NSLog(@"%@",exception.description);
                            }
                            @finally {
                            }
                            
                            [self getMessageUnreadCount];

                            
                        }
                    }
                }
            }
        }
        else if (application.applicationState == UIApplicationStateBackground ||
                 application.applicationState == UIApplicationStateInactive)
        {
            //NSLog(@"app is coming from bg");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                for (UIViewController *navC in appDel.navC.viewControllers)
                {
                    if ([navC isKindOfClass:[MMDrawerController class]])
                    {
                        MMDrawerController *draw = (MMDrawerController *)navC;
                        UINavigationController *navvvv =  (UINavigationController *)draw.centerViewController;
                        [self pushViewUsingNav:navvvv withDict:userInfo withMMDraw:draw];
                    }
                }
            });
            
        }
    }
}

-(void)pushViewUsingNav:(UINavigationController *)navC withDict:(NSDictionary *)userInfo withMMDraw:(MMDrawerController *)drawer
{
    //lblNotificationTemp.text = [NSString stringWithFormat:@"%@",notif.object];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @try
        {
            if ([[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] objectForKey:@"loc-args"])
            {
                if ([[[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] objectForKey:@"loc-args"] isKindOfClass:[NSArray class]])
                {
                    
                    NSArray *arr = [[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] objectForKey:@"loc-args"];
                    if (arr.count>1)
                    {
                        [self getMessageUnreadCount];
                        NSString *strType = arr[0];
                        NSString *otherUserid = arr[1];
                        //lblNotificationTemp.text = [NSString stringWithFormat:@"%@",strType];
                        //1
                        if ([strType isEqualToString:@"NewMessage"])
                        {
                            //go to message
                            UIViewController *vc = [[navC viewControllers]lastObject];
                            if (![vc isKindOfClass:[C_MessageView class]])
                            {
                                NSDictionary *dictTemp = @{@"UserId":otherUserid};
                                NSDictionary *dictSender = @{@"SenderDetail":dictTemp};
                                C_MessageModel *model = [C_MessageModel addMessageList:dictSender];
                                C_MessageView *obj = [[C_MessageView alloc]initWithNibName:@"C_MessageView" bundle:nil];
                                obj.message_UserInfo = model;
                                [navC pushViewController:obj animated:YES];
                            }
                            else
                            {
                                [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_GetMessage object:nil];
                            }
                        }
                        //2
                        else if ([strType isEqualToString:@"FollowUser"])
                        {
                            //goto user
//                            UIViewController *vc = [[navC viewControllers]lastObject];
//                            if (![vc isKindOfClass:[C_OtherUserProfileVC class]])
//                            {
                                C_OtherUserProfileVC *obj = [[C_OtherUserProfileVC alloc]initWithNibName:@"C_OtherUserProfileVC" bundle:nil];
                                obj.OtherUserID = otherUserid;
                                [navC pushViewController:obj animated:YES];
//                            }
                            
                        }
                        //3
                        else if([strType isEqualToString:@"JobApplication"])
                        {
                            //go to messagelist view
                            C_MessageListVC *objM = [[C_MessageListVC alloc]initWithNibName:@"C_MessageListVC" bundle:nil];
                            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objM];
                            navvv.navigationBar.translucent = NO;
                            [drawer setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                                
                            }];
                        }
                        // 4 ,5 ,6
                        else if ([strType isEqualToString:@"ApproveJobApplication"] ||
                                 [strType isEqualToString:@"DeclineJobApplication"] ||
                                 [strType isEqualToString:@"FillJob"] )
                        {
                            @try
                            {
//                                UIViewController *vc = [[navC viewControllers]lastObject];
//                                if (![vc isKindOfClass:[C_JobViewVC class]])
//                                {
                                    //go to other user job
                                    NSString *jobID = arr[2];
                                    C_JobListModel *myJob = [[C_JobListModel alloc]init];
                                    myJob.JobID = jobID;
                                    C_JobViewVC *obj = [[C_JobViewVC alloc]initWithNibName:@"C_JobViewVC" bundle:nil];
                                    obj.obj_myJob = myJob;
                                    [navC pushViewController:obj animated:YES];
//                                }
                                
                            }
                            @catch (NSException *exception) {
                                NSLog(@"%@",exception.description);
                            }
                            @finally {
                            }
                        }
                        // unfilled job = 7
                        else if ([strType isEqualToString:@"Unfilled30days"])
                        {
                            @try
                            {
                                UIViewController *vc = [[navC viewControllers]lastObject];
                                if (![vc isKindOfClass:[C_PostJob_UpdateVC class]])
                                {
                                    //go to other user job
                                    NSString *jobID = arr[2];
                                    C_JobListModel *myJob = [[C_JobListModel alloc]init];
                                    myJob.JobID = jobID;
                                    C_PostJob_UpdateVC *objD = [[C_PostJob_UpdateVC alloc]initWithNibName:@"C_PostJob_UpdateVC" bundle:nil];
                                    objD.obj_JobListModel = myJob;
                                    objD.strComingFrom = @"FindAJob";
                                    [navC pushViewController:objD animated:YES];
                                }
                                
                            }
                            @catch (NSException *exception) {
                                NSLog(@"%@",exception.description);
                            }
                            @finally {
                            }
                        }
                    }
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        
//    });
}



#pragma mark - GET Unread Message Count
-(void)getMessageUnreadCount
{
    @try
    {
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token};
        parser = [[JSONParser alloc]initWith_withURL:Web_GET_UNREAD_MESSAGE_COUNT withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(getDataSuccessfull:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}
-(void)getDataSuccessfull:(id)objResponse
{
    //NSLog(@"Response > %@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
    }
    else if([objResponse objectForKey:@"GetUnreadMessageCountResult"])
    {
        /*--- Save data here ---*/
        @try
        {
            BOOL isUnreadMessage = [[objResponse valueForKeyPath:@"GetUnreadMessageCountResult.ResultStatus.Status"] boolValue];
            if (isUnreadMessage)
            {
                //got
                
                    NSString *strNotifCount = [NSString stringWithFormat:@"%@",[objResponse valueForKeyPath:@"GetUnreadMessageCountResult.NumberOfUnreadMessage"]];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateUnreadMessageCount" object:strNotifCount];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
    }
    else
    {
    }
    
}
#pragma mark - Extra
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    

    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*--VOIP Handler registration */
    [[UIApplication sharedApplication] setKeepAliveTimeout:30.0f handler:^{
        LOG_TWILIO(0,@"setKeepAliveTimeout: VOIP handler fired");
        
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //we clear our availability with the server
    C_TwilioClient* tc = [C_TwilioClient sharedInstance];
    [tc setCallAvaibility:NO];
}

@end
