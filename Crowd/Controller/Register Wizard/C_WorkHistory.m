//
//  C_Roles_ResponsibilityVC.m
//  Crowd
//
//  Created by MAC107 on 10/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_WorkHistory.h"
#import "AppConstant.h"
#import "C_UserModel.h"

#import "C_Cell_History.h"

#import "C_EditTextVC.h"
#import "C_EditTimeVC.h"
#import "C_EditLocationVC.h"

#import "C_EducationHistory.h"

#import "C_ProfilePreviewVC.h"
#import "C_Work_JobTitle.h"
@interface C_WorkHistory ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    __weak IBOutlet UILabel *lbl_Static_NoHistoryFound;
    NSMutableArray *arrSectionHeader;
}
@end

@implementation C_WorkHistory
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Work History";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([[UserDefaults objectForKey:PROFILE_PREVIEW]isEqualToString:@"yes"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    }
    

    
    
    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_History" bundle:nil] forCellReuseIdentifier:cellHistoryID];
}

-(void)btnDoneClicked:(id)sender
{
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[C_ProfilePreviewVC class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    //nidhi
    if (arrSectionHeader) {
        [arrSectionHeader removeAllObjects];
    }
    arrSectionHeader = [[NSMutableArray alloc]init];

    NSArray *arrT = @[@"Job Title",@"Employer",@"Time Period",@"Location",@"Roles and Responsibilities"];
    for (int i = 0; i<myUserModel.arrPositionUser.count; i++)
    {
        [arrSectionHeader addObjectsFromArray:arrT];
    }
    if (myUserModel.arrRecommendationsUser.count > 0)
    {
        [arrSectionHeader addObject:@"Recommendations"];
    }

    
    
    if (arrSectionHeader.count > 0)
    {
        lbl_Static_NoHistoryFound.alpha = 0.0;
    }
    else
    {
        lbl_Static_NoHistoryFound.alpha = 1.0;
    }
    [tblView reloadData];
}

-(IBAction)btnNextClicked:(id)sender
{
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(self.location_city == nil) OR (self.summary == nil)"];
    NSPredicate *predStartYear = [NSPredicate predicateWithFormat:@"(self.startDate_year == nil) OR (self.startDate_year == '')"];
    NSPredicate *predStartMonth = [NSPredicate predicateWithFormat:@"(self.startDate_month == nil) OR (self.startDate_month == '')"];
    NSPredicate *pred2 = [NSCompoundPredicate orPredicateWithSubpredicates:@[predStartYear, predStartMonth]];
    
    NSArray *arrFilterY = [myUserModel.arrPositionUser filteredArrayUsingPredicate:pred2];
    if (arrFilterY.count>0)
    {
        [CommonMethods displayAlertwithTitle:@"Please add Time period of your work" withMessage:nil withViewController:self];
        return;
    }
    
    
    NSPredicate *predLocation = [NSPredicate predicateWithFormat:@"(self.location_city == nil) OR (self.location_city == '')  And self.isCurrent == YES"];
    NSArray *arrFilterLocation = [myUserModel.arrPositionUser filteredArrayUsingPredicate:predLocation];
    if (arrFilterLocation.count>0)
    {
        [CommonMethods displayAlertwithTitle:@"Please fill in all locations" withMessage:nil withViewController:self];
        return;
    }
    
    
//    NSPredicate *predSummary = [NSPredicate predicateWithFormat:@"(self.summary == nil) OR (self.summary == '')"];
//    NSArray *arrFilterSummary = [myUserModel.arrPositionUser filteredArrayUsingPredicate:predSummary];
//    if (arrFilterSummary.count>0)
//    {
//        [CommonMethods displayAlertwithTitle:@"Please add Summary" withMessage:nil withViewController:self];
//        return;
//    }
    
    C_EducationHistory *obj = [[C_EducationHistory alloc]initWithNibName:@"C_EducationHistory" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}

#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  arrSectionHeader.count+ 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == arrSectionHeader.count) {
        return 0;
    }
    if ([arrSectionHeader[section] isEqualToString:@"Recommendations"])
    {
        return myUserModel.arrRecommendationsUser.count;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == arrSectionHeader.count) {
        return 50;
    }

    return 34.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == arrSectionHeader.count)
    {
        UIView *viewHeader = [[UIView alloc]init];
        viewHeader.frame = CGRectMake(0, 0, screenSize.size.width, 34.0);
        viewHeader.backgroundColor = [UIColor whiteColor];
        
        UIButton *btnAddSchool = [[UIButton alloc]initWithFrame:CGRectMake(60.0,10.0, screenSize.size.width-100.0, 30.0)];
        btnAddSchool.layer.cornerRadius = 10.0;
        if (arrSectionHeader.count == 0)
            [btnAddSchool setTitle:@"Add Work Experience" forState:UIControlStateNormal];
        else
            [btnAddSchool setTitle:@"Add Another Work Experience" forState:UIControlStateNormal];
        
        [btnAddSchool.titleLabel setFont:kFONT_LIGHT(15.0)];
        [btnAddSchool setBackgroundImage:[UIImage imageNamed:@"btnGreenBG"] forState:UIControlStateNormal];
        [btnAddSchool addTarget:self action:@selector(btnAddNewWorkCliked:) forControlEvents:UIControlEventTouchUpInside];
        [viewHeader addSubview:btnAddSchool];
        return viewHeader;
    }
    UIView *viewHeader = [[UIView alloc]init];
    viewHeader.frame = CGRectMake(0, 0, screenSize.size.width, 34.0);
    viewHeader.backgroundColor = RGBCOLOR_DARK_BROWN;
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, screenSize.size.width - 40, 24)];
    lblTitle.text = arrSectionHeader[section];
    lblTitle.textColor = [UIColor whiteColor];
    [viewHeader addSubview:lblTitle];
    return viewHeader;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //@[@"Job Title",@"Employer",@"Time Period",@"Location",@"Summary",@"Recommendations"]
    if ([arrSectionHeader[indexPath.section] isEqualToString:@"Recommendations"])
    {
        Recommendations *myRecommend = myUserModel.arrRecommendationsUser[indexPath.row];
        CGFloat heightLBL = [myRecommend.recommendationText getHeight_withFont:[UIFont systemFontOfSize:17.0] widht:screenSize.size.width - 64];
        NSString *strName = [[NSString stringWithFormat:@"%@ %@",myRecommend.recommender_firstName,myRecommend.recommender_lastName] isNull];
        CGFloat heightLBLNAME = [strName getHeight_withFont:kFONT_ITALIC_LIGHT(14.0) widht:screenSize.size.width - 64];
        return 12.0 + MAX(19.0, heightLBL) + 7.0 + MAX(0.0, heightLBLNAME) + 3.0;
    }
    else
    {
        Positions *myPosition = myUserModel.arrPositionUser[indexPath.section/5];
        NSString *strText ;
        UIFont *fontT;
        switch (indexPath.section%5)
        {
            case 0:
                fontT = kFONT_BOLD(17.0);
                strText = [myPosition.title isNull];
                break;
            case 1:
                fontT = kFONT_BOLD(17.0);
                strText = [myPosition.company_name isNull];
                break;
            case 2:
                fontT = kFONT_BOLD(17.0);
                if (myPosition.isCurrent)
                {
                    strText = [[NSString stringWithFormat:@"%@ - Present",myPosition.startDate_year] isNull];
                }
                else
                {
                    strText = [NSString stringWithFormat:@"%@ - %@",myPosition.startDate_year,myPosition.endDate_year];
                }
                break;
            case 3:
            {
                fontT = kFONT_BOLD(17.0);
                NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
                if (![[myPosition.location_city isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_city isNull]];
                if (![[myPosition.location_state isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_state isNull]];
                if (![[myPosition.location_country isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_country isNull]];
                
                strText = [arrLoc componentsJoinedByString:@","];//
                strText = [strText stringByReplacingOccurrencesOfString:@"," withString:@", "];
                break;
            }
            case 4:
                fontT = kFONT_REGULAR(15.0);
                strText = [myPosition.summary isNull];
                break;
            default:
                break;
        }
        
        
        CGFloat heightLBL = [strText getHeight_withFont:fontT widht:screenSize.size.width - 64.0];//btnedit 44 + 10 + lablewidth + 10
        return 12.0 + MAX(19.0, heightLBL+2) + 12.0;
    }
    return 45.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    C_Cell_History *cell = (C_Cell_History *)[tblView dequeueReusableCellWithIdentifier:cellHistoryID];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    cell.lblTitle.numberOfLines = 0;
    if ([arrSectionHeader[indexPath.section] isEqualToString:@"Recommendations"])
    {
        Recommendations *myRecommend = myUserModel.arrRecommendationsUser[indexPath.row];
        cell.lblTitle.text = myRecommend.recommendationText;
        cell.lblTitle.font = kFONT_REGULAR(17.0);
        //cell.lblTitle.adjustsFontSizeToFitWidth = YES;
        
        cell.lblName.hidden = NO;
        cell.lblName.text = [[NSString stringWithFormat:@"%@ %@",myRecommend.recommender_firstName,myRecommend.recommender_lastName] isNull];
        cell.lblName.textColor = [UIColor lightGrayColor];
        cell.lblName.font = kFONT_ITALIC_LIGHT(14.0);
    }
    else
    {
        Positions *myPosition = myUserModel.arrPositionUser[indexPath.section/5];
        NSString *strText ;
        UIFont *fontT;
        switch (indexPath.section%5)
        {
            case 0:
                fontT = kFONT_BOLD(17.0);
                strText = [myPosition.title isNull];
                break;
            case 1:
                fontT = kFONT_BOLD(17.0);
                strText = [myPosition.company_name isNull];
                break;
            case 2:
                fontT = kFONT_BOLD(17.0);
               
                if (myPosition.isCurrent)
                {
                    strText = [[NSString stringWithFormat:@"%@ - Present",myPosition.startDate_year] isNull];
                }
                else
                {
                    strText = [NSString stringWithFormat:@"%@ - %@",myPosition.startDate_year,myPosition.endDate_year];
                }
                break;
            case 3:
            {
                fontT = kFONT_BOLD(17.0);
                NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
                if (![[myPosition.location_city isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_city isNull]];
                if (![[myPosition.location_state isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_state isNull]];
                if (![[myPosition.location_country isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_country isNull]];
                
                strText = [arrLoc componentsJoinedByString:@","];//
                strText = [strText stringByReplacingOccurrencesOfString:@"," withString:@", "];
                break;
            }
            case 4:
                fontT = kFONT_REGULAR(15.0);
                strText = [myPosition.summary isNull];
                break;
            default:
                break;
        }
        cell.lblTitle.font = fontT;
        cell.lblTitle.text = strText;
        
        cell.lblName.hidden = YES;
    }

    cell.btnEdit.accessibilityHint = [NSString stringWithFormat:@"%ld_%ld",(long)indexPath.section,(long)indexPath.row];
    [cell.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Add New Experience
-(void)btnAddNewWorkCliked:(UIButton*)btnNew{
    [dictAddNewEducation removeAllObjects];
    NSLog(@"Add new school");
    C_Work_JobTitle *obj = [[C_Work_JobTitle alloc]initWithNibName:@"C_Work_JobTitle" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:obj];
    nav.navigationBar.translucent = NO;
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
    
}


#pragma mark - Edit Cliked - Open Specific Screen
-(void)btnEditClicked:(UIButton *)btnEdit
{
    //NSLog(@"%@",btnEdit.accessibilityHint);
    NSArray *arr = [btnEdit.accessibilityHint componentsSeparatedByString:@"_"];
    NSInteger section = [arr[0] integerValue];
    //NSInteger index = [arr[1] integerValue];
    NSString *strTitle = arrSectionHeader[section];
    if (([strTitle isEqualToString:@"Recommendations"]))
    {
        //NSLog(@"last Section with Index : %ld",index);
        // GOTO recommend with index
        C_EditTextVC *obj = [[C_EditTextVC alloc]initWithNibName:@"C_EditTextVC" bundle:nil];
        obj.strComingFrom = @"Position";
        obj.strTitle = strTitle;
        obj.selectedIndexToUpdate = [arr[1] integerValue];
        obj.arrContent = myUserModel.arrRecommendationsUser;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else
    {
        //NSLog(@"Section  :  %ld",(long)section);
    
        NSInteger myIndexSelected = section/5;
        Positions *myPosition = myUserModel.arrPositionUser[myIndexSelected];
        NSString *strText ;
        switch (section%5)
        {
            case 0:
                strText = [myPosition.title isNull];
                break;
            case 1:
                strText = [myPosition.company_name isNull];
                break;
            case 2:
                if (myPosition.isCurrent)
                {
                    strText = [[NSString stringWithFormat:@"%@ - Present",myPosition.startDate_year] isNull];
                }
                else
                {
                    strText = [NSString stringWithFormat:@"%@ - %@",myPosition.startDate_year,myPosition.endDate_year];
                }
                break;
            case 3:
            {
                NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
                if (![[myPosition.location_city isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_city isNull]];
                if (![[myPosition.location_state isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_state isNull]];
                if (![[myPosition.location_country isNull]isEqualToString:@""])
                    [arrLoc addObject:[myPosition.location_country isNull]];
                
                strText = [arrLoc componentsJoinedByString:@","];//
                strText = [strText stringByReplacingOccurrencesOfString:@"," withString:@", "];
            }
                break;
            case 4:
                strText = [myPosition.summary isNull];
                break;
            default:
                break;
        }
        //@[@"Job Title",@"Employer",@"Time Period",@"Location",@"Summary",@"Recommendations"]
        if ([strTitle isEqualToString:@"Time Period"])
        {
            C_EditTimeVC *obj = [[C_EditTimeVC alloc]initWithNibName:@"C_EditTimeVC" bundle:nil];
            obj.strComingFrom = @"Position";
            obj.strTitle = strTitle;
            obj.selectedIndexToUpdate = myIndexSelected;
            obj.arrContent = myUserModel.arrPositionUser;
            [self.navigationController pushViewController:obj animated:YES];
        }
        else if ([strTitle isEqualToString:@"Location"])
        {
            C_EditLocationVC *obj = [[C_EditLocationVC alloc]initWithNibName:@"C_EditLocationVC" bundle:nil];
            obj.strComingFrom = @"Position";
            obj.strTitle = strTitle;
            obj.selectedIndexToUpdate = myIndexSelected;
            obj.arrContent = myUserModel.arrPositionUser;
            [self.navigationController pushViewController:obj animated:YES];
        }
        else
        {
            C_EditTextVC *obj = [[C_EditTextVC alloc]initWithNibName:@"C_EditTextVC" bundle:nil];
            obj.strComingFrom = @"Position";
            obj.strTitle = strTitle;
            obj.selectedIndexToUpdate = myIndexSelected;
            obj.arrContent = myUserModel.arrPositionUser;
            [self.navigationController pushViewController:obj animated:YES];
        }
        //NSLog(@"Text : %@",strText);
    }
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
