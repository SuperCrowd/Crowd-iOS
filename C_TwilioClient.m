//
//  C_TwilioClient.m
//  Crowd
//
//  Created by Bobby Gill on 11/1/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_TwilioClient.h"
#import "AppConstant.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TCPresenceEvent.h"

@implementation C_TwilioClient
@synthesize connection;
@synthesize pendingIncomingConnection;
@synthesize device;
@synthesize backgroundSupported;
@synthesize backgroundTaskAgent;
@synthesize loggedIn;
//@synthesize internetReachability;
@synthesize reachabilityManager;
@synthesize parser;
@synthesize heartbeatTimer;
@synthesize secondsAfterToRenewHeartbeat;
@synthesize clientPresenceInfo;

+ (C_TwilioClient *)sharedInstance {
    static C_TwilioClient *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


#pragma mark -
#pragma mark Initalization

-(void)beginBackgroundUpdateTask
{
    if (self.backgroundSupported && self.backgroundTaskAgent == UIBackgroundTaskInvalid)
    {
        self.backgroundTaskAgent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
            [self endBackgroundUpdateTask];
        }];
    }
}

-(void)endBackgroundUpdateTask
{
    if (self.backgroundSupported && self.backgroundTaskAgent != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskAgent];
        self.backgroundTaskAgent = UIBackgroundTaskInvalid;
    }
}

-(id)init
{
    if (self = [super init])
    {
//        self.internetReachability = [WalkieTalkieReachability reachabilityForInternetConnection] ;
//        [self.internetReachability stopNotifier];
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        self.loggedIn = NO;
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        if ([currentDevice respondsToSelector:@selector(isMultitaskingSupported)])
        {
            self.backgroundSupported = currentDevice.multitaskingSupported;
        }
        
        self.backgroundTaskAgent = UIBackgroundTaskInvalid;
        
        
        __weak C_TwilioClient* weakSelf;
        //lets set the reachability callback
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
         {
             LOG_TWILIO(0,@"Networking reachability status changed to %d",status);
             AFNetworkReachabilityStatus netStatus = [weakSelf.reachabilityManager networkReachabilityStatus];
             
             if(netStatus != AFNetworkReachabilityStatusNotReachable && !weakSelf.loggedIn)
             {
                 [weakSelf loginHelper];
             }

             
         }];
        
        AFNetworkReachabilityStatus netStatus = [self.reachabilityManager networkReachabilityStatus];
        if(netStatus != AFNetworkReachabilityStatusNotReachable && !self.loggedIn)
        {
            [self loginHelper];
        }
        
        self.clientPresenceInfo = [[NSMutableDictionary alloc]init];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(onUserLoggedOutNotification:)
//                                                     name:kNotification_UserLoggedOut
//                                                   object:nil];
    }
    
    return self;
}

//-(void)reachabilityChanged:(NSNotification *)note
//{
//    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
//    
//    if(netStatus != NotReachable && !self.loggedIn)
//    {
//        [self loginHelper];
//    }
//}

-(void)login
{
    [self beginBackgroundUpdateTask];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WTLoginDidStart object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(reachabilityChanged:)
//                                                 name:kReachabilityChangedNotification
//                                               object:nil];
    
    AFNetworkReachabilityStatus netStatus = [self.reachabilityManager networkReachabilityStatus];
    
    if(netStatus != AFNetworkReachabilityStatusNotReachable)
    {
        [self loginHelper];
    }
//    else
//    {
//        [self.internetReachability startNotifier];
//    }
}



- (void) logout
{
    NSString* activityName = @"onUserLoggedOutNotification:";
      LOG_TWILIO(0,@"%@Detected user has logged out, shutting down incoming connections and updating presence as offline on server",activityName);
    [self.device unlisten];
    
    self.loggedIn = NO;
}
- (void)renewCallAvailability
{
    [self setCallAvaibility:YES];
}

- (void) setCallAvaibility:(BOOL)isAvailableForCall
{
    NSString* activityName = @"setCallAvailibility:";
    @try
    {
  
        NSDictionary *dictParam = @{@"UserID":userInfoGlobal.UserId,
                                    @"UserToken":userInfoGlobal.Token};
        if (isAvailableForCall)
        {
            //renewing the availibility
            LOG_TWILIO(0,@"%@Attempting to renew avaibility on server",activityName);
            parser = [[JSONParser alloc]initWith_withURL:Web_SET_AVAILABLE_CALL withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(setAvailableForCallSuccessfull:) withObject:self];
        }
        else
        {
            //we clear the heartbeat timer so it doesnt run
            [self.heartbeatTimer invalidate];
            self.heartbeatTimer = nil;
            //expiring the availibility
            LOG_TWILIO(0,@"%@Attempting to clear avaibility on server",activityName);
            parser = [[JSONParser alloc]initWith_withURL:Web_SET_UNAVAILABLE_CALL withParam:dictParam withData:nil withType:kURLPost withSelector:@selector(setUnAvailableForCallSuccessfull:) withObject:self];
        }
        

    }
    @catch (NSException *exception) {
        LOG_TWILIO(1,@"%@%@",activityName,exception.description);
        
    }

    
}

