//
//  C_Work_Roles.m
//  Crowd
//
//  Created by Mac009 on 3/10/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "C_Work_Roles.h"
#import "AppConstant.h"
#import "C_UserModel.h"
@interface C_Work_Roles ()<UITextViewDelegate>
{
    __weak IBOutlet UITextView *txtV;
}


@end

@implementation C_Work_Roles

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Roles and Responsibilities";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    
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
        if (_obj_ProfileUpdate) {
            [self addNewPosition_LoggedInUser:@""];
        }
        else
        {
            [self addNewPosition:@""];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSString *strFinal = [txtV.text isNull];
        
        if (strFinal.length > 0)
        {
            
            [self.view endEditing:YES];
            
            if (_obj_ProfileUpdate) {
                
                [self addNewPosition_LoggedInUser:strFinal];
            }
            else
            {
                [self addNewPosition:strFinal];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            txtV.text = @"";
            [CommonMethods displayAlertwithTitle:@"Please Enter proper roles and responsibilities" withMessage:nil withViewController:self];
        }
        
    }
}
-(void)addNewPosition:(NSString *)strRoles
{
    
    Positions *myposition = [[Positions alloc]init];
    
    myposition.title = dictAddWorkExperience[@"title"];
    myposition.company_name = dictAddWorkExperience[@"company_name"];

    myposition.startDate_month = dictAddWorkExperience[@"startDate_month"];
    myposition.endDate_month = dictAddWorkExperience[@"endDate_month"];
    
    myposition.startDate_year = dictAddWorkExperience[@"startDate_year"];
    myposition.endDate_year = dictAddWorkExperience[@"endDate_year"];
    
    myposition.location_city = dictAddWorkExperience[@"location_city"];
        myposition.location_state = dictAddWorkExperience[@"location_state"];
        myposition.location_country = dictAddWorkExperience[@"location_country"];
    
     myposition.isCurrent = dictAddWorkExperience[@"isCurrent"];
    
    
    myposition.summary = strRoles;
    
    [myUserModel.arrPositionUser addObject:myposition ];
    
    [CommonMethods saveMyUser:myUserModel];
    myUserModel = [CommonMethods getMyUser];
}
-(void)addNewPosition_LoggedInUser:(NSString *)strRoles
{
    
    C_Model_Work *myposition = [[C_Model_Work alloc]init];
    
    myposition.Title = dictAddWorkExperience[@"title"];
    myposition.EmployerName = dictAddWorkExperience[@"company_name"];
    
    myposition.StartYear = dictAddWorkExperience[@"startDate_year"];
    myposition.EndYear = dictAddWorkExperience[@"endDate_year"];
    
    myposition.StartMonth = dictAddWorkExperience[@"startDate_month"];
    myposition.EndMonth = dictAddWorkExperience[@"endDate_month"];
    
    myposition.LocationCity = dictAddWorkExperience[@"location_city"];
    myposition.LocationState = dictAddWorkExperience[@"location_state"];
    myposition.LocationCountry = dictAddWorkExperience[@"location_country"];

    myposition.isCurrent =  [dictAddWorkExperience[@"isCurrent"]boolValue];
    myposition.summary = strRoles;
    
    [_obj_ProfileUpdate.arr_WorkALL addObject:myposition];
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
