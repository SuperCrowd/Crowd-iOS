//
//  C_PostJob_LinkVC.m
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_LinkVC.h"
#import "AppConstant.h"
#import "UITextFieldExtended.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"
@interface C_PostJob_LinkVC ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextFieldExtended *txtLink;
}
@end

@implementation C_PostJob_LinkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"] ||
       [is_PostJob_Edit_update isEqualToString:@"update"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
        txtLink.text = ([is_PostJob_Edit_update isEqualToString:@"update"])?postJob_ModelClass.URL:dictPostNewJob[@"JobURL"];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
}
-(void)done
{
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        postJob_ModelClass.URL = [[NSString stringWithFormat:@"%@",txtLink.text]isNull];
    }
    else
    {
        [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",txtLink.text]isNull] forKey:@"JobURL"];
    }
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
    [txtLink becomeFirstResponder];
}

-(IBAction)btnNextClicked:(id)sender
{
    @try
    {
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
        {
            postJob_ModelClass.URL = [[NSString stringWithFormat:@"%@",txtLink.text]isNull];
            for (UIViewController *vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[C_PostJob_UpdateVC class]])
                {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        }
        else
        {
            [dictPostNewJob setValue:[[NSString stringWithFormat:@"%@",txtLink.text]isNull] forKey:@"JobURL"];
            C_PostJob_PreviewVC *obj = [[C_PostJob_PreviewVC alloc]initWithNibName:@"C_PostJob_PreviewVC" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtLink resignFirstResponder];
    return YES;
}
#pragma mark - Extra

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//{
//    "UserID":"3",
//    "UserToken":"Dbr/k5trWmO3XRTk3AWfX90E9jwpoh59w/EaiU9df/OkFa6bxluaKsQmBtKDNDHbBpplmFe2Zo06m6TOpxxDc0mhb1DzDq0EzXjBFsfQRVTewDXwdZZ5mxNdEp4HEdrIlx43DPPRh+5uQzOzP8bob7ckkNvE7yB9HbeZVS5I1BhjHA3/8Ac2Qf0+sjkHb8mKk/bSO1NammUBSEHHCQ0u3MNYOiR1PU+Uc1gRIkGm4CmEcYZVEdD1D1i9i26QwQSqMSs/hBy6V9wgcbrApOiKrRXOcQDv7r93",
//    "JobID": "9",
//    "Company": "Sparsh",
//    "Industry": "It",
//    "Industry2": "IT",
//    "Title": "Tatvasoft",
//    "LocationCity": "Ahmedabad",
//    "LocationState": "Gujarat",
//    "LocationCountry": "India",
//    "ExperienceLevel": "",
//    "Responsibilities": "r1",
//    "Qualifications": "",
//    "EmployerIntroduction ": "",
//    "JobURL": "testURL",
//    "Skills": [
//                   {
//                         "Skill": ".NET"
//                       },
//                   {
//                         "Skill": "SQL"
//                       }    
//                 ]
//}
//}
@end
