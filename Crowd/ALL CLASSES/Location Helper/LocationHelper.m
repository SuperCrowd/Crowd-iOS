//
//  LocationHelper.m
//
//  Created by Chris Hulbert on 24/04/12.
//

#import "LocationHelper.h"
#import "AppConstant.h"

@interface LocationHelper()
@property(copy) LocationBlock locationBlock;
@property(strong) CLLocationManager* locMan;
@end

@implementation LocationHelper
@synthesize locationBlock, locMan;

+ (void)getRoughLocation:(LocationBlock)block {
    if ([CLLocationManager locationServicesEnabled]) {
        
        // We have to instantiate something so we can use it as a delegate. Boo hiss. Blocks rule!
        LocationHelper* lh = [[LocationHelper alloc] init];
        lh.locationBlock = block;
        
        // Kick off the location finder
        lh.locMan = [[CLLocationManager alloc] init];
        lh.locMan.desiredAccuracy = kCLLocationAccuracyBest; // Get the roughest accuracy (eg use cell towers not gps)
        lh.locMan.delegate = lh;
       // lh.locMan.purpose = locationHelperPurpose;
        [lh.locMan startUpdatingLocation];
        
        // This serves two purposes: keep the instance retained by the runloop, and timeout if things don't work
        [lh performSelector:@selector(timeout) withObject:nil afterDelay:300];
        
    } else {
        block(nil,nil); // Not enabled
    }    
}

// This is used to keep the instance retained by the runloop, and to call the block just in case the location manager didn't
- (void)timeout {
    if (self.locationBlock) {
        self.locationBlock(nil,nil);
        self.locationBlock=nil;
    }
    self.locMan = nil;
}


#pragma mark - Delegate stuff


/*- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (self.locationBlock) {
        self.locationBlock(newLocation,oldLocation);
        self.locationBlock=nil;
    }
    
    self.locMan = nil;
}*/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if (self.locationBlock) {
        
        if (locations.count > 0) {
            CLLocation *newLocation = [locations lastObject];
            CLLocation *oldLocation;
            if (locations.count > 1) {
                oldLocation = [locations objectAtIndex:locations.count-2];
            } else {
                oldLocation = nil;
            }
            self.locationBlock(newLocation,oldLocation);
            self.locationBlock=nil;
        }
        else{
            self.locationBlock(nil,nil);
            self.locationBlock=nil;
        }
    }
    self.locMan = nil;
}
// If it fails, 
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to get current Location : %@",[error localizedDescription]);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            //No Internet
        }
            break;
        case kCLErrorDenied:{
        }
            break;
        default:
        {
        }
            break;
    }

    if (self.locationBlock) {
        self.locationBlock(nil,nil);
        self.locationBlock=nil;
    }

    self.locMan = nil;
}


@end