- (void) setAvailableForCallSuccessfull:(id)objResponse
{
    NSString* activityName = @"setAvailableForCallSuccessfull:";
    LOG_TWILIO(0,@"%@Successfully renewed user call availablility with result %@",activityName,objResponse);
    
    NSDictionary* responseDictionary = (NSDictionary*)objResponse;
    
    if (responseDictionary != nil)
    {
      //  NSDictionary* setAvailableForCallResult = [responseDictionary objectForKey:@"SetAvailableForCallResult"];
        self.secondsAfterToRenewHeartbeat = [NSNumber numberWithInt: CALL_AVAILABILITY_HEARTBEAT_INTERVAL];
                                         
    
        //now we schedule the timer to renew in the specified number of seconds
        self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:[self.secondsAfterToRenewHeartbeat doubleValue] target:self selector:@selector(renewCallAvailability) userInfo:nil repeats:NO];
       
        LOG_TWILIO(0,@"%@Successfully scheduled renewal of twilio heartbeat to happen in %@ seconds",activityName,self.secondsAfterToRenewHeartbeat);
    }
    else
    {
        LOG_TWILIO(1,@"%@Received null response from availibility method, unable to create heartbeat refresh timer",activityName);
    }
    
    
}

- (void) setUnAvailableForCallSuccessfull:(id)objResponse
{
    NSString* activityName = @"setUnAvailableForCallSuccessfull:";
    LOG_TWILIO(0,@"%@Successfully cleared user call availablility with result %@",activityName,objResponse);
}

-(void)loginHelper
{
    NSString* activityName = @"loginHelper:";
    NSError* loginError = nil;
    NSString* capabilityToken = [self getCapabilityToken:&loginError];
    
//    NSLog(@"Got capabilility token, in loginHelper");
    LOG_TWILIO(0,@"%@Capability token %@",activityName,capabilityToken);
    if ( !loginError && capabilityToken )
    {
        if ( !self.device )
        {
            // initialize a new device
            self.device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken delegate:self];
        }
        else
        {
            // update its capabilities
            [self.device updateCapabilityToken:capabilityToken];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WTLoginDidFinish object:nil];
        self.loggedIn = YES;
        
        // Check the capabilities and warn if features aren't available.
        // You might handle this in other ways such as disabling buttons, or having
        // LED-style images in a red or green state.
        NSNumber* hasOutgoing = [self.device.capabilities objectForKey:TCDeviceCapabilityOutgoingKey];
        NSNumber* hasIncoming = [self.device.capabilities objectForKey:TCDeviceCapabilityIncomingKey];
        
        if ( [hasOutgoing boolValue] == NO )
        {
            LOG_TWILIO(0,@"%@Unable to make outgoing calls with current capability token",activityName);
           
        }
        if ( [hasIncoming boolValue] == NO )
        {
            LOG_TWILIO(0,@"%@Unable to receive incoming calls with current capability token",activityName);
        }
    }
    else if ( loginError )
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:loginError forKey:@"error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:WTLoginDidFailWithError object:nil userInfo:userInfo];
    }
    
    [self endBackgroundUpdateTask];
}

#pragma mark -
#pragma mark TCDevice Capability Token

