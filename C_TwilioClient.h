//
//  C_TwilioClient.h
//  Crowd
//
//  Created by Bobby Gill on 11/1/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCConnection.h"
#import "TCDevice.h"
#import "AFNetworkReachabilityManager.h"
@interface C_TwilioClient : NSObject<TCDeviceDelegate, TCConnectionDelegate>

@property (nonatomic,strong)    TCDevice* device;
@property (nonatomic,strong)	TCConnection* connection;
@property (nonatomic,strong)	TCConnection* pendingIncomingConnection;
@property (assign) UIBackgroundTaskIdentifier backgroundTaskAgent;
//@property (nonatomic,strong)    WalkieTalkieReachability* internetReachability;
@property (nonatomic,strong) AFNetworkReachabilityManager* reachabilityManager;

@property BOOL loggedIn;
@property BOOL backgroundSupported;

-(void)connect:(NSString*)clientName;
-(void)disconnect;
-(void)acceptIncomingConnection;
-(void)ignoreIncomingConnection;
-(void)login;
-(void)loginHelper;
+ (C_TwilioClient *)sharedInstance;
@end
