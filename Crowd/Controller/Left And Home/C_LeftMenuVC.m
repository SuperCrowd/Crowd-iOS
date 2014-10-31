//
//  C_LeftMenuVC.m
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_LeftMenuVC.h"
#import "AppConstant.h"
#import "M13BadgeView.h"

#import "C_MessageListVC.h"
#import "C_DashBoardVC.h"
#import "C_PostJob_NameVC.h"
#import "C_MyProfileVC.h"
#import "C_MyCrowdVC.h"
#import "C_MyJobsVC.h"

//#import "C_FindAJobVC.h"
//#import "C_Find_CandidateVC.h"

#import "MainViewController.h"

#define NAME @"NameKey"
#define IMG @"ImageKey"
typedef NS_ENUM(NSInteger, ChooseIndex)
{
    DASHBOARD = 0,
    MY_PROFILE = 1,
    FIND_A_JOB = 2,
    FIND_A_CANDIDATE = 3,
    POST_A_JOB = 4,
    MY_CROWD = 5,
    MY_JOBS = 6
};
@interface C_LeftMenuVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    __weak IBOutlet UIImageView *imgVUserPic;
    __weak IBOutlet UITableView *tblView;
    
    __weak IBOutlet UIButton *badgeSuperView;
    M13BadgeView *badgeView;
    
    NSArray *arrInfo;
    
    CGRect rectBtn_0;
    CGRect rectLBL_0;
    
    CGRect rectBtn;
    CGRect rectLbl;
    
    JSONParser *parser;
}
@end

@implementation C_LeftMenuVC
#pragma mark - View Did Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    arrInfo =  @[@{NAME:@"HOME",IMG:@"profile_home"},
                @{NAME:@"MY PROFILE",IMG:@"profile_my_profile"},
                @{NAME:@"FIND A JOB",IMG:@"profile_find_a_job"},
                @{NAME:@"FIND A CANDIDATE",IMG:@"profile_find_a_candidate"},
                @{NAME:@"POST A JOB LISTING",IMG:@"profile_post_a_jpb"},
                @{NAME:@"MY CROWD",IMG:@"profile_my_crowd"},
                @{NAME:@"MY JOBS",IMG:@"profile_job"}];
    
    CGFloat totalWidth = screenSize.size.width - 45.0;
    rectBtn_0 = CGRectMake(totalWidth/3, 2.0, 34.0, 34.0);
    rectLBL_0 = CGRectMake(totalWidth/3+39.0, 2.0, totalWidth/2-39.0, 34.0);
    
    rectBtn = CGRectMake(15.0, 2.0, 34.0, 34.0);
    rectLbl = CGRectMake(59.0, 2.0, screenSize.size.width - 45.0 - 69.0, 34.0);//20+34+5.0
    
    /*--- Round Imageview and load---*/
    imgVUserPic.layer.cornerRadius = (imgVUserPic.bounds.size.width)/2.0;
    imgVUserPic.layer.borderWidth = 1.25;
    imgVUserPic.layer.borderColor = RGBCOLOR_GREEN.CGColor;
    [imgVUserPic setContentMode:UIViewContentModeScaleAspectFill];
    [imgVUserPic setClipsToBounds:YES];
    

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUnreadCount:) name:@"updateUnreadMessageCount" object:nil];

    
    /*--- Badge setup ---*/
    badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 24.0, 24.0)];
    [badgeSuperView addSubview:badgeView];

    badgeView.text = userInfoGlobal.NumberOfUnreadMessage;
    badgeView.textColor = [UIColor whiteColor];
    badgeView.badgeBackgroundColor = [UIColor purpleColor];
    badgeView.borderColor = nil;
    badgeView.font = kFONT_REGULAR(13.0);
    badgeView.showGloss = NO;//
    badgeView.cornerRadius = 12.0f;
    badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
    badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
    badgeView.maximumWidth = 300;
    badgeView.hidesWhenZero = YES;
    badgeView.shadowBadge = NO;//
    badgeView.shadowBorder = NO;//
    badgeView.shadowText = NO;//
    badgeView.borderWidth = 0.0;
    
    
    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [imgVUserPic sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:userInfoGlobal.PhotoURL ]]];
}
-(void)updateUnreadCount:(NSNotification *)notif
{
    NSLog(@"%@",notif.object);
    badgeView.text = notif.object;
}

