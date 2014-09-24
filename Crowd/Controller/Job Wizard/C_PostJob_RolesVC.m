//
//  C_PostJob_RolesVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_RolesVC.h"
#import "AppConstant.h"
#import "C_PostJob_SkillsVC.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"
@interface C_PostJob_RolesVC ()<UITextViewDelegate>
{
    __weak IBOutlet UITextView *txtV;
}

@end

@implementation C_PostJob_RolesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"] ||
       [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
        txtV.text = ([is_PostJob_Edit_update isEqualToString:@"update"])?postJob_ModelClass.Responsibilities:dictPostNewJob[@"Responsibilities"];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
}
-(void)done
{
    if ([self saveRoles])
    {
        Class mtyC = nil;;
        if ([is_PostJob_Edit_update isEqualToString:@"edit"])
        {
            mtyC = [C_PostJob_PreviewVC class];
        }
        else
        {
            mtyC = [C_PostJob_UpdateVC class];
        }
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:mtyC])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    }
}
-(void)back
{
    popView;
}
-(void)btnCancelClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [txtV becomeFirstResponder];
}
-(BOOL)saveRoles
{
    NSString *strT = [[NSString stringWithFormat:@"%@",txtV.text] isNull];
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter your Roles and Responsibilities" withMessage:nil withViewController:self];
        return NO;
    }
    else
    {
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
            postJob_ModelClass.Responsibilities = strT;
        else
            [dictPostNewJob setValue:strT forKey:@"Responsibilities"];
        return YES;
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self saveRoles])
    {
        C_PostJob_SkillsVC *obj = [[C_PostJob_SkillsVC alloc]initWithNibName:@"C_PostJob_SkillsVC" bundle:nil];
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
