//
//  C_EditTextVC.m
//  Crowd
//
//  Created by MAC107 on 11/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_EditTextVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"

#define POSITION @"Position"
#define EDUCATION @"Education"
#define ROLES @"Roles and Responsibilities"

//for position
#define JOB_TITLE @"Job Title"
#define EMPLOYER @"Employer"
#define SUMMARYVC @"SummaryVC"
#define RECOMMENDATION @"Recommendations"



//for education

#define SCHOOL @"School"
#define DEGREE @"Degree"

@interface C_EditTextVC ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UITextView *txtV;
    
    __weak IBOutlet NSLayoutConstraint *constraint_lblHeight;
}
@end

@implementation C_EditTextVC
//@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _strTitle;
    lblTitle.text = [NSString stringWithFormat:@"    %@",_strTitle];
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    
    
    NSString *strText;
    constraint_lblHeight.constant = 30.0;
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
        strText = [myUserModel.summary isNull];
        constraint_lblHeight.constant = 0.0;
    }
    //@[@"Job Title",@"Employer",@"Time Period",@"Location",@"Summary",@"Recommendations"]
    txtV.text = strText;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [txtV becomeFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ios8)
        {
            txtV.selectedRange = NSMakeRange([txtV.text length], 0);
        }
        else
        {
            [CommonMethods scrollToCaretInTextView:txtV animated:YES];
        }
    });
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
            [_strTitle isEqualToString:ROLES])
        {
            Positions *myPosition = _arrContent[_selectedIndexToUpdate];//
            if ([_strTitle isEqualToString:JOB_TITLE])
            {
                myPosition.title = txtV.text;
            }
            else if ([_strTitle isEqualToString:EMPLOYER])
            {
                myPosition.company_name = txtV.text;
            }
            else
            {
                myPosition.summary = txtV.text;
            }
            
            /*--- Replace object which was saved before ---*/
            [_arrContent replaceObjectAtIndex:_selectedIndexToUpdate withObject:myPosition];
            
            myUserModel.arrPositionUser = _arrContent;
        }
        else
        {
            Recommendations *myRecomment =_arrContent[_selectedIndexToUpdate];//
            myRecomment.recommendationText = txtV.text;
            
            /*--- Replace object which was saved before ---*/
            [_arrContent replaceObjectAtIndex:_selectedIndexToUpdate withObject:myRecomment];
            
            myUserModel.arrRecommendationsUser = _arrContent;
        }
        /*--- Save global object ---*/
        [CommonMethods saveMyUser:myUserModel];
        myUserModel = [CommonMethods getMyUser];
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
        Education *myEducation = _arrContent[_selectedIndexToUpdate];//
        if ([_strTitle isEqualToString:SCHOOL])
        {
            myEducation.schoolName = txtV.text;;
        }
        else
        {
            myEducation.degree = txtV.text;;
        }
        
        /*--- Replace object which was saved before ---*/
        [_arrContent replaceObjectAtIndex:_selectedIndexToUpdate withObject:myEducation];
        myUserModel.arrEducationUser = _arrContent;
        /*--- Save global object ---*/
        [CommonMethods saveMyUser:myUserModel];
        myUserModel = [CommonMethods getMyUser];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}
-(void)saveSummary
{
    myUserModel.summary = txtV.text;;
    [CommonMethods saveMyUser:myUserModel];
    myUserModel = [CommonMethods getMyUser];
}
#pragma mark - Get Data
-(NSString *)getPosition
{
    NSString *strText;

    @try
    {
        if ([_strTitle isEqualToString:JOB_TITLE] ||
            [_strTitle isEqualToString:EMPLOYER] ||
            [_strTitle isEqualToString:ROLES])
        {
            Positions *myPosition = _arrContent[_selectedIndexToUpdate];//
            if ([_strTitle isEqualToString:JOB_TITLE])
            {
                strText = myPosition.title;
            }
            else if ([_strTitle isEqualToString:EMPLOYER])
            {
                strText = myPosition.company_name;
            }
            else
            {
                strText = myPosition.summary;
            }
        }
        else
        {
            Recommendations *myRecomment = _arrContent[_selectedIndexToUpdate];//
            strText = myRecomment.recommendationText;
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
        Education *myEducation = _arrContent[_selectedIndexToUpdate];//
        if ([_strTitle isEqualToString:SCHOOL])
        {
            strText = myEducation.schoolName;
        }
        else
        {
            strText = myEducation.degree;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
