//
//  C_Work_Employer.m
//  Crowd
//
//  Created by Mac009 on 3/10/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "C_Work_Employer.h"
#import "AppConstant.h"
#import "C_Work_TimePeriod.h"
@interface C_Work_Employer ()<UITextViewDelegate>
{
    __weak IBOutlet UITextView *txtV;
}


@end

@implementation C_Work_Employer

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Employer";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_Dismiss:self withSelector:@selector(back)];
    
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
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:[NSString stringWithFormat:@"Please Enter your employer"] withMessage:nil withViewController:self];
    }
    else
    {
        
        
        [self.view endEditing:YES];
        [dictAddWorkExperience setValue:strT forKey:@"company_name"];
        C_Work_TimePeriod *obj = [[C_Work_TimePeriod alloc]initWithNibName:@"C_Work_TimePeriod" bundle:nil];
        obj.obj_ProfileUpdate = _obj_ProfileUpdate;
        [self.navigationController pushViewController:obj animated:YES];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
