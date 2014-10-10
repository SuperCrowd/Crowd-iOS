//
//  C_FollowUser.h
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - WORK HERE
@interface C_Model_Work_Follower : NSObject
@property NSString *EmployerName;
@property NSString *Title;
@property NSString *workID;
@property NSString *Summary;

@property NSString *LocationCity;
@property NSString *LocationState;
@property NSString *LocationCountry;

@property NSString *StartMonth;
@property NSString *StartYear;
@property NSString *EndMonth;
@property NSString *EndYear;

@property NSString *DateCreated;
@property NSString *DateModified;
@end

#pragma mark -
#pragma mark - FINAL MODEL HERE
@interface C_FollowUser : NSObject

@property NSString *UserId;
@property NSString *Email;
@property NSString *FirstName;
@property NSString *LastName;
@property NSString *LinkedInId;
@property NSString *Token;

@property NSString *ExperienceLevel;
@property NSString *Industry;
@property NSString *Industry2;

@property NSString *LocationCity;
@property NSString *LocationState;
@property NSString *LocationCountry;

@property NSString *NumberOfUnreadMessage;
@property NSString *PhotoURL;
@property NSString *Summary;

@property NSString *DateCreated;
@property NSString *DateModified;


@property NSMutableArray *arr_WorkALL;


#pragma mark - Methods
+(C_FollowUser *)addNewUser:(NSDictionary *)dictTTTT;

@end
