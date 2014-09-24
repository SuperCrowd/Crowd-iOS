//
//  UpdateProfile.h
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
@class C_MyUser;

typedef void(^SuccessBlock)();
typedef void(^FailBlock)(NSString *strError);

@interface UpdateProfile : NSObject

-(void)updateProfile_WithModel:(C_MyUser *)myModel withSuccessBlock:(SuccessBlock)successBlock withFailBlock:(FailBlock)failBlock;
@end
