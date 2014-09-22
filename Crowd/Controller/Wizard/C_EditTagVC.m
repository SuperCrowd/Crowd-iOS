//
//  C_SkillsEditVC.m
//  Crowd
//
//  Created by MAC107 on 09/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_EditTagVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#define ENTER_TEXT @"Enter skills here"

#define SKILLS @"Skills"
#define EDUCATION @"Education"

@interface C_EditTagVC ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UITextView *txtV;
}
@end


@implementation C_EditTagVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_strComingFrom isEqualToString:SKILLS])
    {
        self.title = SKILLS;
        lblTitle.text = @"Separate skills with comma";
    }
    else if([_strComingFrom isEqualToString:EDUCATION])
    {
        self.title = @"Courses";
        lblTitle.text = @"Separate courses with comma";
    }
    
    lblTitle.font = kFONT_LIGHT(15.0);
    
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];

    //Tap to add skills.  Separate skills with a comma.
    if (_strTags.length > 0)
    {
        txtV.text = _strTags;
    }
    else
    {
        txtV.text = @"";
    }
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
        NSString *strTitle;
        if ([_strComingFrom isEqualToString:SKILLS]) {
            strTitle = @"Please Enter your skills";
        }
        else if([_strComingFrom isEqualToString:EDUCATION])
        {
            strTitle = @"Please Enter your Courses";
        }
        [CommonMethods displayAlertwithTitle:strTitle withMessage:nil withViewController:self];
    }
    else
    {
        NSString *strFinal = [txtV.text isNull];
        NSArray *arrTemp = [CommonMethods getTagArray:strFinal];
//        NSArray *arrTemp = [strFinal componentsSeparatedByString:@","];
//        /*--- Remove Blank String ---*/
//        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id str, NSDictionary *unused) {
//            return ![[str isNull] isEqualToString:@""];
//        }];
//        
//        arrTemp = [arrTemp filteredArrayUsingPredicate:pred];
        if (arrTemp.count > 0)
        {
            NSMutableArray *trimmedStrings = [NSMutableArray array];
            for (NSString *string in arrTemp) {
                [trimmedStrings addObject:[string isNull]];
            }
            arrTemp = trimmedStrings;
            
            
            
            if ([_strComingFrom isEqualToString:SKILLS])
            {
                if ([self.delegate respondsToSelector:@selector(updateTags:)])
                    [self.delegate updateTags:[arrTemp componentsJoinedByString:@","]];
            }
            else if([_strComingFrom isEqualToString:EDUCATION])
            {
                [self saveEducation:[arrTemp componentsJoinedByString:@","]];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            txtV.text = @"";
            [CommonMethods displayAlertwithTitle:@"Please Enter proper skills" withMessage:nil withViewController:self];
        }
        
    }
}
-(void)saveEducation:(NSString *)strText
{
    Education *myEducation = _arrContent[_selectedIndexToUpdate];
    myEducation.fieldOfStudy = strText;
    
    [_arrContent replaceObjectAtIndex:_selectedIndexToUpdate withObject:myEducation];
    [CommonMethods saveMyUser:myUserModel];
    myUserModel = [CommonMethods getMyUser];
//    if ([self.delegate respondsToSelector:@selector(reloadTable)])
//        [self.delegate reloadTable];
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
