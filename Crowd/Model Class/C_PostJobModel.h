//
//  C_PostJobModel.h
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C_PostJobModel : NSObject

@property NSString *JobID;
@property NSString *Title;

@property NSString *Company;
@property NSString *Industry;
@property NSString *Industry2;

@property NSString *LocationCity;
@property NSString *LocationState;
@property NSString *LocationCountry;


@property NSString *ExperienceLevel;
@property NSString *Responsibilities;
@property NSString *URL;

@property NSMutableArray *arrSkills;



@property NSString *EmployerIntroduction;
@property NSString *Qualifications;

+(C_PostJobModel *)addPostJobModel:(NSDictionary *)dictT;

@end
/*{
 Company = c1;
 DateCreated = "9/23/2014 9:54:07 AM";
 DateModified = "9/23/2014 9:54:07 AM";
 EmployerIntroduction = "";
 ExperienceLevel = 1;
 ID = 24;
 Industry = Accounting;
 Industry2 = "";
 JobSkills =             (
 {
 DateCreated = "9/23/2014 9:54:07 AM";
 ID = 57;
 JobID = 24;
 Skill = s1;
 }
 );
 LocationCity = Ahmedabad1;
 LocationCountry = India1;
 LocationState = Gujarat1;
 Qualifications = "";
 Responsibilities = r1;
 ShareURL = "<null>";
 State = False;
 Title = p1;
 URL = "";
 UserId = 42;
 };*/