//
//  C_CallViewController.m
//  Crowd
//
//  Created by Bobby Gill on 11/1/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_CallViewController.h"
#import "C_TwilioClient.h"
#import "AppConstant.h"
@interface C_CallViewController ()

@end

@implementation C_CallViewController
@synthesize lblStatusText;
@synthesize btnHangUp;
@synthesize isCalling;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //subscribe to the Twilio notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionDidConnect:)
                                                 name:WTConnectionDidConnect
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionDidDisconnect:)
                                                 name:WTConnectionDidDisconnect
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionDidFailWithError:)
                                                 name:WTConnectionDidFailWithError
                                               object:nil];
    
   
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Call Notification handlers
- (void) connectionDidConnect:(NSNotification*)notification
{
    NSString* activityName = @"connectionDidConnect:";
    LOG_TWILIO(0,@"%@Call has connected",activityName);
    
    self.lblStatusText.text = @"Connected";
   
}

- (void) connectionDidDisconnect:(NSNotification*)notification
{
    NSString* activityName = @"connectionDidDisconnect:";
    LOG_TWILIO(0,@"%@Call has disconnected",activityName);
    self.lblStatusText.text = @"Call Ended";
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)connectionDidFailWithError:(NSNotification*)notification
{
    NSString* activityName = @"connectionDidFailWithError:";
  
    LOG_TWILIO(1,@"%@Call has failed",activityName);
    self.lblStatusText.text = @"Call Failed";
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onHangUpButtonPressed:(id)sender
{
    NSString* activityName = @"onHangUpButtonPressed:";
    
    LOG_TWILIO(0,@"%@User has pressed hang up button, ending call",activityName);
    C_TwilioClient* twilioClient = [C_TwilioClient sharedInstance];
    [twilioClient disconnect];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


+ (C_CallViewController*)createForDialing:(NSString*)user
{
    C_CallViewController* retVal = [[C_CallViewController alloc]initWithNibName:@"C_CallViewController" bundle:nil];
    retVal.lblStatusText.text = [NSString stringWithFormat:@"Calling %@",user];
    retVal.isCalling = YES;
    return retVal;
}

+ (C_CallViewController*)createForReceiving
{
    C_CallViewController* retVal = [[C_CallViewController alloc]initWithNibName:@"C_CallViewController" bundle:nil];
    retVal.lblStatusText.text = [NSString stringWithFormat:@"Incoming call..."];
    retVal.isCalling = NO;
    return retVal;
}
@end
