//
//  C_CandidateModel.m
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_CandidateModel.h"
#import "AppConstant.h"
@implementation C_CandidateModel

+(C_CandidateModel *)addCandidateListModel:(NSDictionary *)dictT
{
    
    C_CandidateModel *myCandidate = [[C_CandidateModel alloc]init];
    @try
    {
        myCandidate.UserId = [[NSString stringWithFormat:@"%@",dictT[@"UserId"]] isNull];
        myCandidate.LinkedInId = [[NSString stringWithFormat:@"%@",dictT[@"LinkedInId"]] isNull];
        myCandidate.Email = [[NSString stringWithFormat:@"%@",dictT[@"Email"]] isNull];

        myCandidate.FirstName = [[NSString stringWithFormat:@"%@",dictT[@"FirstName"]] isNull];
        myCandidate.LastName = [[NSString stringWithFormat:@"%@",dictT[@"LastName"]] isNull];

        myCandidate.Industry = [[NSString stringWithFormat:@"%@",dictT[@"Industry"]] isNull];
        myCandidate.Industry2 = [[NSString stringWithFormat:@"%@",dictT[@"Industry2"]] isNull];

        myCandidate.LocationCity = [[NSString stringWithFormat:@"%@",dictT[@"LocationCity"]] isNull];
        myCandidate.LocationState = [[NSString stringWithFormat:@"%@",dictT[@"LocationState"]] isNull];
        myCandidate.LocationCountry = [[NSString stringWithFormat:@"%@",dictT[@"LocationCountry"]] isNull];

        myCandidate.PhotoURL = [[NSString stringWithFormat:@"%@",dictT[@"PhotoURL"]] isNull];

        myCandidate.Summary = [[NSString stringWithFormat:@"%@",dictT[@"Summary"]] isNull];

        myCandidate.ExperienceLevel = [[NSString stringWithFormat:@"%@",dictT[@"ExperienceLevel"]] isNull];

        myCandidate.IsAvailableForCall = [[NSString stringWithFormat:@"%@",dictT[@"IsAvailableForCall"]] isNull];
        
        if ([dictT[@"UserCurrentEmployer"] isKindOfClass:[NSArray class]])
        {
            NSArray *arrCurrentEmployer = dictT[@"UserCurrentEmployer"];
            if (arrCurrentEmployer.count>0)
            {
                myCandidate.EmployerName = [[NSString stringWithFormat:@"%@",arrCurrentEmployer[0][@"EmployerName"]] isNull];
            }
        }
        else
            myCandidate.EmployerName = @"";
        
        myCandidate.isShowDescription = NO;

    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    return myCandidate;
}

@end
