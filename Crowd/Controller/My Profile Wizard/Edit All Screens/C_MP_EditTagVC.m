//
//  C_MP_EditTagVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_EditTagVC.h"
#import "AppConstant.h"
#define ENTER_TEXT @"Enter skills here"

#define SKILLS @"Skills"
#define EDUCATION @"Education"
@interface C_MP_EditTagVC ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UITextView *txtV;
}

@end

@implementation C_MP_EditTagVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    
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
    [CommonMethods addBottomLine_to_Label:lblTitle];
    
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
-(void)back
{
    popView;
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
        if (arrTemp.count > 0)
        {
            NSMutableArray *trimmedStrings = [NSMutableArray array];
            
            for (NSString *string in arrTemp) {
                @try
                {
                    [trimmedStrings addObject:[string isNull]];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                }
                
            }
            arrTemp = trimmedStrings;
            
            
            
            if ([_strComingFrom isEqualToString:SKILLS])
            {
                if ([self.delegate respondsToSelector:@selector(updateTags:)])
                    [self.delegate updateTags:[arrTemp componentsJoinedByString:@","]];
            }
            else if([_strComingFrom isEqualToString:EDUCATION])
            {
                [self saveEducation:[arrTemp mutableCopy]];
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
-(void)saveEducation:(NSMutableArray *)arrC
{
    C_Model_Education *myEducation = _arrContent[_selectedIndexToUpdate];
    NSMutableArray *arrT = [NSMutableArray array];
    for (int i = 0; i<arrC.count; i++)
    {
        C_Model_Courses *myCourse = [[C_Model_Courses alloc]init];
        @try
        {
            myCourse.Course = [[NSString stringWithFormat:@"%@",arrC[i]]isNull];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        
        [arrT addObject:myCourse];
    }
    myEducation.arrCourses = arrT;
    
    [_obj_ProfileUpdate.arr_EducationALL replaceObjectAtIndex:_selectedIndexToUpdate withObject:myEducation];
    
    
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
