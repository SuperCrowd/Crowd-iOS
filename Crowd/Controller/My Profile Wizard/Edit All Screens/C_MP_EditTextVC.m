//
//  C_MP_EditTextVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_EditTextVC.h"
#import "AppConstant.h"

#define POSITION @"Position"
#define EDUCATION @"Education"
#define SUMMARY @"Summary"

//for position
#define JOB_TITLE @"Job Title"
#define EMPLOYER @"Employer"
#define SUMMARYVC @"SummaryVC"
#define RECOMMENDATION @"Recommendations"



//for education
#define SCHOOL @"School"
#define DEGREE @"Degree"
@interface C_MP_EditTextVC ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UITextView *txtV;
}

@end

@implementation C_MP_EditTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = lblTitle.text = _strTitle;
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    
    NSString *strText;
    if ([_strComingFrom isEqualToString:POSITION])
    {
        strText = [[self getPosition] isNull];
    }
    else if ([_strComingFrom isEqualToString:EDUCATION])
    {
        strText = [[self getEducation] isNull];
    }
    else if ([_strComingFrom isEqualToString:SUMMARYVC])
    {
        strText = [_obj_ProfileUpdate.Summary isNull];
    }
    //@[@"Job Title",@"Employer",@"Time Period",@"Location",@"Summary",@"Recommendations"]
    txtV.text = strText;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [txtV becomeFirstResponder];
}
-(void)back
{
    popView;
}
-(IBAction)btnDoneClicked:(id)sender
{
    NSString *strT = [txtV.text isNull];
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:[NSString stringWithFormat:@"Please Enter your %@",_strTitle] withMessage:nil withViewController:self];
    }
    else
    {
        if ([_strComingFrom isEqualToString:POSITION])
        {
            [self savePosition];
        }
        else if ([_strComingFrom isEqualToString:EDUCATION])
        {
            [self saveEducation];
        }
        else if ([_strComingFrom isEqualToString:SUMMARYVC])
        {
            [self saveSummary];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)savePosition
{
    @try
    {
        if ([_strTitle isEqualToString:JOB_TITLE] ||
            [_strTitle isEqualToString:EMPLOYER] ||
            [_strTitle isEqualToString:SUMMARY])
        {
            C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];//
            if ([_strTitle isEqualToString:JOB_TITLE])
            {
                myWork.Title = txtV.text;
            }
            else if ([_strTitle isEqualToString:EMPLOYER])
            {
                myWork.EmployerName = txtV.text;
            }
            else
            {
                myWork.Summary = txtV.text;
            }
            
            /*--- Replace object which was saved before ---*/
            [_obj_ProfileUpdate.arr_WorkALL replaceObjectAtIndex:_selectedIndexToUpdate withObject:myWork];
            
        }
        else
        {
            C_Model_Recommendation *myRecomment =_arrContent[_selectedIndexToUpdate];//
            myRecomment.Recommendation = txtV.text;
            
            /*--- Replace object which was saved before ---*/
            [_obj_ProfileUpdate.arr_RecommendationALL replaceObjectAtIndex:_selectedIndexToUpdate withObject:myRecomment];
            
        }
        /*--- Save global object ---*/
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}



-(void)saveEducation
{
    @try
    {
        C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];//
        if ([_strTitle isEqualToString:SCHOOL])
        {
            myEducation.Name = txtV.text;;
        }
        else
        {
            myEducation.Degree = txtV.text;;
        }
        
        /*--- Replace object which was saved before ---*/
        [_obj_ProfileUpdate.arr_EducationALL replaceObjectAtIndex:_selectedIndexToUpdate withObject:myEducation];

    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}
-(void)saveSummary
{
    _obj_ProfileUpdate.Summary = txtV.text;;
}
#pragma mark - Get Data
-(NSString *)getPosition
{
    NSString *strText;
    
    @try
    {
        if ([_strTitle isEqualToString:JOB_TITLE] ||
            [_strTitle isEqualToString:EMPLOYER] ||
            [_strTitle isEqualToString:SUMMARY])
        {
            C_Model_Work *myWork = _arrContent[_selectedIndexToUpdate];//
            if ([_strTitle isEqualToString:JOB_TITLE])
            {
                strText = myWork.Title;
            }
            else if ([_strTitle isEqualToString:EMPLOYER])
            {
                strText = myWork.EmployerName;
            }
            else
            {
                strText = myWork.Summary;
            }
        }
        else
        {
            C_Model_Recommendation *myRecomment =_arrContent[_selectedIndexToUpdate];//
            strText = myRecomment.Recommendation;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return strText;
}
-(NSString *)getEducation
{
    NSString *strText;
    
    @try
    {
        C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];//
        if ([_strTitle isEqualToString:SCHOOL])
        {
            strText = myEducation.Name;
        }
        else
        {
            strText = myEducation.Degree;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return strText;
}
#pragma mark - Text View Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}
#pragma mark - Extra

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end