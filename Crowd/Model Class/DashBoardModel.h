//
//  DashBoardModel.h
//  Crowd
//
//  Created by MAC107 on 09/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DashBoardModel : NSObject

@property NSString *OtherUserID;
@property NSString *LinkedInId;
@property NSString *Type;

@property NSString *FirstName;
@property NSString *LastName;
@property NSString *Industry;
@property NSString *Industry2;
@property NSString *Email;

@property NSString *LocationCity;
@property NSString *LocationState;
@property NSString *LocationCountry;

@property NSString *PhotoURL;
@property NSString *Summary;
@property NSString *ExperienceLevel;


// Now Job ID
@property NSString *JobID;

@property NSString *Job_Title;
@property NSString *Job_Company;
@property NSString *Job_Industry;
@property NSString *Job_Industry2;

@property NSString *Job_LocationCity;
@property NSString *Job_LocationState;
@property NSString *Job_LocationCountry;

@property NSString *Job_Responsibilities;
@property NSString *Job_URL;

@property NSString *Job_EmployerIntroduction;
@property NSString *Job_Qualifications;


//@property NSMutableString *strDisplayText;

@property NSMutableAttributedString *attribS;
@property NSString *strClickable;

+(DashBoardModel *)addDashBoardListModel:(NSDictionary *)dictT;

/*{
    DateCreated = "10/9/2014 7:10:42 AM";
    ID = 82;
    JobDetail =                 {
        Company = "T2 Job Creator";
        DateCreated = "10/9/2014 7:10:10 AM";
        DateModified = "10/9/2014 7:10:10 AM";
        EmployerIntroduction = "";
        ID = 92;
        Industry = "Computer Software";
        Industry2 = Accounting;
        LocationCity = Ahd;
        LocationCountry = Ind;
        LocationState = "";
        Qualifications = "";
        Responsibilities = "Roles Goes here.";
        ShareURL = "<null>";
        State = False;
        Title = Devvv;
        URL = "";
        UserId = 61;
    };
    JobID = 92;
    OtherUserDetails =                 {
        DateCreated = "10/8/2014 11:51:18 AM";
        DateModified = "10/8/2014 11:51:18 AM";
        Email = "tatvathird@gmail.com";
        ExperienceLevel = 3;
        FirstName = Tatva;
        Industry = "Computer Software";
        Industry2 = Accounting;
        LastName = Third;
        LinkedInId = "b_HcCybQNR";
        LocationCity = "Ahmedabad Area";
        LocationCountry = India;
        LocationState = "";
        PhotoURL = "Profilee781e95a-aa73-43a7-a172-b4cfdcfffe43.PNG";
        Summary = "My professional Summary Goes Here.\n\n\n- updated\n\n\n- Thanks";
        UserId = 60;
    };
    OtherUserID = 60;
    Type = 3;
    UserId = 61;
}*/
@end
