//
//  UserDetailsModal.h
//  Dedicaring
//
//  Created by pratik on 31/10/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstant.h"

#import "AFDownloadRequestOperation.h"
typedef void (^DownloadBlock)(BOOL success, float progress, NSError *error);
@interface DownloadManager : NSObject
{
    AFDownloadRequestOperation *operation;
}
+ (DownloadManager *)sharedManager;
- (void)startDownloadWithURL:(NSString *)downloadUrl handler:(DownloadBlock)completionHandler;

-(void)downloadImagewithURL:(NSString *)strURL;



@end
