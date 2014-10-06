//
//  C_PostJob_SkillsVC.m
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_SkillsVC.h"
#import "AppConstant.h"
#import "C_PostJob_LinkVC.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"
@interface C_PostJob_SkillsVC ()<UITextViewDelegate>
{
    __weak IBOutlet UITextView *txtV;
    __weak IBOutlet UILabel *lblSubTitle;

}


@end

@implementation C_PostJob_SkillsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"] ||
       [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
        NSMutableArray *arrS = [NSMutableArray array];
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
        {
            for (NSDictionary *dictS in postJob_ModelClass.arrSkills)
            {
                [arrS addObject:dictS[@"Skill"]];
            }
        }
        else
        {
            for (NSDictionary *dictS in dictPostNewJob[@"Skills"])
            {
                [arrS addObject:dictS[@"Skill"]];
            }
        }
        
        txtV.text = [arrS componentsJoinedByString:@","];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
    [CommonMethods addBottomLine_to_Label:lblSubTitle];

}
-(void)done
{
    if ([self saveSkills])
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        txtV.selectedRange = NSMakeRange([txtV.text length], 0);
    });
}
-(BOOL)saveSkills
{
    NSString *strT = [[NSString stringWithFormat:@"%@",txtV.text] isNull];
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter your skills" withMessage:nil withViewController:self];
        return NO;
    }
    else
    {
        NSArray *arrTemp = [CommonMethods getTagArray:strT];
        if (arrTemp.count > 0)
        {
            NSMutableArray *trimmedStrings = [NSMutableArray array];
            for (NSString *string in arrTemp) {
                [trimmedStrings addObject:[string isNull]];
            }
            
            
            NSMutableArray *arrSkillsF = [NSMutableArray array];
            for (NSString *str in trimmedStrings)
            {
                [arrSkillsF addObject:@{@"Skill":str}];
            }
            
            if ([is_PostJob_Edit_update isEqualToString:@"update"])
                postJob_ModelClass.arrSkills = arrSkillsF;
            else
                [dictPostNewJob setObject:arrSkillsF forKey:@"Skills"];
            
            return YES;
        }
        else
        {
            txtV.text = @"";
            [CommonMethods displayAlertwithTitle:@"Please Enter proper skills" withMessage:nil withViewController:self];
            return NO;
        }
        
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self saveSkills])
    {
        C_PostJob_LinkVC *obj = [[C_PostJob_LinkVC alloc]initWithNibName:@"C_PostJob_LinkVC" bundle:nil];
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

@end