-(IBAction)btnMessageClicked:(id)sender
{
    for (UIViewController *navC in appDel.navC.viewControllers)
    {
        if ([navC isKindOfClass:[MMDrawerController class]])
        {
            MMDrawerController *draw = (MMDrawerController *)navC;
            UINavigationController *navvvv =  (UINavigationController *)draw.centerViewController;
            UIViewController *vc = [[navvvv viewControllers]objectAtIndex:0];
            if (![vc isKindOfClass:[C_MessageListVC class]]) {
                C_MessageListVC *objM = [[C_MessageListVC alloc]initWithNibName:@"C_MessageListVC" bundle:nil];
                UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objM];
                navvv.navigationBar.translucent = NO;
                [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                    
                }];
            }
            
            
            //[self pushViewUsingNav:navvvv withDict:userInfo withMMDraw:draw];
        }
    }
    
    
    
}
-(IBAction)btnLogoutClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Logout" otherButtonTitles:nil ,nil];
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self logOutNow];
            break;
        case 1:
            break;
        default:
            break;
    }
}
-(void)logOutNow
{
    @try
    {
        showHUD_with_Title(@"Please Wait");
        
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token};
        parser = [[JSONParser alloc]initWith_withURL:Web_LOGOUT withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(logOutSuccessfull:) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        [CommonMethods displayAlertwithTitle:@"Please Try Again" withMessage:nil withViewController:self];
    }
    @finally {
    }
    
}
-(void)logOutSuccessfull:(id)objResponse
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
    else if([objResponse objectForKey:@"LogoutUserResult"])
    {
        /*--- Save data here ---*/
        hideHUD;
        BOOL isJobList = [[objResponse valueForKeyPath:@"LogoutUserResult.Status"] boolValue];
        if (isJobList)
        {

            /*--- Remove all Defaults + Image Cache ---*/
            [UserDefaults removeObjectForKey:PROFILE_PREVIEW];
            [UserDefaults removeObjectForKey:USER_INFO];
            [UserDefaults removeObjectForKey:APP_USER_INFO];
            [SDWebImageManager.sharedManager.imageCache clearMemory];
            [SDWebImageManager.sharedManager.imageCache clearDisk];
            [appDel.navC popToRootViewControllerAnimated:YES];
        }
        else
        {
            [CommonMethods displayAlertwithTitle:[objResponse valueForKeyPath:@"LogoutUserResult.StatusMessage"] withMessage:nil withViewController:self];
        }
    }
    else
    {
        hideHUD;
        [self showAlert_withTitle:[objResponse objectForKey:kURLFail]];
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
                                       [self logOutNow];
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                [self logOutNow];
                break;
                
            default:
                break;
        }
    }
}
#pragma mark - Table Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38.0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrInfo.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
    UIButton *btnIcon;
    UILabel *lblTitle;

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        btnIcon = [[UIButton alloc]initWithFrame:rectBtn];
        btnIcon.tag = 100;
        btnIcon.userInteractionEnabled = NO;
        [cell.contentView addSubview:btnIcon];
        
        lblTitle = [[UILabel alloc]initWithFrame:rectLbl];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.font = kFONT_THIN(15.0);
        lblTitle.tag = 101;
        [cell.contentView addSubview:lblTitle];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (selectedLeftControllerIndex == indexPath.row)
        cell.backgroundColor = RGBCOLOR_GREEN;
    else
        cell.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    lblTitle = (UILabel *)[cell.contentView viewWithTag:101];
    lblTitle.text = arrInfo[indexPath.row][NAME];
    
    btnIcon = (UIButton *)[cell.contentView viewWithTag:100];
    [btnIcon setImage:[UIImage imageNamed:arrInfo[indexPath.row][IMG]] forState:UIControlStateNormal];
    
    
    if (indexPath.row == 0)
    {
        lblTitle.frame = rectLBL_0;
        btnIcon.frame = rectBtn_0;
    }
    else
    {
        lblTitle.frame = rectLbl;
        btnIcon.frame = rectBtn;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    selectedLeftControllerIndex = indexPath.row;
    ChooseIndex myInd = selectedLeftControllerIndex;
    switch (myInd) {
        case DASHBOARD:
        {
            C_DashBoardVC *objD = [[C_DashBoardVC alloc]initWithNibName:@"C_DashBoardVC" bundle:nil];
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objD];
            navvv.navigationBar.translucent = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        case MY_PROFILE:
        {
            C_MyProfileVC *objD = [[C_MyProfileVC alloc]initWithNibName:@"C_MyProfileVC" bundle:nil];
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objD];
            navvv.navigationBar.translucent = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        case FIND_A_JOB:
        {
            MainViewController *objC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
            objC.isForCandidate = NO;
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objC];
            navvv.navigationBar.translucent = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        case FIND_A_CANDIDATE:
        {
            MainViewController *objC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
            objC.isForCandidate = YES;
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objC];
            navvv.navigationBar.translucent = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        case POST_A_JOB:
        {
            is_PostJob_Edit_update = @"no";
            C_PostJob_NameVC *objP = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objP];
            navvv.navigationBar.translucent = NO;
            objP.isComeFromTutorial = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        case MY_CROWD:
        {
            C_MyCrowdVC *objC = [[C_MyCrowdVC alloc]initWithNibName:@"C_MyCrowdVC" bundle:nil];
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objC];
            navvv.navigationBar.translucent = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        case MY_JOBS:
        {
            C_MyJobsVC *objJ = [[C_MyJobsVC alloc]initWithNibName:@"C_MyJobsVC" bundle:nil];
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objJ];
            navvv.navigationBar.translucent = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        default:
            break;
    }
    [tblView reloadData];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
