//
//  C_JobListModel.h
//  Crowd
//
//  Created by MAC107 on 29/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C_JobListModel : NSObject
@property NSString *JobID;
@property NSString *UserId;
@property NSString *Title;
@property NSString *Company;
@property NSString *Industry;
@property NSString *Industry2;
@property NSString *LocationCity;
@property NSString *LocationState;
@property NSString *LocationCountry;

@property NSString *ShareURL;
@property NSString *URL;
@property NSString *Qualifications;
@property NSString *Responsibilities;
@property NSString *ExperienceLevel;
@property NSString *EmployerIntroduction;


@property NSString *dateStr;
@property NSString *DateCreated;
@property NSString *DateModified;

@property NSMutableArray *arrSkills;
@property BOOL IsJobApplied;
@property BOOL IsJobFavorite;

@property BOOL isShowDescription;
+(C_JobListModel *)updateModel:(C_JobListModel *)myJob withDict:(NSDictionary *)dictT;

/*
 Company = Tatvasoft;
 DateCreated = "9/17/2014 1:16:47 PM";
 DateModified = "9/17/2014 1:21:01 PM";
 EmployerIntroduction = "Tatvasoft details";
 ExperienceLevel = 1;
 ID = 14;
 Industry = Computers;
 Industry2 = "";
 LocationCity = Ahmedabad;
 LocationCountry = India;
 LocationState = Gujarat;
 Qualifications = "BE/MCA with 2+ yrs of expr";
 Responsibilities = "Coding, documentation, on time delivery, etc";
 ShareURL = "www.tatvasoft.com";
 State = False;
 Title = "iOS Developer";
 URL = "www.tatvasoft.com";
 UserId = 27;
 */

+(C_JobListModel *)addJobListModel:(NSDictionary *)dictT;

@end
