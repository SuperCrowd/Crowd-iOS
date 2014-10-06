//
//  C_MP_EditTimeVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_EditTimeVC.h"
#import "AppConstant.h"
#import "UITextFieldExtended.h"

#define POSITION @"Position"
#define EDUCATION @"Education"

typedef NS_ENUM(NSInteger, btnTapped)
{
    btnFrom = 51,
    btnTo = 52,
    btnEditFrom = 61,
    btnEditTo = 62
};
@interface C_MP_EditTimeVC ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    __weak IBOutlet UITextFieldExtended *txtFrom;
    __weak IBOutlet UITextFieldExtended *txtTo;
    
    __weak IBOutlet UIPickerView *piker;
    
    NSString *strYear;
    NSString *strMonth;
    
    NSMutableArray *arrYear;
    NSArray *arrMonthTo;
    NSArray *arrMonthFrom;
    
    __weak IBOutlet UIBarButtonItem *btnToolbar;
    
    
    BOOL isUpdateFrom;
}

@end

@implementation C_MP_EditTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _strTitle;
    
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    
    /*--- 10 years more for study only ---*/
    NSInteger currentYear;//
    if ([_strComingFrom isEqualToString:POSITION])
    {
        currentYear = [[[NSDate date] convertDateinFormat:@"yyyy"] integerValue];
    }
    else if([_strComingFrom isEqualToString:EDUCATION])
    {
        currentYear = [[[[NSDate date] addYear:10] convertDateinFormat:@"yyyy"] integerValue];//[[[NSDate date] convertDateinFormat:@"yyyy"] integerValue];
    }
    @try
    {
        arrYear = [[NSMutableArray alloc]init];
        for (int i = 1900; i <= currentYear; i++)
        {
            [arrYear addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    
    arrMonthFrom = @[@"January",
                     @"February",
                     @"March",
                     @"April",
                     @"May",
                     @"June",
                     @"July",
                     @"August",
                     @"September",
                     @"October",
                     @"November",
                     @"December"];
    
    
    /*--- coming from which view to update data ---*/
    if ([_strComingFrom isEqualToString:POSITION])
    {
        arrMonthTo = @[@"Present",
                       @"January",
                       @"February",
                       @"March",
                       @"April",
                       @"May",
                       @"June",
                       @"July",
                       @"August",
                       @"September",
                       @"October",
                       @"November",
                       @"December"];
        strMonth = [[self getPosition_StartMonth] isNull];
        strYear = [[self getPosition_StartYear] isNull];
        if ([strMonth isEqualToString:@""])
            strMonth = arrMonthFrom[0];
        if ([strYear  isEqualToString:@""])
            strYear = arrYear[arrYear.count - 1];
        
        txtFrom.text = [NSString stringWithFormat:@"%@ %@",strMonth,strYear];
        
        
        NSString *strMonthEnd = [[self getPosition_EndMonth] isNull];
        NSString *strEndY = [[self getPosition_EndYear] isNull];
        if ([strMonthEnd isEqualToString:@""])
        {
            strMonthEnd = arrMonthTo[0];
        }
        if ([strEndY  isEqualToString:@""])
        {
            strEndY = arrYear[arrYear.count - 1];
        }
        
        
        if ([strMonthEnd isEqualToString:@"Present"])
            txtTo.text = @"Present";
        else
            txtTo.text = [NSString stringWithFormat:@"%@ %@",strMonthEnd,strEndY];
    }
    else if([_strComingFrom isEqualToString:EDUCATION])
    {
        arrMonthTo = @[@"January",
                       @"February",
                       @"March",
                       @"April",
                       @"May",
                       @"June",
                       @"July",
                       @"August",
                       @"September",
                       @"October",
                       @"November",
                       @"December"];
        strMonth = [[self getEducation_StartMonth] isNull];
        strYear = [[self getEducation_StartYear] isNull];
        
        if ([strMonth isEqualToString:@""])
            strMonth = arrMonthTo[0];
        if ([strYear  isEqualToString:@""])
            strYear = arrYear[arrYear.count - 10];
        
        txtFrom.text = [[NSString stringWithFormat:@"%@ %@",strMonth,strYear] isNull];
        
        NSString *strEndM = [[self getEducation_EndMonth] isNull];
        NSString *strEndY = [[self getEducation_EndYear] isNull];
        if ([strEndM isEqualToString:@""])
        {
            strEndM = arrMonthTo[0];
        }
        if ([strEndY  isEqualToString:@""])
        {
            strEndY = arrYear[arrYear.count - 10];
        }
        txtTo.text = [NSString stringWithFormat:@"%@ %@",strEndM,strEndY];
    }

    [piker reloadAllComponents];
    
    
    /*--- Search index using message id to remove from both array while searching ---*/
    btnToolbar.title = @"From";
    isUpdateFrom = YES;
    [self updatePiker];
}

-(void)updatePiker
{
    [piker reloadAllComponents];
    NSInteger indexMonth;
    
    @try
    {
        if (![strMonth isEqualToString:@""])
        {
            if (isUpdateFrom)
                indexMonth  = [arrMonthFrom indexOfObject:strMonth];
            else
                indexMonth  = [arrMonthTo indexOfObject:strMonth];
            
            [piker selectRow:indexMonth inComponent:0 animated:NO];
            
        }
        
        if (![strYear isEqualToString:@""])
        {
            NSInteger indexYear = [arrYear indexOfObject:strYear];
            [piker selectRow:indexYear inComponent:1 animated:NO];
        }
        
        
        if (isUpdateFrom)
            txtFrom.text = [NSString stringWithFormat:@"%@ %@",strMonth,strYear];
        
        else
            txtTo.text = [NSString stringWithFormat:@"%@ %@",strMonth,strYear];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}
#pragma mark - IBAction
-(void)back
{
    popView;
}
-(IBAction)btnEditClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    btnTapped btnT = btn.tag;
    
    @try
    {
        if (btnT == btnFrom || btnT == btnEditFrom)
        {
            isUpdateFrom = YES;
            btnToolbar.title = @"From";
            strMonth = [[[txtFrom.text isNull] componentsSeparatedByString:@" "] objectAtIndex:0];
            strYear = [[[txtFrom.text isNull] componentsSeparatedByString:@" "] objectAtIndex:1];
            
            [self updatePiker];
        }
        else
        {
            isUpdateFrom = NO;
            btnToolbar.title = @"To";
            strMonth = [[[txtTo.text isNull] componentsSeparatedByString:@" "] objectAtIndex:0];
            
            if (![strMonth isEqualToString:@"Present"])
            {
                strYear = [[[txtTo.text isNull] componentsSeparatedByString:@" "] objectAtIndex:1];
                [self updatePiker];
            }
            else
            {
                [piker reloadAllComponents];
                [piker selectRow:0 inComponent:0 animated:NO];
                //[piker selectRow:arrYear.count-1 inComponent:1 animated:NO];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}
-(IBAction)btnDoneClicked:(id)sender
{
    if ([_strComingFrom isEqualToString:POSITION])
    {
        [self savePositionNOW];
    }
    else if([_strComingFrom isEqualToString:EDUCATION])
    {
        [self saveEducationNOW];
    }
}
#pragma mark - Save Position
-(void)savePositionNOW
{
    @try
    {
        NSArray *arrMonthStart = [[txtFrom.text isNull] componentsSeparatedByString:@" "];
        
        C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
        
        BOOL result = NO;
        /*--- If user choose present no need to check validation otherwise check date Validation ---*/
        if ([[txtTo.text isNull] isEqualToString:@"Present"])
        {
            //myWork.isCurrent = @"1";
            result = YES;
        }
        else
        {
            NSArray *arrMonthEnd = [[txtTo.text isNull] componentsSeparatedByString:@" "];
            //myPosition.isCurrent = @"0";
            result = [self checkDateValidation_with:arrMonthStart[0] withStartYear:arrMonthStart[1] withEndMonth:arrMonthEnd[0] withEndYear:arrMonthEnd[1]];
        }
        
        if (result)
        {
            NSArray *arrMonthEnd = [[txtTo.text isNull] componentsSeparatedByString:@" "];

            myWork.StartMonth = [NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthStart[0]]];
            myWork.StartYear = arrMonthStart[1];
            if ([[txtTo.text isNull] isEqualToString:@"Present"])
            {
                //myWork.isCurrent = @"1";
                myWork.EndMonth = @"";
                myWork.EndYear = @"";
            }
            else
            {
                myWork.EndMonth = [NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthEnd[0]]];
                myWork.EndYear = arrMonthEnd[1];;
            }
            
            [_obj_ProfileUpdate.arr_WorkALL replaceObjectAtIndex:_selectedIndexToUpdate withObject:myWork];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [CommonMethods displayAlertwithTitle:@"Please be sure the start date is not after the end date." withMessage:nil withViewController:self];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}

#pragma mark - Save Education
-(void)saveEducationNOW
{
    @try
    {
        NSArray *arrMonthStart = [[txtFrom.text isNull] componentsSeparatedByString:@" "];
        
        C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];
        /*--- If user choose present no need to check validation otherwise check date Validation ---*/
        
        NSArray *arrMonthEnd = [[txtTo.text isNull] componentsSeparatedByString:@" "];
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id str, NSDictionary *unused) {
            return ![[str isNull] isEqualToString:@""];
        }];
        
        arrMonthEnd = [arrMonthEnd filteredArrayUsingPredicate:pred];
        BOOL result = YES;
        if (arrMonthEnd.count > 0)
        {
            result = [self checkDateValidation_with:arrMonthStart[0] withStartYear:arrMonthStart[1] withEndMonth:arrMonthEnd[0] withEndYear:arrMonthEnd[1]];
        }
        else
        {
            result = YES;
        }
        
        
        if (result)
        {
            myEducation.StartMonth = [NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthStart[0]]];
            myEducation.StartYear = arrMonthStart[1];
            if (arrMonthEnd.count > 0)
            {
                myEducation.EndMonth = [NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthEnd[0]]];
                myEducation.EndYear = arrMonthEnd[1];;
            }
            
            [_obj_ProfileUpdate.arr_EducationALL replaceObjectAtIndex:_selectedIndexToUpdate withObject:myEducation];

            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [CommonMethods displayAlertwithTitle:@"Please be sure the start date is not after the end date." withMessage:nil withViewController:self];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}
#pragma mark - Date Match
-(BOOL)checkDateValidation_with:(NSString *)strStartDateMonth withStartYear:(NSString *)strStartDateYear withEndMonth:(NSString *)strEndDateMonth withEndYear:(NSString *)strEndDateYear
{
    if ([strEndDateYear integerValue]<[strStartDateYear integerValue])
    {
        return NO;
    }
    else if([strStartDateYear isEqualToString:strEndDateYear])
    {
        /*--- Both Same Year ---*/
        NSInteger sM = [CommonMethods getMonthNumber:strStartDateMonth];
        NSInteger eM = [CommonMethods getMonthNumber:strEndDateMonth];
        if (sM<=eM)
            return YES;
        else
            return NO;
        
    }
    return YES;
}
#pragma mark - Get Data - Position
-(NSString *)getPosition_StartMonth
{
    C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
    return [CommonMethods getMonthName:myWork.StartMonth];
}
-(NSString *)getPosition_StartYear
{
    C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
    return myWork.StartYear;
}

-(NSString *)getPosition_EndMonth
{
    C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
    if ([myWork.EndMonth isEqualToString:@""])
    {
        return @"Present";
    }
    return [CommonMethods getMonthName:myWork.EndMonth];
}
-(NSString *)getPosition_EndYear
{
    C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];
    if ([myWork.EndYear isEqualToString:@""])
    {
        return @"";
    }
    return myWork.EndYear;
}
#pragma mark - Get Data - Educxation
-(NSString *)getEducation_StartMonth
{
    C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];
    return [CommonMethods getMonthName:myEducation.StartMonth];
}
-(NSString *)getEducation_StartYear
{
    C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];
    return myEducation.StartYear;
}

