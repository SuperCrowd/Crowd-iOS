//
//  C_ProffessionalSummaryVC.m
//  Crowd
//
//  Created by MAC107 on 16/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_ProffessionalSummaryVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#import "C_EditTextVC.h"
#import "C_ProfilePreviewVC.h"
@interface C_ProffessionalSummaryVC ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblSummary;
    __weak IBOutlet UITextView *txtV;
}


@end

@implementation C_ProffessionalSummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Professional Summary";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    
    if ([[UserDefaults objectForKey:PROFILE_PREVIEW]isEqualToString:@"yes"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    }
}

-(void)btnDoneClicked:(id)sender
{
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[C_ProfilePreviewVC class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([myUserModel.summary isEqualToString:@""])
        lblSummary.alpha = 1.0;
    else
    {
        lblSummary.alpha = 0.0;
        txtV.text = myUserModel.summary;
    }
}
#pragma mark - IBAction
-(IBAction)btnEditClicked:(id)sender
{
    C_EditTextVC *obj = [[C_EditTextVC alloc]initWithNibName:@"C_EditTextVC" bundle:nil];
    obj.strComingFrom = @"SummaryVC";
    obj.strTitle = self.title;
    obj.arrContent = myUserModel.arrEducationUser;
    [self.navigationController pushViewController:obj animated:YES];
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([myUserModel.summary isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please add summary" withMessage:nil withViewController:self];
    }
    else
    {
        C_ProfilePreviewVC *obj = [[C_ProfilePreviewVC alloc]initWithNibName:@"C_ProfilePreviewVC" bundle:nil];
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

#pragma mark - Extra
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
