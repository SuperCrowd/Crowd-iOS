//
//  C_Work_TimePeriod.m
//  Crowd
//
//  Created by Mac009 on 3/10/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "C_Work_TimePeriod.h"
#import "UITextFieldExtended.h"
#import "AppConstant.h"
#import "C_Work_Location.h"
typedef NS_ENUM(NSInteger, btnTapped)
{
    btnFrom = 51,
    btnTo = 52,
    btnEditFrom = 61,
    btnEditTo = 62
};

@interface C_Work_TimePeriod ()
{
    
    __weak IBOutlet UITextFieldExtended *txtFrom;
    __weak IBOutlet UITextFieldExtended *txtTo;
    
    __weak IBOutlet UIPickerView *piker;
    
    NSString *strYear;
    NSString *strMonth;
    __weak IBOutlet UIBarButtonItem *btnToolbar;
    NSMutableArray *arrYear;
    NSArray *arrMonthTo;
    NSArray *arrMonthFrom;
    BOOL isUpdateFrom;
}
@end

@implementation C_Work_TimePeriod

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Time Period";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_Dismiss:self withSelector:@selector(back)];

    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Next" withSelector:@selector(btnDoneClicked:)];
     NSInteger currentYear;//
    currentYear = [[[NSDate date] convertDateinFormat:@"yyyy"] integerValue];
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
    
            strMonth = arrMonthFrom[0];
            strYear = arrYear[arrYear.count - 1];
        
        txtFrom.text = [NSString stringWithFormat:@"%@ %@",strMonth,strYear];
        
        
        NSString *strMonthEnd = @"";
        NSString *strEndY = @"";
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


-(IBAction)btnDoneClicked:(id)sender{

    NSString *startDate_month,*startDate_year,*endDate_month,*isCurrent,*endDate_year;
    @try
    {
        NSArray *arrMonthStart = [[txtFrom.text isNull] componentsSeparatedByString:@" "];
        
        
        startDate_month = [NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthStart[0]]];
        startDate_year = arrMonthStart[1];
        
        BOOL result = NO;
        /*--- If user choose present no need to check validation otherwise check date Validation ---*/
        if ([[txtTo.text isNull] isEqualToString:@"Present"])
        {
            isCurrent = @"1";
            endDate_month = @"";
            endDate_year = @"";
            result = YES;
        }
        else
        {
            NSArray *arrMonthEnd = [[txtTo.text isNull] componentsSeparatedByString:@" "];
            isCurrent = @"0";
            endDate_month = [NSString stringWithFormat:@"%ld",(long)[CommonMethods getMonthNumber:arrMonthEnd[0]]];
            endDate_year = arrMonthEnd[1];;
            
            result = [self checkDateValidation_with:arrMonthStart[0] withStartYear:arrMonthStart[1] withEndMonth:arrMonthEnd[0] withEndYear:arrMonthEnd[1]];
        }
        
        if (result)
        {
            [self.view endEditing:YES];
                    
            [dictAddWorkExperience setValue:startDate_month forKey:@"startDate_month"];
            [dictAddWorkExperience setValue:startDate_year forKey:@"startDate_year"];
            [dictAddWorkExperience setValue:endDate_month forKey:@"endDate_month"];
            [dictAddWorkExperience setValue:endDate_year forKey:@"endDate_year"];
            [dictAddWorkExperience setValue:isCurrent forKey:@"isCurrent"];
            
            C_Work_Location *locVc  = [[C_Work_Location alloc]initWithNibName:@"C_Work_Location" bundle:nil];
            locVc.obj_ProfileUpdate = _obj_ProfileUpdate;
            [self.navigationController pushViewController:locVc animated:YES];
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
