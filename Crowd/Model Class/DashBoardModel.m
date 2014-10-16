//
//  DashBoardModel.m
//  Crowd
//
//  Created by MAC107 on 09/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "DashBoardModel.h"
#import "AppConstant.h"
@implementation DashBoardModel


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


/*
 OtherUserID;
 LinkedInId;
 Type;
 FirstName;
 LastName;
 Industry;
 Industry2;
 Email;
 LocationCity;
 LocationState;
 LocationCountry;
 PhotoURL;
 Summary;
 ExperienceLevel;
 
 JobID;
 Job_Title;
 Job_Company;
 Job_Industry;
 Job_Industry2;
 Job_LocationCity;
 Job_LocationState;
 Job_LocationCountry;
 Job_Responsibilities;
 Job_URL;
 Job_EmployerIntroduction;
 Job_Qualifications;
 */
+(DashBoardModel *)addDashBoardListModel:(NSDictionary *)dictT
{
    
    DashBoardModel *myDashBoard = [[DashBoardModel alloc]init];
    @try
    {
        myDashBoard.OtherUserID = [[NSString stringWithFormat:@"%@",dictT[@"OtherUserID"]] isNull];
        myDashBoard.Type = [[NSString stringWithFormat:@"%@",dictT[@"Type"]] isNull];
        myDashBoard.JobID = [[NSString stringWithFormat:@"%@",dictT[@"JobID"]] isNull];;


        NSDictionary *dictOtherUser = dictT[@"OtherUserDetails"];
        
        myDashBoard.LinkedInId = [[NSString stringWithFormat:@"%@",dictOtherUser[@"LinkedInId"]] isNull];
        myDashBoard.Email = [[NSString stringWithFormat:@"%@",dictOtherUser[@"Email"]] isNull];
        
        myDashBoard.FirstName = [[NSString stringWithFormat:@"%@",dictOtherUser[@"FirstName"]] isNull];
        myDashBoard.LastName = [[NSString stringWithFormat:@"%@",dictOtherUser[@"LastName"]] isNull];
        
        myDashBoard.Industry = [[NSString stringWithFormat:@"%@",dictOtherUser[@"Industry"]] isNull];
        myDashBoard.Industry2 = [[NSString stringWithFormat:@"%@",dictOtherUser[@"Industry2"]] isNull];
        
        myDashBoard.LocationCity = [[NSString stringWithFormat:@"%@",dictOtherUser[@"LocationCity"]] isNull];
        myDashBoard.LocationState = [[NSString stringWithFormat:@"%@",dictOtherUser[@"LocationState"]] isNull];
        myDashBoard.LocationCountry = [[NSString stringWithFormat:@"%@",dictOtherUser[@"LocationCountry"]] isNull];
        
        myDashBoard.PhotoURL = [[NSString stringWithFormat:@"%@",dictOtherUser[@"PhotoURL"]] isNull];
        myDashBoard.Summary = [[NSString stringWithFormat:@"%@",dictOtherUser[@"Summary"]] isNull];
        myDashBoard.ExperienceLevel = [[NSString stringWithFormat:@"%@",dictOtherUser[@"ExperienceLevel"]] isNull];
        
        if ([dictT[@"JobDetail"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dictJob = dictT[@"JobDetail"];
            @try
            {
                myDashBoard.Job_Title = [[NSString stringWithFormat:@"%@",dictJob[@"Title"]] isNull];;
                myDashBoard.Job_Company = [[NSString stringWithFormat:@"%@",dictJob[@"Company"]] isNull];;
                myDashBoard.Job_Industry = [[NSString stringWithFormat:@"%@",dictJob[@"Industry"]] isNull];;
                myDashBoard.Job_Industry2 = [[NSString stringWithFormat:@"%@",dictJob[@"Industry2"]] isNull];;
                myDashBoard.Job_LocationCity = [[NSString stringWithFormat:@"%@",dictJob[@"LocationCity"]] isNull];;
                myDashBoard.Job_LocationState = [[NSString stringWithFormat:@"%@",dictJob[@"LocationState"]] isNull];;
                myDashBoard.Job_LocationCountry = [[NSString stringWithFormat:@"%@",dictJob[@"LocationCountry"]] isNull];;
                myDashBoard.Job_Responsibilities = [[NSString stringWithFormat:@"%@",dictJob[@"Responsibilities"]] isNull];;
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            
            
            @try
            {
                myDashBoard.Job_URL = [[NSString stringWithFormat:@"%@",dictJob[@"URL"]] isNull];;
                myDashBoard.Job_EmployerIntroduction = [[NSString stringWithFormat:@"%@",dictJob[@"EmployerIntroduction"]] isNull];;
                myDashBoard.Job_Qualifications = [[NSString stringWithFormat:@"%@",dictJob[@"Qualifications"]] isNull];;
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
                
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    if([myDashBoard.Type isEqualToString:@"1"])
    {
        NSString *StrM = [NSString stringWithFormat:@"%@ %@ has followed you.",myDashBoard.FirstName,myDashBoard.LastName];
        /*--- Set full strig same font ---*/
        NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithString:StrM];
        NSRange fullString = [[attrib string] rangeOfString:StrM];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:fullString];

        myDashBoard.strClickable = @"";
        myDashBoard.attribS = attrib;
        
    }
    else if([myDashBoard.Type isEqualToString:@"2"])
    {
        
        NSString *StrM = [NSString stringWithFormat:@"%@ %@ has sent you a message.",myDashBoard.FirstName,myDashBoard.LastName];
        /*--- Set full strig same font ---*/
        NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithString:StrM];
        NSRange fullString = [[attrib string] rangeOfString:StrM];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:fullString];
        
        myDashBoard.strClickable = @"";
        myDashBoard.attribS = attrib;

    }
    else if([myDashBoard.Type isEqualToString:@"3"])
    {
        
        NSMutableString *StrM = [[NSMutableString alloc]init];
        [StrM appendFormat:@"%@ %@ has applied for a job you posted:",myDashBoard.FirstName,myDashBoard.LastName];
        [StrM appendFormat:@" "];
        [StrM appendString:myDashBoard.Job_Title];
        [StrM appendString:@" at "];
        [StrM appendString:myDashBoard.Job_Company];
        [StrM appendFormat:@" "];
        NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
        if (![[myDashBoard.Job_LocationCity isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationCity isNull]];
        if (![[myDashBoard.Job_LocationState isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationState isNull]];
        if (![[myDashBoard.Job_LocationCountry isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationCountry isNull]];
        NSString *strLoc = [arrLoc componentsJoinedByString:@","];
        
        [StrM appendString:[strLoc stringByReplacingOccurrencesOfString:@"," withString:@", "]];

        
        //myDashBoard.strDisplayText = StrM;
        
        /*--- Only attributed when Apply ---*/
        NSString *strT = [NSString stringWithFormat:@"%@ at %@",myDashBoard.Job_Title,myDashBoard.Job_Company];
        NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithString:StrM];
        NSRange fullString = [[attrib string] rangeOfString:StrM];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:fullString];

        /*--- Now apply link on specific ---*/
        NSRange goRange = [[attrib string] rangeOfString:strT];
        [attrib addAttributes:@{NSLinkAttributeName: @"www.google.com"} range:goRange];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:goRange];
        [attrib addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:goRange];
//        [attrib addAttribute:NSUnderlineColorAttributeName value:[UIColor blackColor] range:goRange];
//        [attrib addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:goRange];

        
        myDashBoard.strClickable = strT;
        myDashBoard.attribS = attrib;
    }
    else if([myDashBoard.Type isEqualToString:@"4"])
    {
        NSMutableString *StrM = [[NSMutableString alloc]init];
        [StrM appendFormat:@"%@ %@ has filled the job you favorited or applied to:",myDashBoard.FirstName,myDashBoard.LastName];
        [StrM appendFormat:@" "];
        [StrM appendString:myDashBoard.Job_Title];
        [StrM appendString:@" at "];
        [StrM appendString:myDashBoard.Job_Company];
        [StrM appendFormat:@" "];
        NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
        if (![[myDashBoard.Job_LocationCity isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationCity isNull]];
        if (![[myDashBoard.Job_LocationState isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationState isNull]];
        if (![[myDashBoard.Job_LocationCountry isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationCountry isNull]];
        NSString *strLoc = [arrLoc componentsJoinedByString:@","];
        
        [StrM appendString:[strLoc stringByReplacingOccurrencesOfString:@"," withString:@", "]];
        
        
        NSString *strT = [NSString stringWithFormat:@"%@ at %@",myDashBoard.Job_Title,myDashBoard.Job_Company];
        /*--- Now apply link on specific ---*/
        
        NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithString:StrM];
        
        /*--- Set full strig same font ---*/
        NSRange fullString = [[attrib string] rangeOfString:StrM];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:fullString];
        
        NSRange goRange = [[attrib string] rangeOfString:strT];
        [attrib addAttributes:@{NSLinkAttributeName: @"www.google.com"} range:goRange];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:goRange];
        [attrib addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:goRange];
        
        myDashBoard.strClickable = strT;
        myDashBoard.attribS = attrib;
    }
    else if([myDashBoard.Type isEqualToString:@"5"])
    {
        NSMutableString *StrM = [[NSMutableString alloc]init];
        [StrM appendFormat:@"%@ %@ has reopened the job you favorited or applied to:",myDashBoard.FirstName,myDashBoard.LastName];
        [StrM appendFormat:@" "];
        [StrM appendString:myDashBoard.Job_Title];
        [StrM appendString:@" at "];
        [StrM appendString:myDashBoard.Job_Company];
        [StrM appendFormat:@" "];
        NSMutableArray *arrLoc = [[NSMutableArray alloc]init];
        if (![[myDashBoard.Job_LocationCity isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationCity isNull]];
        if (![[myDashBoard.Job_LocationState isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationState isNull]];
        if (![[myDashBoard.Job_LocationCountry isNull]isEqualToString:@""])
            [arrLoc addObject:[myDashBoard.Job_LocationCountry isNull]];
        NSString *strLoc = [arrLoc componentsJoinedByString:@","];
        
        [StrM appendString:[strLoc stringByReplacingOccurrencesOfString:@"," withString:@", "]];
        
        /*--- Set full strig same font ---*/
        NSString *strT = [NSString stringWithFormat:@"%@ at %@",myDashBoard.Job_Title,myDashBoard.Job_Company];
        
        
        NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithString:StrM];
        NSRange fullString = [[attrib string] rangeOfString:StrM];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:fullString];
        
        NSRange goRange = [[attrib string] rangeOfString:strT];
        [attrib addAttributes:@{NSLinkAttributeName: @"www.google.com"} range:goRange];
        [attrib addAttribute:NSFontAttributeName value:kFONT_LIGHT(14.0) range:goRange];
        [attrib addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:goRange];
        
        myDashBoard.strClickable = strT;
        myDashBoard.attribS = attrib;

    }
    else
    {
//        myDashBoard.strDisplayText = [NSMutableString stringWithFormat:@""];
        NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithString:@""];

        
        myDashBoard.strClickable = @"";
        myDashBoard.attribS = attrib;

    }
    
    return myDashBoard;
}
/*
 Type : 1 - Follow
 “<FIRST NAME> <LAST NAME> has followed you”
 
 Type : 2 - Message
 “<FIRST NAME> <LAST NAME> has sent you a message”
 
 Type : 3 - Job Apply
 “<FIRST NAME> <LAST NAME> has applied for a job you posted: <JOB TITLE> at <JOB COMPANY> <JOB LOCATION CITY> <JOB LOCATION STATE> <JOB LOCATION COUNTRY>”
 
 Type : 4 - Filled job
 “<FIRST NAME> <LAST NAME> has filled the job you favorited or applied to: <JOB TITLE> at <JOB COMPANY> <JOB LOCATION CITY> <JOB LOCATION STATE> <JOB LOCATION COUNTRY>”
 
 Type : 5 - Reoped job
 “<FIRST NAME> <LAST NAME> has reopened the job you favorited or applied to: <JOB TITLE> at <JOB COMPANY> <JOB LOCATION CITY> <JOB LOCATION STATE> <JOB LOCATION COUNTRY>”
 */
@end
