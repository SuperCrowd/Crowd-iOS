//
//  C_PostJob_PositionVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_PositionVC.h"
#import "AppConstant.h"
#import "C_ViewEditableTextField.h"
#import "C_PostJob_LocationVC.h"
@interface C_PostJob_PositionVC ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextFieldExtended *txtPosition;
}
@end

@implementation C_PostJob_PositionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];    
}

-(void)back
{
    popView;
}
-(void)btnCancelClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(IBAction)btnEditClicked:(UIButton *)btnEdit
{
    [txtPosition becomeFirstResponder];
}
-(BOOL)checkValidation
{
    NSString *strT = [[NSString stringWithFormat:@"%@",txtPosition.text]isNull];
    if ([strT isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please enter your position" withMessage:nil withViewController:self];
        return NO;
    }
    
    else
    {
        return YES;
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    if ([self checkValidation])
    {
        @try
        {
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",txtPosition.text]isNull] forKey:@"position"];
            C_PostJob_LocationVC *objC = [[C_PostJob_LocationVC alloc]initWithNibName:@"C_PostJob_LocationVC" bundle:nil];
            [self.navigationController pushViewController:objC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }

        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtPosition resignFirstResponder];
    return YES;
}
#pragma mark - Extra

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