-(NSString*)getCapabilityToken:(NSError **)error
{
    NSString* activityName = @"getCapabilityToken:";
    //Creates a new capability token from the auth.php file on server
    
    NSString* capabilityToken = nil;
    //Make the URL Connection to your server
    
    //lets get the logged in user id
    NSString* loggedInUserID = userInfoGlobal.UserId;
    NSString* urlString = [NSString stringWithFormat:@"http://54.172.176.28/Twilio/WalkieTalkie/auth.php?ClientName=%@",loggedInUserID];
    
    LOG_TWILIO(0,@"%@Attempting to login to Twilio with URL %@",activityName,urlString);
    NSURL* url = nil;
//    if (IS_iPad)
//    {
//        url = [NSURL URLWithString:@"http://54.172.176.28/Twilio/WalkieTalkie/auth.php?ClientName=jenny"];
//        NSLog(@"Logging in as jenny");
//    }
//    else
//    {
//        url = [NSURL URLWithString:@"http://54.172.176.28/Twilio/WalkieTalkie/auth.php?ClientName=tommy"];
//        NSLog(@"Logging in as tommy");
//    }
    
    
    url = [NSURL URLWithString:urlString];
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                                         returningResponse:&response error:error];
    if (data)
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        if (httpResponse.statusCode==200)
        {
            capabilityToken = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            LOG_TWILIO(0,@"%@Successfully received capability token %@",activityName,capabilityToken);
        }
        else
        {
            LOG_TWILIO(1,@"%@Capability Token error: HTTP status code %d",activityName,httpResponse.statusCode);
//            NSLog(@"Capability Token error: HTTP status code %d",httpResponse.statusCode);
        }
    }
    else
    {
        LOG_TWILIO(1,@"%@Error logging in: %@",activityName,[*error localizedDescription]);

        //NSLog(@"Error logging in: %@", [*error localizedDescription]);
    }
    
    return capabilityToken;
}


-(BOOL)capabilityTokenValid
{
    //Check TCDevice's capability token to see if it is still valid
    BOOL isValid = NO;
    NSNumber* expirationTimeObject = [self.device.capabilities objectForKey:@"expiration"];
    long long expirationTimeValue = [expirationTimeObject longLongValue];
    long long currentTimeValue = (long long)[[NSDate date]timeIntervalSince1970];
    
    if ((expirationTimeValue-currentTimeValue)>0)
        isValid = YES;
    
    return isValid;
}

-(void)connect:(NSString*)clientName;
{
    NSString* activityName = @"connect:";
    // first check to see if the token we have is valid, and if not, refresh it.
    // Your own client may ask the user to re-authenticate to obtain a new token depending on
    // your security requirements.
    if (![self capabilityTokenValid])
    {
        //Capability token is not valid, so create a new one and update device
        
        //Set the capability token of the device to be the newly created capability token
        [self login];
    }
    
    //now check to see if we can make an outgoing call and attempt a connection if so
    NSNumber* hasOutgoing = [self.device.capabilities objectForKey:TCDeviceCapabilityOutgoingKey];
    if ([hasOutgoing boolValue]==YES)
    {
        //Disconnect if we've already got a connection in progress
        if (self.connection)
            [self disconnect];
        
        NSDictionary* parameters = nil;
        if ([clientName length]>0)
        {
            parameters = [NSDictionary dictionaryWithObject:clientName forKey:@"ClientName"];
        }
        self.connection = [self.device connect:parameters delegate:self];
       
        
        if (!self.connection)
            LOG_TWILIO(1,@"%@Couldn't establish outgoing call",activityName);
//            NSLog(@"Couldn't establish outgoing call");
    }
    else
    {
        LOG_TWILIO(1,@"%@Unable to make outgoing calls with current capabilities",activityName);
//        NSLog(@"Unable to make outgoing calls with current capabilities");
    }
}

-(void)disconnect
{
    // Destroy TCConnection.
    // We don't release until after the delegate callback for connectionDidConnect:
    [self.connection disconnect];
}

-(void)acceptIncomingConnection
{
    NSString* activityName = @"acceptIncomingConnection:";
    //Accept the pending connection
    [self.pendingIncomingConnection accept];
    self.connection = self.pendingIncomingConnection;
    self.pendingIncomingConnection = nil;
    
    LOG_TWILIO(0,@"%@Connection state %d",activityName,self.connection.state);
    
}

-(void)ignoreIncomingConnection
{
    // Ignore the pending connection
    // We don't release until after the delegate callback for connectionDidConnect:
    [self.pendingIncomingConnection ignore];
}

#pragma mark -
#pragma mark TCDeviceDelegate Methods

-(void)deviceDidStartListeningForIncomingConnections:(TCDevice*)device
{
    LOG_TWILIO(0,@"Device is now listening for incoming connections");
    [self setCallAvaibility:YES];
}

-(void)device:(TCDevice*)device didStopListeningForIncomingConnections:(NSError*)error
{
    NSString* activityName = @"device:didStopListeningForIncomingConnections:";

    if ( !error )
        LOG_TWILIO(0,@"%@Device went offline",activityName);
    else
        LOG_TWILIO(1,@"%@Device went offline due to error: %@",activityName, [error localizedDescription]);
//        NSLog(@"Device went offline due to error: %@", [error localizedDescription]);
    
    [self setCallAvaibility:NO];
}

