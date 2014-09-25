//
//  C_MP_EducationHistory.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_EducationHistory.h"
#import "AppConstant.h"
#import "C_Cell_History.h"
#import "C_Cell_Tags.h"

#import "UpdateProfile.h"
#import "C_MyProfileVC.h"

#import "C_MP_EditTimeVC.h"
#import "C_MP_EditTextVC.h"
#import "C_MP_EditTagVC.h"

#import "C_MP_ExperienceVC.h"

#import "C_Education_SchoolVC.h"
@interface C_MP_EducationHistory ()<UITableViewDataSource,UITableViewDelegate,DWTagListDelegate>
{
    __weak IBOutlet UITableView *tblView;
    
    NSMutableArray *arrSectionHeader;
}


@end

@implementation C_MP_EducationHistory

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Education";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(doneClicked)];
    self.automaticallyAdjustsScrollViewInsets = NO;

    /*--- Register Cell ---*/
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_History" bundle:nil] forCellReuseIdentifier:cellHistoryID];
    [tblView registerNib:[UINib nibWithNibName:@"C_Cell_Tags" bundle:nil] forCellReuseIdentifier:cellTagID];
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
    
    NSArray *arrT = @[@"School",@"Degree",@"Years",@"Courses"];
    arrSectionHeader = [[NSMutableArray alloc]init];
    for (int i = 0; i<_obj_ProfileUpdate.arr_EducationALL.count; i++)
    {
        [arrSectionHeader addObjectsFromArray:arrT];
    }
    [tblView reloadData];
}
#pragma mark - IBAction Method
-(BOOL)checkValidation
{
    NSPredicate *preddegree = [NSPredicate predicateWithFormat:@"(self.Degree == nil) OR (self.Degree == '')"];
    NSArray *arrcheckdegree = [_obj_ProfileUpdate.arr_EducationALL filteredArrayUsingPredicate:preddegree];;
    if (arrcheckdegree.count>0)
    {
        [CommonMethods displayAlertwithTitle:@"Please add Degree" withMessage:nil withViewController:self];
        return NO;
    }
    
    
    NSPredicate *predStartYear = [NSPredicate predicateWithFormat:@"(self.StartYear == nil) OR (self.StartYear == '')"];
    NSArray *arrstartyear = [_obj_ProfileUpdate.arr_EducationALL filteredArrayUsingPredicate:predStartYear];;
    if (arrstartyear.count>0)
    {
        [CommonMethods displayAlertwithTitle:@"Please add year of degree" withMessage:nil withViewController:self];
        return NO;
    }
    
    NSPredicate *predStartMonth = [NSPredicate predicateWithFormat:@"(self.StartMonth == nil) OR (self.StartMonth == '')"];
    NSArray *arrstartmonth = [_obj_ProfileUpdate.arr_EducationALL filteredArrayUsingPredicate:predStartMonth];;
    if (arrstartmonth.count>0)
    {
        [CommonMethods displayAlertwithTitle:@"Please add month of degree" withMessage:nil withViewController:self];
        return NO;
    }
    return YES;
}
-(IBAction)btnNextClicked:(id)sender
{
    //myEducation.Degree,myEducation.Name,myEducation.StartMonth,myEducation.StartYear,myEducation.EndMonth,myEducation.EndYear
    
//    NSPredicate *predField = [NSPredicate predicateWithFormat:@"(self.arrCourses == nil) OR (self.arrCourses == ())"];
//    NSArray *arrField = [_obj_ProfileUpdate.arr_EducationALL filteredArrayUsingPredicate:predField];;
//    if (arrField.count>0)
//    {
//        [CommonMethods displayAlertwithTitle:@"Please add Courses" withMessage:nil withViewController:self];
//        return;
//    };
    
    NSLog(@"Done");
    if ([self checkValidation])
    {
        C_MP_ExperienceVC *obj = [[C_MP_ExperienceVC alloc]initWithNibName:@"C_MP_ExperienceVC" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        [self.navigationController pushViewController:obj animated:YES];
    }
    //push now
}
#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionHeader.count + 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == arrSectionHeader.count) {
        return 0;
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
        
        UIButton *btnAddSchool = [[UIButton alloc]initWithFrame:CGRectMake(65.0,10.0, screenSize.size.width-130.0, 30.0)];
        btnAddSchool.layer.cornerRadius = 10.0;
        [btnAddSchool setTitle:@"Add Another School" forState:UIControlStateNormal];
        [btnAddSchool.titleLabel setFont:kFONT_LIGHT(15.0)];
        [btnAddSchool setBackgroundImage:[UIImage imageNamed:@"btnGreenBG"] forState:UIControlStateNormal];
        [btnAddSchool addTarget:self action:@selector(btnAddNewSchoolCliked:) forControlEvents:UIControlEventTouchUpInside];
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
    //@[@"School",@"Degree",@"Years",@"Courses"]
    NSString *strSectionName = arrSectionHeader[indexPath.section];
    if ([strSectionName isEqualToString:@"Courses"])
    {
        //Do different
        DWTagList *tagList = [[DWTagList alloc]initWithFrame:CGRectMake(50.0,11.0,screenSize.size.width - 50.0 -10.0 , 21.0)];
        C_Model_Education *myEducation = _obj_ProfileUpdate.arr_EducationALL[indexPath.section/4];
        
        NSMutableArray *arrC = [NSMutableArray array];
        for (C_Model_Courses *course in myEducation.arrCourses)
        {
            [arrC addObject:course.Course];
        }
        [tagList setTags:arrC];
        [tagList setAutomaticResize:YES];
        [tagList display];
        [tagList fittedSize];
        return MAX(45.0, 11.0 + [tagList fittedSize].height + 11.0);
        
    }
    else
    {
        C_Model_Education *myEducation = _obj_ProfileUpdate.arr_EducationALL[indexPath.section/4];
        NSString *strText ;
        switch (indexPath.section%4)
        {
            case 0:
                strText = [myEducation.Name isNull];
                break;
            case 1:
                strText = [myEducation.Degree isNull];
                break;
            case 2:
                strText = [NSString stringWithFormat:@"%@ - %@",myEducation.StartYear,myEducation.EndYear];
                break;
//            case 3:
//                strText = [myEducation.fieldOfStudy isNull];
//                break;
            default:
                break;
        }
        
        
        CGFloat heightLBL = [strText getHeight_withFont:kFONT_BOLD(17.0) widht:screenSize.size.width - 64];//btnedit 44 + 10 + lablewidth + 10
        
        return 12.0 + MAX(19.0, heightLBL) + 12.0;
    }
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strSectionName = arrSectionHeader[indexPath.section];
    if ([strSectionName isEqualToString:@"Courses"])
    {
        C_Cell_Tags *cell = (C_Cell_Tags *)[tblView dequeueReusableCellWithIdentifier:cellTagID forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        C_Model_Education *myEducation = _obj_ProfileUpdate.arr_EducationALL[indexPath.section/4];
        [cell.tagList setAutomaticResize:YES];
        
        NSMutableArray *arrC = [NSMutableArray array];
        for (C_Model_Courses *course in myEducation.arrCourses)
        {
            [arrC addObject:course.Course];
        }
        [cell.tagList setTags:arrC];
        [cell.tagList setTagDelegate:self];
        
        cell.btnEdit.accessibilityHint = [NSString stringWithFormat:@"%ld_%ld",(long)indexPath.section,(long)indexPath.row];
        [cell.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        // Customisation
        @try
        {
            cell.tagList.scrollEnabled = NO;
            [cell.tagList setCornerRadius:4.0f];
            [cell.tagList setHighlightedBackgroundColor:RGBCOLOR_DARK_BROWN];
            [cell.tagList setTextColor:[UIColor blackColor]];
            //        [cell.tagList setBorderColor:RGBCOLOR_DARK_BROWN.CGColor];
            [cell.tagList setTagBackgroundColor:RGBCOLOR_DARK_BROWN];
            [cell.tagList setBorderWidth:0.0f];
            [cell.tagList setTextShadowOffset:CGSizeMake(0, 0)];
            
            cell.tagList.translatesAutoresizingMaskIntoConstraints = NO;
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        
        return cell;
    }
    else
    {
        C_Cell_History *cell = (C_Cell_History *)[tblView dequeueReusableCellWithIdentifier:cellHistoryID forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lblTitle.numberOfLines = 0;
        C_Model_Education *myEducation = _obj_ProfileUpdate.arr_EducationALL[indexPath.section/4];
        NSString *strText ;
        switch (indexPath.section%4)
        {
            case 0:
                strText = [myEducation.Name isNull];
                break;
            case 1:
                strText = [myEducation.Degree isNull];
                break;
            case 2:
                
                strText = [NSString stringWithFormat:@"%@ - %@",[myEducation.StartYear isNull],[myEducation.EndYear isNull]];
                break;
//            case 3:
//                strText = [myEducation.fieldOfStudy isNull];
//                break;
            default:
                break;
        }
        cell.lblTitle.font = kFONT_BOLD(17.0);
        cell.lblTitle.text = strText;
        cell.lblName.hidden = YES;
        
        cell.btnEdit.accessibilityHint = [NSString stringWithFormat:@"%ld_%ld",(long)indexPath.section,(long)indexPath.row];
        [cell.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Add New Education
-(void)btnAddNewSchoolCliked:(id)sender
{
    [dictAddNewEducation removeAllObjects];
    NSLog(@"Add new school");
    C_Education_SchoolVC *obj = [[C_Education_SchoolVC alloc]initWithNibName:@"C_Education_SchoolVC" bundle:nil];
    obj.obj_ProfileUpdate = _obj_ProfileUpdate;
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
    
    NSString *strTitle = arrSectionHeader[section];

    NSInteger myIndexSelected = section/4;
    C_Model_Education *myEducation = _obj_ProfileUpdate.arr_EducationALL[myIndexSelected];

    //@[@"School",@"Degree",@"Years",@"Courses"]
    if ([strTitle isEqualToString:@"Years"])
    {
        C_MP_EditTimeVC *obj = [[C_MP_EditTimeVC alloc]initWithNibName:@"C_MP_EditTimeVC" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        obj.strComingFrom = @"Education";
        obj.strTitle = strTitle;
        obj.selectedIndexToUpdate = myIndexSelected;
        obj.arrContent = _obj_ProfileUpdate.arr_EducationALL;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if ([strTitle isEqualToString:@"Courses"])
    {
        C_MP_EditTagVC *obj = [[C_MP_EditTagVC alloc]initWithNibName:@"C_MP_EditTagVC" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        obj.strComingFrom = @"Education";
        obj.selectedIndexToUpdate = myIndexSelected;
        obj.arrContent = _obj_ProfileUpdate.arr_EducationALL;
        NSMutableArray *arrC = [NSMutableArray array];
        for (C_Model_Courses *course in myEducation.arrCourses)
        {
            [arrC addObject:course.Course];
        }
        obj.strTags = [arrC componentsJoinedByString:@","];
        [self.navigationController pushViewController:obj animated:YES];
    }
    
    else
    {
        C_MP_EditTextVC *obj = [[C_MP_EditTextVC alloc]initWithNibName:@"C_MP_EditTextVC" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        obj.strComingFrom = @"Education";
        obj.strTitle = strTitle;
        obj.selectedIndexToUpdate = myIndexSelected;
        obj.arrContent = _obj_ProfileUpdate.arr_EducationALL;
        [self.navigationController pushViewController:obj animated:YES];
    }
    //NSLog(@"Text : %@",strText);
    //    }
}

#pragma mark - Custom Delegate
-(void)reloadTable
{
    [tblView reloadData];
}
#pragma mark - Extra

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
