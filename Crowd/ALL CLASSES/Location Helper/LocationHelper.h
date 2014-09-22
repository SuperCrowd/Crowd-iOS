//
//  LocationHelper.h
//
//  Created by Chris Hulbert on 24/04/12.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define locationHelperPurpose @"This app would like to know your location for some good reason." // Change this!

typedef void(^LocationBlock)(CLLocation* newlocation,CLLocation* oldlocation); // Is called with nil on error

@interface LocationHelper : NSObject<CLLocationManagerDelegate>

+ (void)getRoughLocation:(LocationBlock)block;

@end
