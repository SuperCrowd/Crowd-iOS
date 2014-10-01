//
//  C_CandidateModel.h
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C_CandidateModel : NSObject
@property NSString *UserId;
@property NSString *LinkedInId;

@property NSString *Email;
@property NSString *FirstName;
@property NSString *LastName;

@property NSString *Industry;
@property NSString *Industry2;

@property NSString *LocationCity;
@property NSString *LocationState;
@property NSString *LocationCountry;

@property NSString *PhotoURL;
@property NSString *Summary;

@property NSString *ExperienceLevel;

@property NSString *EmployerName;
@property BOOL isShowDescription;
+(C_CandidateModel *)addCandidateListModel:(NSDictionary *)dictT;

@end
/*DateCreated = "9/17/2014 11:22:55 AM";
DateModified = "9/17/2014 11:22:55 AM";
Email = "chintan@crowd.com";
ExperienceLevel = 1;
FirstName = Chintan;
Industry = Computers;
Industry2 = Industry2;
LastName = Ramani;
LinkedInId = Chintan;
LocationCity = Ahmedabad;
LocationCountry = India;
LocationState = Gujarat;
PhotoURL = "";
Summary = "Chintan Ramani Summary";
UserCurrentEmployer =                 (
                                       {
                                           DateCreated = "9/17/2014 11:22:55 AM";
                                           DateModified = "9/17/2014 11:22:55 AM";
                                           EmployerName = Tatvasoft;
                                           EndMonth = "";
                                           EndYear = "";
                                           ID = 108;
                                           LocationCity = Ahmedabad;
                                           LocationCountry = India;
                                           LocationState = Gujarat;
                                           StartMonth = 11;
                                           StartYear = 2013;
                                           Summary = "Tatvasoft Summary Here";
                                           Title = "Sr. Software Engg";
                                           UserId = 28;
                                       }
                                       );
UserId = 28;
}*/