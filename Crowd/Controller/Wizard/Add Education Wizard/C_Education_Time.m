//
//  C_Education_Time.m
//  Crowd
//
//  Created by MAC107 on 16/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_Education_Time.h"
#import "AppConstant.h"
#import "UITextFieldExtended.h"
#import "C_Education_Courses.h"

typedef NS_ENUM(NSInteger, btnTapped)
{
    btnFrom = 51,
    btnTo = 52,
    btnEditFrom = 51,
    btnEditTo = 52
};
@interface C_Education_Time ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    
    __weak IBOutlet UITextFieldExtended *txtFrom;
    __weak IBOutlet UITextFieldExtended *txtTo;
    
    __weak IBOutlet UIPickerView *piker;
    
    NSString *strYear;
    NSString *strMonth;
    
    NSMutableArray *arrYear;
    NSArray *arrMonth;
    
    __weak IBOutlet UIBarButtonItem *btnToolbar;
    BOOL isUpdateFrom;
}
@end

@implementation C_Education_Time

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Education";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Next" withSelector:@selector(btnDoneClicked:)];
    
    
    
    
    /*--- 10 years more for study only ---*/
    NSInteger currentYear = [[[[NSDate date] addYear:10] convertDateinFormat:@"yyyy"] integerValue];//[[[NSDate date] convertDateinFormat:@"yyyy"] integerValue];
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
    
    arrMonth = @[@"January",
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
    strMonth = @"January";
    strYear = [NSString stringWithFormat:@"%ld",currentYear-10];
    txtFrom.text = [[NSString stringWithFormat:@"%@ %@",strMonth,strYear] isNull];
    
    NSString *strEndM = @"January";
    NSString *strEndY = [NSString stringWithFormat:@"%ld",currentYear-10];

    txtTo.text = [NSString stringWithFormat:@"%@ %@",strEndM,strEndY];
    [piker reloadAllComponents];
    
    
    /*--- Search index using message id to remove from both array while searching ---*/
    btnToolbar.title = @"From";
    isUpdateFrom = YES;
    [self updatePiker];
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)updatePiker
{
    [piker reloadAllComponents];
    
    @try
    {
        NSInteger indexMonth  = [arrMonth indexOfObject:strMonth];
        [piker selectRow:indexMonth inComponent:0 animated:NO];
 
        NSInteger indexYear = [arrYear indexOfObject:strYear];
        [piker selectRow:indexYear inComponent:1 animated:NO];
        
        
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
            strYear = [[[txtTo.text isNull] componentsSeparatedByString:@" "] objectAtIndex:1];
            [self updatePiker];
            
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
    @try
    {
        NSArray *arrMonthStart = [[txtFrom.text isNull] componentsSeparatedByString:@" "];
        /*--- If user choose present no need to check validation otherwise check date Validation ---*/
        
        NSArray *arrMonthEnd = [[txtTo.text isNull] componentsSeparatedByString:@" "];
        
        BOOL result = [self checkDateValidation_with:arrMonthStart[0] withStartYear:arrMonthStart[1] withEndMonth:arrMonthEnd[0] withEndYear:arrMonthEnd[1]];
        
        if (result)
        {
            //save here
            @try
            {
                // month is in number format

                [dictAddNewEducation setValue:[NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthStart[0]]] forKey:@"startDate_month"];
                [dictAddNewEducation setValue:arrMonthStart[1] forKey:@"startDate_year"];
                [dictAddNewEducation setValue:[NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthEnd[0]]] forKey:@"endDate_month"];
                [dictAddNewEducation setValue:arrMonthEnd[1] forKey:@"endDate_year"];
                
                C_Education_Courses *obj = [[C_Education_Courses alloc]initWithNibName:@"C_Education_Courses" bundle:nil];
                [self.navigationController pushViewController:obj animated:YES];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            
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
        return arrMonth.count;
    }
    return arrYear.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return  arrMonth [row];
    }
    return arrYear[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        strMonth = arrMonth[row];
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
#pragma mark - Extra

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
