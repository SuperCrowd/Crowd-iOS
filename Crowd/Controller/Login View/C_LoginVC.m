//
//  C_LoginVC.m
//  Crowd
//
//  Created by MAC107 on 05/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_LoginVC.h"

#import "AppConstant.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

#import "C_UserModel.h"
#import "C_WelcomeVC.h"
#import "C_ProfilePreviewVC.h"
#import "DownloadManager.h"


#import "C_LeftMenuVC.h"
#import "C_DashBoardVC.h"

#import "C_TutorialVC.h"
@interface C_LoginVC ()
{
    LIALinkedInHttpClient *_client;
    JSONParser *parser;
    
    NSMutableDictionary *dictUserLinkedinProfile;
    
    BOOL isGoToHome;
}
@end

@implementation C_LoginVC


#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    isGoToHome = NO;
    /*--- First check if user login with linkedin if not stay here ---*/
    if ([UserDefaults objectForKey:APP_USER_INFO])
    {
      //push to home
      isGoToHome  = YES;
      self.navigationController.navigationBarHidden = YES;
      [self pushToHome:NO];
      return;
    }
    else if (![UserDefaults objectForKey:USER_INFO])
    {
        
    }
    /*--- then check if user has reached profile view but not register then directly goto profile preview ---*/
    else if ([[UserDefaults objectForKey:PROFILE_PREVIEW] isEqualToString:@"yes"])
    {
        //goto profile preview
        self.navigationController.navigationBarHidden = NO;
        C_ProfilePreviewVC *obj = [[C_ProfilePreviewVC alloc]initWithNibName:@"C_ProfilePreviewVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:NO];
    }
    /*--- if user is already logged in ---*/
    else
    {
        //Stay here
#warning - PLEASE CHECK WHOLE APP FOR BLANK USER WHO DIDN'T FILL ANY INFO
#warning - PLEASE CHECK HERE ALL CONDITION
        self.navigationController.navigationBarHidden = NO;
        C_WelcomeVC *obj = [[C_WelcomeVC alloc]initWithNibName:@"C_WelcomeVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:NO];
        return;
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (!isGoToHome)
    {
        self.navigationController.navigationBarHidden = NO;
    }
}

#pragma mark - Linked In Authentication

- (IBAction)btnLinkedInClicked:(id)sender
{
    if (!appDel.isConnected)
    {
        [CommonMethods displayAlertwithTitle:text_InternetCheck withMessage:nil withViewController:self];
        return;
    }
    
#warning - PLEASE SET NIL TO ADD NEW ACCOUNT EVERY TIME
    NSString *storedToken = nil;//[UserDefaults objectForKey:@"access_token"];
    if (storedToken == nil || storedToken == (NSString*)[NSNull null]) {
        
        [self.client getAuthorizationCode:^(NSString *code)
        {
            [self.client getAccessToken:code success:^(NSDictionary *accessTokenData)
             {
                 NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
                 [UserDefaults setObject:accessToken forKey:@"access_token"];
                 [UserDefaults synchronize];
                 
                 /*--- Get user data when get access token ---*/
                [self requestMeWithToken:accessToken];
                
            }
             failure:^(NSError *error) {
                 
                NSLog(@"Quering accessToken failed %@", error);
            }];
        }
        cancel:^{
            NSLog(@"Authorization was cancelled by user");
        }
        failure:^(NSError *error) {
            NSLog(@"Authorization failed %@", error);
        }];
        
    }
    else
    {
        NSLog(@"already has access Token ");
        /*--- Get user data if already have access token ---*/
        [self requestMeWithToken:storedToken];
    }
}
-(void)checkIfUserAlreadyExist:(NSString *)strUserid withDictionary:(NSDictionary *)dict
{
    dictUserLinkedinProfile = [NSMutableDictionary dictionaryWithDictionary:dict];
    //[C_UserModel addLinkedInProfile:dict];
    
    showHUD_with_Title(@"Let us check if you already exist on Crowd");
    parser = [[JSONParser alloc]initWith_withURL:Web_IS_USER_EXIST withParam:@{@"LinkedInID":strUserid} withData:nil withType:kURLPost withSelector:@selector(checkIfUserAlreadyExistSuccessful:) withObject:self];
}
-(void)checkIfUserAlreadyExistSuccessful:(id)objResponse
{
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
    else if([objResponse objectForKey:@"IsUserExistsResult"])
    {
        /*--- Save data here ---*/
        BOOL isUserExist = [[objResponse valueForKeyPath:@"IsUserExistsResult.ResultStatus.Status"] boolValue];
        if (!isUserExist)
        {
            // goto register wizard
            NSLog(@"Not exist");
            hideHUD;
            myUserModel = [C_UserModel addLinkedInProfile:dictUserLinkedinProfile];
            [CommonMethods saveMyUser:myUserModel];
            
            [[DownloadManager sharedManager]downloadImagewithURL:myUserModel.pictureUrl];
            
            self.navigationController.navigationBarHidden = NO;
            C_WelcomeVC *obj = [[C_WelcomeVC alloc]initWithNibName:@"C_WelcomeVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
        else
        {
            NSLog(@"already exist");
            // user already exist.
            // add data as per service
            // save user now
            userInfoGlobal = [C_MyUser addNewUser:[objResponse objectForKey:@"IsUserExistsResult"]];
            [UserHandler_LoggedIn saveMyUser_LoggedIN:userInfoGlobal];
            userInfoGlobal = [UserHandler_LoggedIn getMyUser_LoggedIN];
            
            [UserDefaults setValue:@"done" forKey:PROFILE_PREVIEW];
            [UserDefaults removeObjectForKey:USER_INFO];
            [UserDefaults synchronize];
            
            hideHUD;
            isGoToHome  = YES;
            [self pushToHome:YES];
        }
    }
    else
    {
        hideHUD;
        [CommonMethods displayAlertwithTitle:[objResponse objectForKey:kURLFail] withMessage:nil withViewController:self];
    }

}

- (void)requestMeWithToken:(NSString *)accessToken
{
    showHUD_with_Title(@"Getting your Linkedin profile...")
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address,location,industry,summary,picture-urls::(original),positions,educations,skills,recommendations-received)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result)
    {
        //https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address)?oauth2_access_token=%@&format=json
        NSLog(@"%@",result);
        if ([result isKindOfClass:[NSDictionary class]])
        {
            [self checkIfUserAlreadyExist:result[@"id"] withDictionary:result];
        }
        else
        {
            hideHUD
        }
        /*--- Check now if user already exist or not ---*/
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
        showHUD_with_error(@"Unknown Server Error. Please try again.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hideHUD;
        });
    }];
}
#pragma mark - Linkedin Methods
- (LIALinkedInHttpClient *)client
{
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.google.com"//http://www.ancientprogramming.com/liaexample
                                                                                    clientId:@"75ol7koq0lf0ed"
                                                                                clientSecret:@"dGeJeziMKJutfZhv"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_fullprofile", @"r_network",@"r_emailaddress",@"r_contactinfo"]];
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}



-(void)pushToHome:(BOOL)isAnimate
{
    selectedLeftControllerIndex = 0;
    self.navigationController.navigationBarHidden = YES;
    C_DashBoardVC *objDashBoardVC = [[C_DashBoardVC alloc] initWithNibName:@"C_DashBoardVC" bundle:nil];
    C_LeftMenuVC *objleftVC = [[C_LeftMenuVC alloc] initWithNibName:@"C_LeftMenuVC" bundle:nil];
    
    /*--- Init navigation ---*/
    UINavigationController *_navC = [[UINavigationController alloc] initWithRootViewController:objDashBoardVC];
    _navC.navigationBarHidden = YES;
    _navC.navigationBar.translucent = NO;
    /*--- Right controller ---*/
    MMDrawerController *drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:_navC
                                            leftDrawerViewController:objleftVC
                                            rightDrawerViewController:nil];
    [drawerController setShowsShadow:NO];
    [drawerController setRestorationIdentifier:@"MMDrawer"];
    [drawerController setMaximumLeftDrawerWidth:screenSize.size.width-45.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setShouldStretchDrawer:NO];

    [drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    
    [self.navigationController pushViewController:drawerController animated:isAnimate];
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
