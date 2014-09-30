//
//  C_PostJobModel.m
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJobModel.h"
#import "AppConstant.h"
@implementation C_PostJobModel
+(C_PostJobModel *)addPostJobModel:(NSDictionary *)dictT
{
    C_PostJobModel *myJob = [[C_PostJobModel alloc]init];
    
    myJob.JobID = [[NSString stringWithFormat:@"%@",dictT[@"ID"]] isNull];
    myJob.Title = [[NSString stringWithFormat:@"%@",dictT[@"Title"]] isNull];
    myJob.Company = [[NSString stringWithFormat:@"%@",dictT[@"Company"]] isNull];
    myJob.Industry = [[NSString stringWithFormat:@"%@",dictT[@"Industry"]] isNull];
    myJob.Industry2 = [[NSString stringWithFormat:@"%@",dictT[@"Industry2"]] isNull];
    
    myJob.LocationCity = [[NSString stringWithFormat:@"%@",dictT[@"LocationCity"]] isNull];
    myJob.LocationState = [[NSString stringWithFormat:@"%@",dictT[@"LocationState"]] isNull];
    myJob.LocationCountry = [[NSString stringWithFormat:@"%@",dictT[@"LocationCountry"]] isNull];
    myJob.ExperienceLevel = [[NSString stringWithFormat:@"%@",dictT[@"ExperienceLevel"]] isNull];
    myJob.Responsibilities = [[NSString stringWithFormat:@"%@",dictT[@"Responsibilities"]] isNull];
    myJob.URL = [[NSString stringWithFormat:@"%@",dictT[@"URL"]] isNull];
    
    if ([dictT[@"JobSkills"] isKindOfClass:[NSArray class]])
    {
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        NSArray *arrS = dictT[@"JobSkills"];
        for (NSDictionary *dictSkills in arrS)
        {
            [arr addObject:@{@"Skill":dictSkills [@"Skill"]}];
        }
        myJob.arrSkills = arr;
    }
    else
    {
        myJob.arrSkills = [NSMutableArray array];
    }
    
    myJob.EmployerIntroduction = [[NSString stringWithFormat:@"%@",dictT[@"EmployerIntroduction"]] isNull];
    myJob.Qualifications = [[NSString stringWithFormat:@"%@",dictT[@"Qualifications"]] isNull];
    return myJob;
}
@end
