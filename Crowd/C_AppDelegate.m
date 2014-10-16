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

@interface C_AppDelegate()
{
    JSONParser *parser;
}
@end
@implementation C_AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*--- com.symposium.crowd ---*/
    /*--- Create Initial Window ---*/
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    /*--- Setup Push Notification ---*/
    //For iOS 8
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)] && [UIApplication instancesRespondToSelector:@selector(registerForRemoteNotifications)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
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
        userInfoGlobal = [UserHandler_LoggedIn getMyUser_LoggedIN];
    }
    else if ([UserDefaults objectForKey:USER_INFO])
    {
        myUserModel = [CommonMethods getMyUser];
    }
    if (![UserDefaults objectForKey:PROFILE_PREVIEW])
    {
        [UserDefaults setValue:@"no" forKey:PROFILE_PREVIEW];
        [UserDefaults synchronize];
    }
    
    
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
    
    /*--- open Specific notification ---*/
    NSDictionary* notifInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notifInfo)
    {
        [self SetUpActionWhenPushNotiClicked:notifInfo application:application PushPop:NO];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}
-(BOOL)isConnected
{
    /*--- Check Internet Connectivity ---*/
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
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
-(void)SetUpActionWhenPushNotiClicked:(NSDictionary*)userInfo application:(UIApplication *)application PushPop:(BOOL)pushpop
{
    NSLog(@"UserInfo : %@",userInfo);
    application.applicationIconBadgeNumber = 0;
    /*
     {
     aps =     {
     alert =         {
     "action-loc-key" = Answer;
     body = xzczxczxcxcxc;
     };
     badge = 5;
     destination = 2;
     match = 1;
     messageType = 2;
     sound = default;
     };
     }
     
     */
    //Get User Data
    if (userInfo)
    {
        if (application.applicationState == UIApplicationStateActive )
        {
            //NSLog(@"app is already open");
            
        }
        else if (application.applicationState == UIApplicationStateBackground ||
                 application.applicationState == UIApplicationStateInactive)
        {
            //NSLog(@"app is coming from bg");
        }
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([UserDefaults objectForKey:APP_USER_INFO]) {
        [self getMessageUnreadCount];
    }
}
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
    NSLog(@"Response > %@",objResponse);
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
        BOOL isUnreadMessage = [[objResponse valueForKeyPath:@"GetUnreadMessageCountResult.ResultStatus.Status"] boolValue];
        if (isUnreadMessage)
        {
            //got
            @try
            {
                NSString *strNotifCount = [NSString stringWithFormat:@"%@",[objResponse valueForKeyPath:@"GetUnreadMessageCountResult.NumberOfUnreadMessage"]];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateUnreadMessageCount" object:strNotifCount];
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
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