-(NSString *)getEducation_EndMonth
{
    C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];
    return [CommonMethods getMonthName:myEducation.EndMonth];
}
-(NSString *)getEducation_EndYear
{
    C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];
    return myEducation.EndYear;
}
#pragma mark - Picker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([strMonth isEqualToString:@"Present"])
        return 1;
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (component == 0)
    {
        if (isUpdateFrom)
        {
            return arrMonthFrom.count;
        }
        return arrMonthTo.count;
    }
    return arrYear.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        if (isUpdateFrom)
        {
            return  arrMonthFrom [row];
        }
        return arrMonthTo[row];
    }
    return arrYear[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        if (isUpdateFrom)
        {
            strMonth = arrMonthFrom [row];
        }
        else
        {
            strMonth = arrMonthTo[row];
        }
    }
    else
    {
        strYear = arrYear[row];
    }
    [self updateText];
}
-(void)updateText
{
    if (isUpdateFrom)
    {
        txtFrom.text = [NSString stringWithFormat:@"%@ %@",strMonth,strYear] ;
    }
    else
    {
        txtTo.text = [NSString stringWithFormat:@"%@ %@",strMonth,strYear] ;
        if ([strMonth isEqualToString:@"Present"])
        {
            txtTo.text = strMonth;
            [piker reloadAllComponents];
        }
        else
        {
            @try
            {
                [piker reloadAllComponents];
                NSInteger indexYear = [arrYear indexOfObject:strYear];
                [piker selectRow:indexYear inComponent:1 animated:NO];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            
        }
    }
    
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
