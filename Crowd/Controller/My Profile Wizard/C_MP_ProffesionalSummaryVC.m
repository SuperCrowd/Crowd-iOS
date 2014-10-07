//
//  C_MP_ProffesionalSummaryVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_ProffesionalSummaryVC.h"
#import "AppConstant.h"
#import "UpdateProfile.h"
#import "C_MyProfileVC.h"
#import "C_MP_EditTextVC.h"
@interface C_MP_ProffesionalSummaryVC ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblSummary;
    __weak IBOutlet UITextView *txtV;
}

@end

@implementation C_MP_ProffesionalSummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Professional Summary";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(doneClicked)];
}

-(void)back
{
    popView;
}
-(void)doneClicked
{
//    if ([_obj_ProfileUpdate.Summary isEqualToString:@""])
//    {
//        [CommonMethods displayAlertwithTitle:@"Please add summary" withMessage:nil withViewController:self];
//        return;
//    }
    UpdateProfile *profile = [[UpdateProfile alloc]init];
    [profile updateProfile_WithModel:_obj_ProfileUpdate withSuccessBlock:^{
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_MyProfileVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    } withFailBlock:^(NSString *strError) {
        [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_obj_ProfileUpdate.Summary isEqualToString:@""])
        lblSummary.alpha = 1.0;
    else
    {
        lblSummary.alpha = 0.0;
        txtV.text = _obj_ProfileUpdate.Summary;
        
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
}
#pragma mark - IBAction
-(IBAction)btnEditClicked:(id)sender
{
    C_MP_EditTextVC *obj = [[C_MP_EditTextVC alloc]initWithNibName:@"C_MP_EditTextVC" bundle:nil];
    obj.obj_ProfileUpdate = _obj_ProfileUpdate;
    obj.strComingFrom = @"SummaryVC";
    obj.strTitle = self.title;
    [self.navigationController pushViewController:obj animated:YES];
}
-(IBAction)btnNextClicked:(id)sender
{
    [self doneClicked];
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
