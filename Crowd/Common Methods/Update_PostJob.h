//
//  Update_PostJob.h
//  Crowd
//
//  Created by MAC107 on 08/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)();
typedef void(^FailBlock)(NSString *strError);
@interface Update_PostJob : NSObject


-(void)update_JobPost_with_withSuccessBlock:(SuccessBlock)successBlock withFailBlock:(FailBlock)failBlock;

@end
