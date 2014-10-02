//
//  C_MP_WorkHistoryVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_WorkHistoryVC.h"
#import "AppConstant.h"
#import "C_Cell_History.h"
#import "C_MyProfileVC.h"
#import "UpdateProfile.h"

#import "C_MP_EditTextVC.h"
#import "C_MP_EditTimeVC.h"
#import "C_MP_EditLocationVC.h"

#import "C_MP_EducationHistory.h"
@interface C_MP_WorkHistoryVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    
    NSMutableArray *arrSectionHeader;
}


@end

@implementation C_MP_WorkHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Work History";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(doneClicked)];
    self.automaticallyAdjustsScrollViewInsets = NO;

    NSArray *arrT = @[@"Job Title",@"Employer",@"Time Period",@"Location",@"Summary"];
    arrSectionHeader = [[NSMutableArray alloc]init];
    for (int i = 0; i<_obj_ProfileUpdate.arr_WorkALL.count; i++)
    {
        [arrSectionHeader addObjectsFromArray:arrT];
    }
    if (_obj_ProfileUpdate.arr_RecommendationALL.count>0) {
        [arrSectionHeader addObject:@"Recommendations"];
    }
    
    
    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_History" bundle:nil] forCellReuseIdentifier:cellHistoryID];
}
-(void)back
{
    popView;
}
-(void)doneClicked
{
    if ([self checkValidation])
    {
        UpdateProfile *profile = [[UpdateProfile alloc]init];
        [profile updateProfile_WithModel:_obj_ProfileUpdate withSuccessBlock:^{
            for (UIViewController *vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[C_MyProfileVC class]])
                {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        } withFailBlock:^(NSString *strError) {
            [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
        }];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tblView reloadData];
}
-(BOOL)checkValidation
{
    NSPredicate *predStartYear = [NSPredicate predicateWithFormat:@"(self.StartYear == nil) OR (self.StartYear == '')"];
    NSPredicate *predStartMonth = [NSPredicate predicateWithFormat:@"(self.StartMonth == nil) OR (self.StartMonth == '')"];
    NSPredicate *pred2 = [NSCompoundPredicate orPredicateWithSubpredicates:@[predStartYear, predStartMonth]];
    
    NSArray *arrFilterY = [_obj_ProfileUpdate.arr_WorkALL filteredArrayUsingPredicate:pred2];
    if (arrFilterY.count>0)
    {
        [CommonMethods displayAlertwithTitle:@"Please add Time period of your work" withMessage:nil withViewController:self];
        return NO;
    }
    
    NSPredicate *predLocation = [NSPredicate predicateWithFormat:@"(self.LocationCity == nil) OR (self.LocationCity == '')"];
    NSArray *arrFilterLocation = [_obj_ProfileUpdate.arr_WorkALL filteredArrayUsingPredicate:predLocation];
    if (arrFilterLocation.count>0)
    {
        [CommonMethods displayAlertwithTitle:@"Please add all Location" withMessage:nil withViewController:self];
        return NO;
    }
    
    // myWork.Summary
//    NSPredicate *predSummary = [NSPredicate predicateWithFormat:@"(self.Summary == nil) OR (self.Summary == '')"];
//    NSArray *arrFilterSummary = [_obj_ProfileUpdate.arr_WorkALL filteredArrayUsingPredicate:predSummary];
//    if (arrFilterSummary.count>0)
//    {
//        [CommonMethods displayAlertwithTitle:@"Please add Summary" withMessage:nil withViewController:self];
//        return NO;
//    }
    return YES;
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        C_MP_EducationHistory *obj = [[C_MP_EducationHistory alloc]initWithNibName:@"C_MP_EducationHistory" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        [self.navigationController pushViewController:obj animated:YES];
    }
}

#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionHeader.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([arrSectionHeader[section] isEqualToString:@"Recommendations"])
    {
        return _obj_ProfileUpdate.arr_RecommendationALL.count;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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
        C_Model_Recommendation *myRecommend = _obj_ProfileUpdate.arr_RecommendationALL[indexPath.row];
        CGFloat heightLBL = [myRecommend.Recommendation getHeight_withFont:[UIFont systemFontOfSize:17.0] widht:screenSize.size.width - 64];
        NSString *strName = [[NSString stringWithFormat:@"%@",myRecommend.RecommenderName] isNull];
        CGFloat heightLBLNAME = [strName getHeight_withFont:kFONT_ITALIC_LIGHT(14.0) widht:screenSize.size.width - 64];
        return 12.0 + MAX(19.0, heightLBL) + 7.0 + MAX(0.0, heightLBLNAME) + 3.0;
    }
    else
    {
        C_Model_Work *myWork = _obj_ProfileUpdate.arr_WorkALL[indexPath.section/5];
       
        NSString *strText ;
        UIFont *fontT;
        switch (indexPath.section%5)
        {
            case 0:
                fontT = kFONT_BOLD(17.0);
                strText = [myWork.Title isNull];
                break;
            case 1:
                fontT = kFONT_BOLD(17.0);
                strText = [myWork.EmployerName isNull];
                break;
            case 2:
                fontT = kFONT_BOLD(17.0);
                if ([myWork.EndMonth isEqualToString:@""])
                {
                    strText = [[NSString stringWithFormat:@"%@ - Present",myWork.StartYear] isNull];
                }
                else
                {
                    strText = [NSString stringWithFormat:@"%@ - %@",myWork.StartYear,myWork.EndYear];
                }
                break;
            case 3:
            {
                fontT = kFONT_BOLD(17.0);
                
                NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
                if (![[myWork.LocationCity isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationCity isNull]];
                if (![[myWork.LocationState isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationState isNull]];
                if (![[myWork.LocationCountry isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationCountry isNull]];
                
                strText = [arrLoc componentsJoinedByString:@","];//
                strText = [strText stringByReplacingOccurrencesOfString:@"," withString:@", "];
                break;
            }
            case 4:
                fontT = kFONT_REGULAR(15.0);
                strText = [myWork.Summary isNull];
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
        C_Model_Recommendation *myRecommend = _obj_ProfileUpdate.arr_RecommendationALL[indexPath.row];
        cell.lblTitle.text = myRecommend.Recommendation;
        cell.lblTitle.font = kFONT_REGULAR(17.0);
        //cell.lblTitle.adjustsFontSizeToFitWidth = YES;
        
        cell.lblName.hidden = NO;
        cell.lblName.text = [[NSString stringWithFormat:@"%@",myRecommend.RecommenderName] isNull];
        cell.lblName.textColor = [UIColor lightGrayColor];
        cell.lblName.font = kFONT_ITALIC_LIGHT(14.0);
    }
    else
    {
        C_Model_Work *myWork = _obj_ProfileUpdate.arr_WorkALL[indexPath.section/5];
        NSString *strText ;
        UIFont *fontT;
        switch (indexPath.section%5)
        {
            case 0:
                fontT = kFONT_BOLD(17.0);
                strText = [myWork.Title isNull];
                break;
            case 1:
                fontT = kFONT_BOLD(17.0);
                strText = [myWork.EmployerName isNull];
                break;
            case 2:
                fontT = kFONT_BOLD(17.0);
                if ([myWork.EndMonth isEqualToString:@""])
                {
                    strText = [[NSString stringWithFormat:@"%@ - Present",myWork.StartYear] isNull];
                }
                else
                {
                    strText = [NSString stringWithFormat:@"%@ - %@",myWork.StartYear,myWork.EndYear];
                }
                break;
            case 3:
            {
                fontT = kFONT_BOLD(17.0);
                NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
                if (![[myWork.LocationCity isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationCity isNull]];
                if (![[myWork.LocationState isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationState isNull]];
                if (![[myWork.LocationCountry isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationCountry isNull]];
                
                strText = [arrLoc componentsJoinedByString:@","];//
                strText = [strText stringByReplacingOccurrencesOfString:@"," withString:@", "];
                break;
            }
            case 4:
                fontT = kFONT_REGULAR(15.0);
                strText = [myWork.Summary isNull];
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

#pragma mark - Edit Cliked - Open Specific Screen
-(void)btnEditClicked:(UIButton *)btnEdit
{
    //NSLog(@"%@",btnEdit.accessibilityHint);
    NSArray *arr = [btnEdit.accessibilityHint componentsSeparatedByString:@"_"];
    NSInteger section = [arr[0] integerValue];
    //NSInteger index = [arr[1] integerValue];
    NSString *strTitle = arrSectionHeader[section];
    if ([strTitle isEqualToString:@"Recommendations"])
    {
        // GOTO recommend with index
        C_MP_EditTextVC *obj = [[C_MP_EditTextVC alloc]initWithNibName:@"C_MP_EditTextVC" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        obj.strComingFrom = @"Position";
        obj.strTitle = strTitle;
        obj.selectedIndexToUpdate = [arr[1] integerValue];
        obj.arrContent = _obj_ProfileUpdate.arr_RecommendationALL;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else
    {
        //NSLog(@"Section  :  %ld",(long)section);
        
        NSInteger myIndexSelected = section/5;
        C_Model_Work *myWork = _obj_ProfileUpdate.arr_WorkALL[myIndexSelected];
        NSString *strText ;
        switch (section%5)
        {
            case 0:
                strText = [myWork.Title isNull];
                break;
            case 1:
                strText = [myWork.EmployerName isNull];
                break;
            case 2:
                if ([myWork.EndMonth isEqualToString:@""])
                {
                    strText = [[NSString stringWithFormat:@"%@ - Present",myWork.StartYear] isNull];
                }
                else
                {
                    strText = [NSString stringWithFormat:@"%@ - %@",myWork.StartYear,myWork.EndYear];
                }
                break;
            case 3:
            {
                NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
                if (![[myWork.LocationCity isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationCity isNull]];
                if (![[myWork.LocationState isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationState isNull]];
                if (![[myWork.LocationCountry isNull]isEqualToString:@""])
                    [arrLoc addObject:[myWork.LocationCountry isNull]];
                
                strText = [arrLoc componentsJoinedByString:@","];//
                strText = [strText stringByReplacingOccurrencesOfString:@"," withString:@", "];
            }
                break;
            case 4:
                strText = [myWork.Summary isNull];
                break;
            default:
                break;
        }
        //@[@"Job Title",@"Employer",@"Time Period",@"Location",@"Summary",@"Recommendations"]
        if ([strTitle isEqualToString:@"Time Period"])
        {
            C_MP_EditTimeVC *obj = [[C_MP_EditTimeVC alloc]initWithNibName:@"C_MP_EditTimeVC" bundle:nil];
            obj.obj_ProfileUpdate = _obj_ProfileUpdate;
            obj.strComingFrom = @"Position";
            obj.strTitle = strTitle;
            obj.selectedIndexToUpdate = myIndexSelected;
            obj.arrContent = _obj_ProfileUpdate.arr_WorkALL;
            [self.navigationController pushViewController:obj animated:YES];
        }
        else if ([strTitle isEqualToString:@"Location"])
        {
            C_MP_EditLocationVC *obj = [[C_MP_EditLocationVC alloc]initWithNibName:@"C_MP_EditLocationVC" bundle:nil];
            obj.obj_ProfileUpdate = _obj_ProfileUpdate;
            obj.strComingFrom = @"Position";
            obj.strTitle = strTitle;
            obj.selectedIndexToUpdate = myIndexSelected;
            obj.arrContent = _obj_ProfileUpdate.arr_WorkALL;
            [self.navigationController pushViewController:obj animated:YES];
        }
        else
        {
            C_MP_EditTextVC *obj = [[C_MP_EditTextVC alloc]initWithNibName:@"C_MP_EditTextVC" bundle:nil];
            obj.obj_ProfileUpdate = _obj_ProfileUpdate;
            obj.strComingFrom = @"Position";
            obj.strTitle = strTitle;
            obj.selectedIndexToUpdate = myIndexSelected;
            obj.arrContent = _obj_ProfileUpdate.arr_WorkALL;
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
