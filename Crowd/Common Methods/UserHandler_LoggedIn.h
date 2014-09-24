//
//  C_LoggedIn_UserHandler.h
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
@class C_MyUser;
@interface UserHandler_LoggedIn : NSObject
+(NSMutableDictionary *)getDict_To_RegisterUser;
+(C_MyUser *)getMyUser_LoggedIN;
+(void)saveMyUser_LoggedIN:(C_MyUser *)myUser;


+(NSMutableDictionary *)getDict_To_Update_withProfileModel:(C_MyUser *)myModel;
@end
