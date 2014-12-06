//
//  C_BaseTwilioViewController.m
//  Crowd
//
//  Created by Bobby Gill on 11/26/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_BaseTwilioViewController.h"
#import "C_CallViewController.h"
#import "C_TwilioClient.h"
#import "AppConstant.h"

@interface C_BaseTwilioViewController ()
{
    JSONParser *parserForCallAvailability;
}
@end

@implementation C_BaseTwilioViewController
@synthesize timerCallAvailability;
@synthesize secondsToWaitToCheckAvailability;
@synthesize isAvailableForCall;
@synthesize OtherUserID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateCallAvailabilityBasedOnCachedPresenceUpdates];
    


}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateCallAvailabilityBasedOnCachedPresenceUpdates];

    
    
    [self checkCallAvailability];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]removeObserver:self name:WTPresenceUpdateForClient object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPresenceUpdateForClientNotification:) name:WTPresenceUpdateForClient object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timerCallAvailability invalidate];
    self.timerCallAvailability = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:WTPresenceUpdateForClient object:nil];
}
#pragma mark - Call Availability Methods
- (void) updateCallAvailabilityBasedOnCachedPresenceUpdates
{
    NSString* activityName = @"updateCallAvailabilityBasedOnCachedPresenceUpdates:";
    C_TwilioClient* twilioClient = [C_TwilioClient sharedInstance];
    NSNumber* presenceObject = [twilioClient getPresenceForClient:self.OtherUserID];
    
    if (presenceObject == nil)
    {
        //no data in the presence cache
        LOG_TWILIO(0,@"%@No cached presence data available for client %@",activityName,self.OtherUserID);
    }
    else
    {
        //we do have data
        BOOL isAvailable = [presenceObject boolValue];
        
        if (isAvailable)
        {
            LOG_TWILIO(0,@"%@User %@ is available for calling based on cached twilio presence update",activityName, self.OtherUserID);
            self.isAvailableForCall = NO;
        }
        else
        {
            LOG_TWILIO(0,@"%@User %@ is NOT available for calling based on cached twilio presence update",activityName, self.OtherUserID);
            self.isAvailableForCall = NO;
            
        }
    }
}

- (void) onPresenceUpdateForClientNotification:(NSNotification*)notification
{
    NSString* activityName = @"OnPresenceUpdateForClientNotification:";
    NSDictionary* userInfo = notification.userInfo;
    
    NSString* clientName = [userInfo objectForKey:@"Name"];
    
    if ([clientName isEqualToString:self.OtherUserID])
    {
        NSNumber* availability = [userInfo objectForKey:@"Available"];
        LOG_TWILIO(0,@"%@Received Twilio presence update notification for client %@ who's presence is %@",activityName,clientName,availability);
        
        if ([availability boolValue] == YES)
        {
            //client is available

            self.isAvailableForCall = YES;
        }
        else
        {
            //client is not available
            self.isAvailableForCall = NO;
            
            
        }
        
        
    }
    
}


#pragma mark - Call Related Methods
- (void) checkCallAvailability
{
    NSString* activityName = @"checkCallAvailability:";
    LOG_TWILIO(0,@"%@Checking user %@  availibility for a call",activityName,self.OtherUserID);
    
    NSDictionary *dictParam = @{@"UserID":self.OtherUserID};
    [self.timerCallAvailability invalidate];
    self.timerCallAvailability = nil;
    
    parserForCallAvailability = [[JSONParser alloc]initWith_withURL:Web_GET_CALLAVAILABILITY withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(onCheckCallAvailabilitySuccessful:) withObject:self];
    
}

- (void) onCheckCallAvailabilitySuccessful:(id)objResponse
{
    NSString* activityName = @"onCheckCallAvailabilitySuccessful:";
    LOG_TWILIO(0,@"%@Successfully received GetCallAvailability result %@",activityName,objResponse);
    
    NSDictionary* responseDictionary = (NSDictionary*)objResponse;
    
    if (responseDictionary != nil)
    {
        NSDictionary* setAvailableForCallResult = [responseDictionary objectForKey:@"GetCallAvailabilityResult"];
        
        NSNumber* isAvailableForCallObj = [setAvailableForCallResult objectForKey:@"IsAvailableForCall"];
        self.isAvailableForCall = [isAvailableForCallObj boolValue];
        
        if (isAvailableForCall)
        {
            LOG_TWILIO(0,@"%@ User %@ is available for a call at this time",activityName, self.OtherUserID);
            //self.callBarButtonItem.enabled = YES;
            
            
        }
        else
        {
            LOG_TWILIO(0,@"%@ User %@ is unavailable for a call at this time",activityName, self.OtherUserID);
           // self.callBarButtonItem.enabled = NO;
            
            //we also inform the TwilioClient to mark the user as unavailable for call
            [[C_TwilioClient sharedInstance]setCallAvailbilityForClient:self.OtherUserID isAvailable:NO];
        }
        self.secondsToWaitToCheckAvailability =[NSNumber numberWithInt: CALL_AVAILABILITY_HEARTBEAT_INTERVAL];
        
        
        //now we schedule the timer to renew in the specified number of seconds
        self.timerCallAvailability = [NSTimer scheduledTimerWithTimeInterval:[self.secondsToWaitToCheckAvailability doubleValue] target:self selector:@selector(checkCallAvailability) userInfo:nil repeats:NO];
        
        LOG_TWILIO(0,@"%@Successfully scheduled re-check of call availability to happen in %@ seconds",activityName,self.secondsToWaitToCheckAvailability);
    }
    else
    {
        LOG_TWILIO(1,@"%@Received null response from availibility method, unable to update user's call availability",activityName);
    }
}


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
