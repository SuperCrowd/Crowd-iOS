//
//  C_JobListModel.m
//  Crowd
//
//  Created by MAC107 on 29/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_JobListModel.h"
#import "AppConstant.h"
/*
 JobID;
 UserId;
 Title;
 Company;
 Industry;
 Industry2;
 LocationCity;
 LocationState;
 LocationCountry;
 ShareURL;
 URL;
 Qualifications;
 Responsibilities;
 ExperienceLevel;
 EmployerIntroduction;
 DateCreated;
 DateModified;
 */
@implementation C_JobListModel
+(C_JobListModel *)addJobListModel:(NSDictionary *)dictT
{
    C_JobListModel *myJob = [[C_JobListModel alloc]init];
    @try
    {
        myJob.JobID = [[NSString stringWithFormat:@"%@",dictT[@"ID"]] isNull];
        myJob.UserId = [[NSString stringWithFormat:@"%@",dictT[@"UserId"]] isNull];
        myJob.FirstName = [[NSString stringWithFormat:@"%@",dictT[@"FirstName"]] isNull];
        myJob.LastName = [[NSString stringWithFormat:@"%@",dictT[@"LastName"]] isNull];
        
        myJob.Title = [[NSString stringWithFormat:@"%@",dictT[@"Title"]] isNull];
        
        myJob.Company = [[NSString stringWithFormat:@"%@",dictT[@"Company"]] isNull];
        myJob.Industry = [[NSString stringWithFormat:@"%@",dictT[@"Industry"]] isNull];
        myJob.Industry2 = [[NSString stringWithFormat:@"%@",dictT[@"Industry2"]] isNull];
        
        myJob.LocationCity = [[NSString stringWithFormat:@"%@",dictT[@"LocationCity"]] isNull];
        myJob.LocationState = [[NSString stringWithFormat:@"%@",dictT[@"LocationState"]] isNull];
        myJob.LocationCountry = [[NSString stringWithFormat:@"%@",dictT[@"LocationCountry"]] isNull];
        myJob.ExperienceLevel = [[NSString stringWithFormat:@"%@",dictT[@"ExperienceLevel"]] isNull];
        myJob.Responsibilities = [[NSString stringWithFormat:@"%@",dictT[@"Responsibilities"]] isNull];
        myJob.isShowDescription = NO;
        myJob.arrSkills = [NSMutableArray array];
        myJob.IsJobApplied = NO;
        myJob.IsJobFavorite = NO;
        
        if ([dictT[@"State"] isEqualToString:@"True"])
            myJob.State = YES;
        else
            myJob.State = NO;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    @try
    {
        myJob.URL = [[NSString stringWithFormat:@"%@",dictT[@"URL"]] isNull];
        myJob.ShareURL = [[NSString stringWithFormat:@"%@",dictT[@"ShareURL"]] isNull];
        
        myJob.EmployerIntroduction = [[NSString stringWithFormat:@"%@",dictT[@"EmployerIntroduction"]] isNull];
        myJob.Qualifications = [[NSString stringWithFormat:@"%@",dictT[@"Qualifications"]] isNull];
        
        myJob.DateCreated = [[NSString stringWithFormat:@"%@",dictT[@"DateCreated"]] isNull];
        myJob.DateModified = [[NSString stringWithFormat:@"%@",dictT[@"DateModified"]] isNull];
        if (![myJob.DateCreated isEqualToString:@""])
            myJob.dateStr = [[myJob.DateCreated componentsSeparatedByString:@" "] objectAtIndex:0];
        else
            myJob.dateStr = @"";
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }

    return myJob;
}

+(C_JobListModel *)updateModel:(C_JobListModel *)myJob withDict:(NSDictionary *)dictT
{
    myJob.IsJobApplied = [dictT[@"IsJobApplied"] boolValue];
    myJob.IsJobFavorite = [dictT[@"IsJobFavorite"] boolValue];

    myJob.FirstName = [[NSString stringWithFormat:@"%@",dictT[@"FirstName"]] isNull];
    myJob.LastName = [[NSString stringWithFormat:@"%@",dictT[@"LastName"]] isNull];
    
    if ([dictT[@"JobDetailsWithSkills"][@"JobSkills"] isKindOfClass:[NSArray class]])
    {
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        NSArray *arrS = dictT[@"JobDetailsWithSkills"][@"JobSkills"];
        for (NSDictionary *dictSkills in arrS)
        {
            [arr addObject:@{@"Skill":dictSkills [@"Skill"]}];
        }
        myJob.arrSkills = arr;
    }

    return myJob;
}
@end
