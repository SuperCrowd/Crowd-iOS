//
//  C_Education_Courses.m
//  Crowd
//
//  Created by MAC107 on 16/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_Education_Courses.h"
#import "AppConstant.h"
#import "C_UserModel.h"
@interface C_Education_Courses ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UITextView *txtV;
}

@end

@implementation C_Education_Courses

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Education";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Next" withSelector:@selector(btnDoneClicked:)];

    txtV.text = @"";
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [txtV becomeFirstResponder];
}
-(IBAction)btnDoneClicked:(id)sender
{
    NSString *strT = [txtV.text isNull];
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter your Courses" withMessage:nil withViewController:self];
    }
    else
    {
        NSString *strFinal = [txtV.text isNull];
        NSArray *arrTemp = [CommonMethods getTagArray:strFinal];

        if (arrTemp.count > 0)
        {
            NSMutableArray *trimmedStrings = [NSMutableArray array];
            for (NSString *string in arrTemp) {
                [trimmedStrings addObject:[string isNull]];
            }
            arrTemp = trimmedStrings;
        
            [self.view endEditing:YES];

            [self addNewEducationWithTags:[arrTemp componentsJoinedByString:@","]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            txtV.text = @"";
            [CommonMethods displayAlertwithTitle:@"Please Enter proper skills" withMessage:nil withViewController:self];
        }
        
    }
}
-(void)addNewEducationWithTags:(NSString *)strTags
{
    Education *myEducation = [[Education alloc]init];
    
    myEducation.degree = dictAddNewEducation[@"degree"];
    myEducation.schoolName = dictAddNewEducation[@"schoolName"];
    myEducation.fieldOfStudy = strTags;
    myEducation.startDate_year = dictAddNewEducation[@"startDate_year"];
    myEducation.endDate_year = dictAddNewEducation[@"endDate_year"];
    
    myEducation.startDate_month = dictAddNewEducation[@"startDate_month"];
    myEducation.endDate_month = dictAddNewEducation[@"endDate_month"];
    
    
    [myUserModel.arrEducationUser addObject:myEducation];
    
    [CommonMethods saveMyUser:myUserModel];
    myUserModel = [CommonMethods getMyUser];
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
