//
//  C_MyUser.h
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark -
#pragma mark - EDUCATION HERE
@interface C_Model_Courses : NSObject
@property NSString *courseID;
@property NSString *Course;
@property NSString *DateCreated;
@property NSString *EducationID;
@end


@interface C_Model_Education : NSObject
@property NSString *educationID;
@property NSString *Name;
@property NSString *Degree;

@property NSString *StartMonth;
@property NSString *StartYear;
@property NSString *EndMonth;
@property NSString *EndYear;

@property NSString *DateCreated;
@property NSString *DateModified;

@property NSMutableArray *arrCourses;
@end

#pragma mark -
#pragma mark - WORK HERE
@interface C_Model_Work : NSObject
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
@property BOOL isCurrent;
@end

#pragma mark -
#pragma mark - SKILLS HERE
@interface C_Model_Skills : NSObject
@property NSString *skillsID;
@property NSString *Skills;
@property NSString *DateCreated;
@end



#pragma mark -
#pragma mark - RECOMMENDATION HERE
@interface C_Model_Recommendation : NSObject
@property NSString *recommendID;
@property NSString *Recommendation;
@property NSString *RecommenderName;
@property NSString *DateCreated;
@end

#pragma mark -
#pragma mark - FINAL MODEL HERE
@interface C_MyUser : NSObject
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

@property NSMutableArray *arr_EducationALL;
@property NSMutableArray *arr_WorkALL;
@property NSMutableArray *arr_RecommendationALL;
@property NSMutableArray *arr_SkillsALL;

#pragma mark - Methods
+(C_MyUser *)addNewUser:(NSDictionary *)dictTTTT;

@end
