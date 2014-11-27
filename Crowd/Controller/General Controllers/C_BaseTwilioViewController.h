//
//  C_BaseTwilioViewController.h
//  Crowd
//
//  Created by Bobby Gill on 11/26/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_BaseTwilioViewController : UIViewController
- (void) onPresenceUpdateForClientNotification:(NSNotification*)notification;
- (void) onCheckCallAvailabilitySuccessful:(id)objResponse;
@property(nonatomic, strong)NSTimer* timerCallAvailability;
@property(nonatomic, strong)NSNumber* secondsToWaitToCheckAvailability;
@property(nonatomic, strong)NSString* OtherUserID;
@property BOOL isAvailableForCall;


@end
