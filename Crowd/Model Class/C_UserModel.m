//
//  C_UserModel.m
//  Crowd
//
//  Created by MAC107 on 05/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_UserModel.h"
#import "AppConstant.h"


@implementation Education
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.degree forKey:@"degree"];
    [encoder encodeObject:self.schoolName forKey:@"schoolName"];
    [encoder encodeObject:self.fieldOfStudy forKey:@"fieldOfStudy"];

    [encoder encodeObject:self.startDate_month forKey:@"startDate_month"];
    [encoder encodeObject:self.endDate_month forKey:@"endDate_month"];

    [encoder encodeObject:self.startDate_year forKey:@"startDate_year"];
    [encoder encodeObject:self.endDate_year forKey:@"endDate_year"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.degree = [decoder decodeObjectForKey:@"degree"];
        self.schoolName = [decoder decodeObjectForKey:@"schoolName"];
        self.fieldOfStudy = [decoder decodeObjectForKey:@"fieldOfStudy"];
        
        self.startDate_month = [decoder decodeObjectForKey:@"startDate_month"];
        self.endDate_month = [decoder decodeObjectForKey:@"endDate_month"];

        self.startDate_year = [decoder decodeObjectForKey:@"startDate_year"];
        self.endDate_year = [decoder decodeObjectForKey:@"endDate_year"];
    }
    return self;
}
@end

@implementation Positions

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.company_name forKey:@"company_name"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.summary forKey:@"summary"];
    [encoder encodeObject:self.isCurrent forKey:@"isCurrent"];
    [encoder encodeObject:self.startDate_year forKey:@"startDate_year"];
    [encoder encodeObject:self.startDate_month forKey:@"startDate_month"];
    [encoder encodeObject:self.endDate_month forKey:@"endDate_month"];
    [encoder encodeObject:self.endDate_year forKey:@"endDate_year"];
    [encoder encodeObject:self.location_city forKey:@"location_city"];
    [encoder encodeObject:self.location_state forKey:@"location_state"];
    [encoder encodeObject:self.location_country forKey:@"location_country"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.company_name = [decoder decodeObjectForKey:@"company_name"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.summary = [decoder decodeObjectForKey:@"summary"];
        self.isCurrent = [decoder decodeObjectForKey:@"isCurrent"];
        self.startDate_year = [decoder decodeObjectForKey:@"startDate_year"];
        self.startDate_month = [decoder decodeObjectForKey:@"startDate_month"];
        self.endDate_month = [decoder decodeObjectForKey:@"endDate_month"];
        self.endDate_year = [decoder decodeObjectForKey:@"endDate_year"];
        self.location_city = [decoder decodeObjectForKey:@"location_city"];
        self.location_state = [decoder decodeObjectForKey:@"location_state"];
        self.location_country = [decoder decodeObjectForKey:@"location_country"];

    }
    return self;
}
@end

@implementation Recommendations


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.recommender_firstName forKey:@"recommender_firstName"];
    [encoder encodeObject:self.recommender_lastName forKey:@"recommender_lastName"];
    [encoder encodeObject:self.recommendationText forKey:@"recommendationText"];
    [encoder encodeObject:self.recommendationType forKey:@"recommendationType"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.recommender_firstName = [decoder decodeObjectForKey:@"recommender_firstName"];
        self.recommender_lastName = [decoder decodeObjectForKey:@"recommender_lastName"];
        self.recommendationText = [decoder decodeObjectForKey:@"recommendationText"];
        self.recommendationType = [decoder decodeObjectForKey:@"recommendationType"];
    }
    return self;
}

@end



@implementation Skills

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.name = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}
@end


