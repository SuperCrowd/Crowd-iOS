//
//  C_Education_Degree.m
//  Crowd
//
//  Created by MAC107 on 16/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_Education_Degree.h"
#import "AppConstant.h"
#import "C_Education_Time.h"
@interface C_Education_Degree ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UITextView *txtV;
}


@end

@implementation C_Education_Degree

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Education";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Next" withSelector:@selector(btnDoneClicked:)];
    txtV.delegate = self;
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
//    if ([strT isEqualToString:@""])
//    {
//        [CommonMethods displayAlertwithTitle:[NSString stringWithFormat:@"Please Enter your degree"] withMessage:nil withViewController:self];
//    }
//    else
//    {
        [self.view endEditing:YES];

        [dictAddNewEducation setValue:strT forKey:@"degree"];

        C_Education_Time *obj = [[C_Education_Time alloc]initWithNibName:@"C_Education_Time" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        [self.navigationController pushViewController:obj animated:YES];
//    }
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