-(void)device:(TCDevice*)device didReceiveIncomingConnection:(TCConnection*)c
{
    //Device received an incoming connection
    NSString* activityName = @"device:didReceiveIncomingConnection:";
    LOG_TWILIO(0,@"%@Received incoming call...",activityName);
    if (self.pendingIncomingConnection != nil)
    {
        // For simplicity, we only allow a single pending connection at once.
        // Your app may choose to do something more complicated.
        NSLog(@"A pending connection already exists");
        return;
    }
    
    self.pendingIncomingConnection = c; // retains
    self.pendingIncomingConnection.delegate = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WTPendingIncomingConnectionReceived object:nil];
}

-(void)device:(TCDevice *)device didReceivePresenceUpdate:(TCPresenceEvent *)presenceEvent
{
    NSString* activityName = @"device:didReceivePresenceUpdate:";
    
    LOG_TWILIO(0,@"%@Client %@ is available for call? %d",activityName,presenceEvent.name,presenceEvent.available);
    
    NSString* clientName = presenceEvent.name;
    NSNumber* isAvailable = [NSNumber numberWithBool:presenceEvent.available];
    //we check and add the client's presence update to our dictionary cache
    if ([self.clientPresenceInfo objectForKey:clientName] != nil)
    {
        
        //client exists in our cache
        [self.clientPresenceInfo removeObjectForKey:clientName];
        [self.clientPresenceInfo setObject:isAvailable forKey:clientName];
    }
    else
    {
        //client doesnt eist in our cache
        [self.clientPresenceInfo setObject:isAvailable forKey:clientName];
    }
    
    //now we post a notification that this has happened
    NSDictionary* userInfo = @{@"Name":presenceEvent.name, @"Available":[NSNumber numberWithBool:presenceEvent.available]};
    
     [[NSNotificationCenter defaultCenter] postNotificationName:WTPresenceUpdateForClient object:nil userInfo:userInfo];
}

#pragma mark - Client Presence Get/Update
- (NSNumber*)getPresenceForClient:(NSString *)clientName
{
 
    
    if ([self.clientPresenceInfo objectForKey:clientName] == nil)
    {
        //client is not in our dictionary, we return nil
        return nil;
    }
    else
    {
        return [self.clientPresenceInfo objectForKey:clientName];
    }
}

- (void) setCallAvailbilityForClient:(NSString *)clientName isAvailable:(BOOL)isAvailable
{
    NSNumber* newValue = [NSNumber numberWithBool:isAvailable];
    [self.clientPresenceInfo setObject:newValue forKey:clientName];
}

#pragma mark -
#pragma mark TCConnectionDelegate

-(void)connectionDidStartConnecting:(TCConnection*)connection
{
    NSString* activityName = @"connectionDidStartConnection:";
//    NSLog(@"Connection attempting to connect");
    LOG_TWILIO(0,@"%@Connection attempting to connect",activityName);
}

-(void)connectionDidConnect:(TCConnection*)connection
{
    NSString* activityName = @"connectionDidConnect:";
    LOG_TWILIO(0,@"%@Connection did connect",activityName);
//    NSLog(@"Connection Did Connect");
    
    // make sure we're using the speaker as an audio route
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:kAudioSessionOverrideAudioRoute_Speaker error:nil];
    
    // Start out muted when the connection is established.
    // The user presses the button on-screen to un-mute.
    self.muted = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WTConnectionDidConnect object:nil];
}

-(void)connectionDidDisconnect:(TCConnection*)c
{
    NSString* activityName = @"connectionDidDisconnect:";
//    NSLog(@"Connection did disconnect");
    LOG_TWILIO(0,@"%@Connection did disconnect",activityName);
    //If a connection still exists that we're tracking, release it.
    if (c == self.connection)
    {
        self.connection = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WTConnectionDidDisconnect object:nil];
    }
    else if (c == self.pendingIncomingConnection)
    {
        // This might happen if the caller calling us has hung up before we could ignore it or answer/disconnect explicitly.
      
        self.pendingIncomingConnection = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WTPendingIncomingConnectionDidDisconnect object:nil];
    }
}

-(void)connection:(TCConnection*)c didFailWithError:(NSError*)error
{
    NSLog(@"Connection failed with error: %@",error);
    if ( c == self.pendingIncomingConnection || c == self.connection )
        [[NSNotificationCenter defaultCenter] postNotificationName:WTConnectionDidFailWithError object:nil];
}




#pragma mark -
#pragma mark Mute

-(void)setMuted:(BOOL)muted
{
    // Since we only have a single connection, there's a global
    // "muted" property on the WalkieTalkie that just affects that
    // connection.  In a more complicated app you might independently mute
    // individual connections or all of them at once.
    self.connection.muted = muted;
}

-(BOOL)muted
{
    return self.connection.muted;
}


@end
