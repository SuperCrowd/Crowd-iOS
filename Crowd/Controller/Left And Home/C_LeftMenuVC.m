//
//  C_LeftMenuVC.m
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_LeftMenuVC.h"
#import "AppConstant.h"

#import "C_DashBoardVC.h"
#import "C_PostJob_NameVC.h"


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
@interface C_LeftMenuVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UIImageView *imgVUserPic;
    __weak IBOutlet UITableView *tblView;
    
    NSArray *arrInfo;
    
    CGRect rectBtn_0;
    CGRect rectLBL_0;
    
    CGRect rectBtn;
    CGRect rectLbl;
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
    
    rectBtn = CGRectMake(20.0, 2.0, 34.0, 34.0);
    rectLbl = CGRectMake(59.0, 2.0, screenSize.size.width - 45.0 - 69.0, 34.0);//20+34+5.0
    
    /*--- Round Imageview and load---*/
    imgVUserPic.layer.cornerRadius = (imgVUserPic.bounds.size.width)/2.0;
    imgVUserPic.layer.borderWidth = 0.25;
    imgVUserPic.layer.borderColor = [UIColor clearColor].CGColor;
    [imgVUserPic setContentMode:UIViewContentModeScaleAspectFill];
    [imgVUserPic setClipsToBounds:YES];
    
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
    [imgVUserPic sd_setImageWithURL:userInfoGlobal.PhotoURL];
    
//    [self.mm_drawerController.centerViewController.view endEditing:YES];
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
        [cell.contentView addSubview:btnIcon];
        
        lblTitle = [[UILabel alloc]initWithFrame:rectLbl];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.font = kFONT_THIN(15.0);
        lblTitle.tag = 101;
        [cell.contentView addSubview:lblTitle];
        /*--- For Custom Cell ---*/
        //[[NSBundle mainBundle]loadNibNamed:@"" owner:self options:nil];
        //cell = myCell;
    }

    
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

        }
            break;
        case FIND_A_JOB:
            
            break;
        case FIND_A_CANDIDATE:
            
            break;
        case POST_A_JOB:
        {
            C_PostJob_NameVC *objP = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
            UINavigationController *navvv = [[UINavigationController alloc]initWithRootViewController:objP];
            navvv.navigationBar.translucent = NO;
            objP.isComeFromTutorial = NO;
            [self.mm_drawerController setCenterViewController:navvv withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }
            break;
        case MY_CROWD:
            
            break;
        case MY_JOBS:
            
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
