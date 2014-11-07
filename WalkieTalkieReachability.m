//
//  Copyright 2013 Twilio. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>
#import "WalkieTalkieReachability.h"

#define kShouldPrintReachabilityFlags DEBUG

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char *comment)
{
#if kShouldPrintReachabilityFlags
	
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				  ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


@implementation WalkieTalkieReachability
static void TCReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    
	if ( [(__bridge NSObject *)info isKindOfClass: [WalkieTalkieReachability class]] )
	{
		// We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
		// in case someone uses the Reachablity object in a different thread.
		@autoreleasepool {
            WalkieTalkieReachability *noteObject = (__bridge WalkieTalkieReachability *)info;
            // Post a notification to notify the client that the network reachability changed.
            [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
        }
    }
}

-(BOOL)startNotifier
{
	BOOL retVal = NO;
	SCNetworkReachabilityContext	context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	if(SCNetworkReachabilitySetCallback(reachabilityRef, TCReachabilityCallback, &context))
	{
		if(SCNetworkReachabilitySetDispatchQueue(reachabilityRef, dispatch_get_main_queue()))
		{
			retVal = YES;
		}
	}
	return retVal;
}

-(void)stopNotifier
{
	if(reachabilityRef != NULL)
	{
		SCNetworkReachabilitySetDispatchQueue(reachabilityRef, NULL);
		SCNetworkReachabilitySetCallback(reachabilityRef, NULL, NULL);
	}
}

//-(void)dealloc
//{
//	[self stopNotifier];
//	if(reachabilityRef != NULL)
//	{
//		CFRelease(reachabilityRef);
//        reachabilityRef = NULL;
//	}
//	[super dealloc];
//}

+(WalkieTalkieReachability *)reachabilityWithHostName:(NSString *)hostName;
{
	WalkieTalkieReachability *retVal = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if(reachability!= NULL)
	{
		retVal= [[self alloc] init];
		if(retVal != NULL)
		{
			retVal->reachabilityRef = reachability;
			retVal->localWiFiRef = NO;
		}
	}
	return retVal;
}

+(WalkieTalkieReachability *)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
	WalkieTalkieReachability* retVal = NULL;
	if(reachability != NULL)
	{
		retVal= [[self alloc] init];
		if(retVal != NULL)
		{
			retVal->reachabilityRef = reachability;
			retVal->localWiFiRef = NO;
		}
	}
	return retVal;
}

+(WalkieTalkieReachability*)reachabilityForInternetConnection;
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	return [self reachabilityWithAddress: &zeroAddress];
}

+(WalkieTalkieReachability*)reachabilityForLocalWiFi;
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	WalkieTalkieReachability* retVal = [self reachabilityWithAddress: &localWifiAddress];
	if(retVal != NULL)
	{
		retVal->localWiFiRef = YES;
	}
	return retVal;
}

#pragma mark Network Flag Handling

-(NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "localWiFiStatusForFlags");
    
	BOOL retVal = NotReachable;
	if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
	{
		retVal = ReachableViaWiFi;
	}
	return retVal;
}

-(NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "networkStatusForFlags");
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// if target host is not reachable
		return NotReachable;
	}
    
	BOOL retVal = NotReachable;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = ReachableViaWiFi;
	}
	
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = ReachableViaWiFi;
        }
    }
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = ReachableViaWWAN;
	}
	return retVal;
}

-(BOOL)connectionRequired;
{
	NSAssert(reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
	{
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
	return NO;
}

-(NetworkStatus)currentReachabilityStatus
{
	NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
	NetworkStatus retVal = NotReachable;
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
	{
		if(localWiFiRef)
		{
			retVal = [self localWiFiStatusForFlags: flags];
		}
		else
		{
			retVal = [self networkStatusForFlags: flags];
		}
	}
	return retVal;
}
@end