@implementation C_UserModel
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.linkedin_id forKey:@"linkedin_id"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.emailAddress forKey:@"emailAddress"];

    [encoder encodeObject:self.industry forKey:@"industry"];
    [encoder encodeObject:self.industry2 forKey:@"industry2"];
    [encoder encodeObject:self.pictureUrl forKey:@"pictureUrl"];
    [encoder encodeObject:self.summary forKey:@"summary"];
    [encoder encodeObject:self.experienceTotal forKey:@"experienceTotal"];

    [encoder encodeObject:self.location_city forKey:@"location_city"];
    [encoder encodeObject:self.location_state forKey:@"location_state"];
    [encoder encodeObject:self.location_country forKey:@"location_country"];
    [encoder encodeObject:self.location_countrycode forKey:@"location_countrycode"];
    
    [encoder encodeObject:self.arrEducationUser forKey:@"arrEducationUser"];
    [encoder encodeObject:self.arrPositionUser forKey:@"arrPositionUser"];
    [encoder encodeObject:self.arrRecommendationsUser forKey:@"arrRecommendationsUser"];
    [encoder encodeObject:self.arrSkillsUser forKey:@"arrSkillsUser"];

    [encoder encodeObject:self.imgUserPic forKey:@"imgUserPic"];
    [encoder encodeBool:self.isUpdateProfilePic forKey:@"isUpdateProfilePic"];
  
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.linkedin_id = [decoder decodeObjectForKey:@"linkedin_id"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.emailAddress = [decoder decodeObjectForKey:@"emailAddress"];
        self.industry = [decoder decodeObjectForKey:@"industry"];
        self.industry2 = [decoder decodeObjectForKey:@"industry2"];

        self.pictureUrl = [decoder decodeObjectForKey:@"pictureUrl"];
        self.summary = [decoder decodeObjectForKey:@"summary"];
        self.experienceTotal = [decoder decodeObjectForKey:@"experienceTotal"];
        
        self.location_city = [decoder decodeObjectForKey:@"location_city"];
        self.location_state = [decoder decodeObjectForKey:@"location_state"];
        self.location_country = [decoder decodeObjectForKey:@"location_country"];
        self.location_countrycode = [decoder decodeObjectForKey:@"location_countrycode"];

        self.arrEducationUser = [decoder decodeObjectForKey:@"arrEducationUser"];
        self.arrPositionUser = [decoder decodeObjectForKey:@"arrPositionUser"];
        self.arrRecommendationsUser = [decoder decodeObjectForKey:@"arrRecommendationsUser"];
        self.arrSkillsUser = [decoder decodeObjectForKey:@"arrSkillsUser"];

        self.imgUserPic = [decoder decodeObjectForKey:@"imgUserPic"];
        self.isUpdateProfilePic = [decoder decodeBoolForKey:@"isUpdateProfilePic"];
    }
    return self;
}
+(C_UserModel *)addLinkedInProfile:(NSDictionary *)dictLinkedIn
{
    C_UserModel *myModel = [[C_UserModel alloc]init];
    myModel.linkedin_id = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"id"]]isNull];
    myModel.firstName = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"firstName"]]isNull];
    myModel.lastName = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"lastName"]]isNull];
    myModel.emailAddress = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"emailAddress"]]isNull];
    myModel.industry = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"industry"]]isNull];
    myModel.industry2 = @"";
    myModel.pictureUrl = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"pictureUrls"][@"values"][0]]isNull];
    myModel.summary = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"summary"]]isNull];
    myModel.experienceTotal = @"";
    
    myModel.location_city = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"location"][@"name"]]isNull];
    myModel.location_state = @"";;
    myModel.location_country = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"location"][@"country"][@"code"]]isNull];
    myModel.location_countrycode = [[NSString stringWithFormat:@"%@",dictLinkedIn[@"location"][@"country"][@"code"]]isNull];

    myModel.imgUserPic = nil;
    myModel.isUpdateProfilePic = NO;
    /*--- Personal Try cache if error occur then dont break whole ---*/
    @try
    {
        /*--- education ---*/
        myModel.arrEducationUser = (dictLinkedIn[@"educations"])?[self getArrEducationUser_withDict:dictLinkedIn]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    @try
    {
        /*--- position ---*/
        myModel.arrPositionUser = (dictLinkedIn[@"positions"])?[self getArrPositionUser_withDict:dictLinkedIn]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    @try
    {
        /*--- recomendation ---*/
        myModel.arrRecommendationsUser = (dictLinkedIn[@"recommendationsReceived"])?[self getArrRecommendationUser_withDict:dictLinkedIn]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    @try
    {
        /*--- skills ---*/
        myModel.arrSkillsUser = (dictLinkedIn[@"skills"])?[self getArrSkillsUser_withDict:dictLinkedIn]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return myModel;
}
+(NSMutableArray *)getArrEducationUser_withDict:(NSDictionary *)dictLinkedIn
{
    NSMutableArray *arrEduTemp = [[NSMutableArray alloc]init];
    @try
    {
        NSArray *arrEducation = dictLinkedIn[@"educations"][@"values"];

        for (int i = 0;i<arrEducation.count;i++)
        {
            NSDictionary *dictT = arrEducation[i];
            Education *eduction = [[Education alloc]init];
            eduction.degree = [[NSString stringWithFormat:@"%@",dictT[@"degree"]]isNull];
            eduction.schoolName = [[NSString stringWithFormat:@"%@",dictT[@"schoolName"]]isNull];
            eduction.fieldOfStudy = [[NSString stringWithFormat:@"%@",dictT[@"fieldOfStudy"]]isNull];
            eduction.startDate_year = [[NSString stringWithFormat:@"%@",[dictT[@"startDate"][@"year"]  stringValue]]isNull];//[[dictT[@"startDate"][@"year"]  stringValue] isNull];
            eduction.endDate_year = [[NSString stringWithFormat:@"%@",[dictT[@"endDate"][@"year"]stringValue]]isNull];
            
            eduction.startDate_month = @"1";
            eduction.endDate_month = @"1";
            
            [arrEduTemp addObject:eduction];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    /*--- Education ---*/
    
    return arrEduTemp;
}
+(NSMutableArray *)getArrPositionUser_withDict:(NSDictionary *)dictLinkedIn
{
    /*--- Position ---*/
    NSMutableArray *arrPositionTemp = [[NSMutableArray alloc]init];
    @try
    {
        NSArray *arrPosition = dictLinkedIn[@"positions"][@"values"];
        
        for (int i = 0;i<arrPosition.count;i++)
        {
            NSDictionary *dictT = arrPosition[i];
            Positions *myPositions = [[Positions alloc]init];
            myPositions.company_name = [[NSString stringWithFormat:@"%@",dictT[@"company"][@"name"]]isNull];
            myPositions.title = [[NSString stringWithFormat:@"%@",dictT[@"title"]]isNull];
            myPositions.summary =[[NSString stringWithFormat:@"%@",dictT[@"summary"]]isNull] ;

            myPositions.isCurrent = [[NSString stringWithFormat:@"%@",dictT[@"isCurrent"]]isNull];

            myPositions.startDate_year = [[NSString stringWithFormat:@"%@",dictT[@"startDate"][@"year"] ]isNull];
            
            NSString *strM = [[NSString stringWithFormat:@"%@",dictT[@"startDate"][@"month"]]isNull];
            myPositions.startDate_month = ([strM isEqualToString:@""])?@"1":strM;
            
            myPositions.endDate_year = [[NSString stringWithFormat:@"%@",dictT[@"endDate"][@"year"]]isNull];
            myPositions.endDate_month = [[NSString stringWithFormat:@"%@",dictT[@"endDate"][@"month"]] isNull];
            
            myPositions.location_city = @"";;
            myPositions.location_state = @"";;
            myPositions.location_country = @"";;
            
            [arrPositionTemp addObject:myPositions];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return arrPositionTemp;
}
+(NSMutableArray *)getArrRecommendationUser_withDict:(NSDictionary *)dictLinkedIn
{
    /*--- Recommendation ---*/
    NSMutableArray *arrRecomendationTemp = [[NSMutableArray alloc]init];
    
    @try
    {
        NSArray *arrRecomment = dictLinkedIn[@"recommendationsReceived"][@"values"];
        
        for (int i = 0;i<arrRecomment.count;i++)
        {
            NSDictionary *dictT = arrRecomment[i];
            Recommendations *myRecomment = [[Recommendations alloc]init];
            myRecomment.recommender_firstName = [[NSString stringWithFormat:@"%@",dictT[@"recommender"][@"firstName"]]isNull];
            myRecomment.recommender_lastName = [[NSString stringWithFormat:@"%@",dictT[@"recommender"][@"lastName"]]isNull];
            myRecomment.recommendationText = [[NSString stringWithFormat:@"%@",dictT[@"recommendationText"]]isNull];
            myRecomment.recommendationType = [[NSString stringWithFormat:@"%@",dictT[@"recommendationType"][@"code"]]isNull];

            [arrRecomendationTemp addObject:myRecomment];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return arrRecomendationTemp;
}

+(NSMutableArray *)getArrSkillsUser_withDict:(NSDictionary *)dictLinkedIn
{
    /*--- Skills ---*/
    NSMutableArray *arrSkillsTemp = [[NSMutableArray alloc]init];
    
    @try
    {
        NSArray *arrSkills = dictLinkedIn[@"skills"][@"values"];
        
        for (int i = 0;i<arrSkills.count;i++)
        {
            NSDictionary *dictT = arrSkills[i];
            Skills *mySkills = [[Skills alloc]init];
            @try
            {
                mySkills.name = [[NSString stringWithFormat:@"%@",dictT[@"skill"][@"name"]]isNull];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            
            
            [arrSkillsTemp addObject:mySkills];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return arrSkillsTemp;
}

@end
