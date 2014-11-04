//
//  C_MyUser.m
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MyUser.h"
#import "AppConstant.h"
/*---------------------------------------------------------------------------------------------------*/
#pragma mark - EDUCATION HERE
@implementation C_Model_Courses
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.courseID forKey:@"courseID"];
    [encoder encodeObject:self.Course forKey:@"Course"];
    [encoder encodeObject:self.DateCreated forKey:@"DateCreated"];
    [encoder encodeObject:self.EducationID forKey:@"EducationID"];

}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.courseID = [decoder decodeObjectForKey:@"courseID"];
        self.Course = [decoder decodeObjectForKey:@"Course"];
        self.DateCreated = [decoder decodeObjectForKey:@"DateCreated"];
        self.EducationID = [decoder decodeObjectForKey:@"EducationID"];

    }
    return self;
}
@end

@implementation  C_Model_Education
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.educationID forKey:@"educationID"];
    [encoder encodeObject:self.Name forKey:@"Name"];
    [encoder encodeObject:self.Degree forKey:@"Degree"];

    [encoder encodeObject:self.StartMonth forKey:@"StartMonth"];
    [encoder encodeObject:self.StartYear forKey:@"StartYear"];
    [encoder encodeObject:self.EndMonth forKey:@"EndMonth"];
    [encoder encodeObject:self.EndYear forKey:@"EndYear"];

    [encoder encodeObject:self.DateCreated forKey:@"DateCreated"];
    [encoder encodeObject:self.DateModified forKey:@"DateModified"];

    [encoder encodeObject:self.arrCourses forKey:@"arrCourses"];

}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.educationID = [decoder decodeObjectForKey:@"educationID"];
        self.Name = [decoder decodeObjectForKey:@"Name"];
        self.Degree = [decoder decodeObjectForKey:@"Degree"];

        self.StartMonth = [decoder decodeObjectForKey:@"StartMonth"];
        self.StartYear = [decoder decodeObjectForKey:@"StartYear"];
        self.EndMonth = [decoder decodeObjectForKey:@"EndMonth"];
        self.EndYear = [decoder decodeObjectForKey:@"EndYear"];

        self.DateCreated = [decoder decodeObjectForKey:@"DateCreated"];
        self.DateModified = [decoder decodeObjectForKey:@"DateModified"];

        self.arrCourses = [decoder decodeObjectForKey:@"arrCourses"];

    }
    return self;
}
@end


/*---------------------------------------------------------------------------------------------------*/
#pragma mark - 
#pragma mark - WORK HERE
@implementation C_Model_Work
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.EmployerName forKey:@"EmployerName"];
    [encoder encodeObject:self.Title forKey:@"Title"];
    [encoder encodeObject:self.workID forKey:@"workID"];
    [encoder encodeObject:self.Summary forKey:@"Summary"];

    [encoder encodeObject:self.LocationCity forKey:@"LocationCity"];
    [encoder encodeObject:self.LocationState forKey:@"LocationState"];
    [encoder encodeObject:self.LocationCountry forKey:@"LocationCountry"];

    [encoder encodeObject:self.StartMonth forKey:@"StartMonth"];
    [encoder encodeObject:self.StartYear forKey:@"StartYear"];
    [encoder encodeObject:self.EndMonth forKey:@"EndMonth"];
    [encoder encodeObject:self.EndYear forKey:@"EndYear"];

    [encoder encodeObject:self.DateCreated forKey:@"DateCreated"];
    [encoder encodeObject:self.DateModified forKey:@"DateModified"];

}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.EmployerName = [decoder decodeObjectForKey:@"EmployerName"];
        self.Title = [decoder decodeObjectForKey:@"Title"];
        self.workID = [decoder decodeObjectForKey:@"workID"];
        self.Summary = [decoder decodeObjectForKey:@"Summary"];

        self.LocationCity = [decoder decodeObjectForKey:@"LocationCity"];
        self.LocationState = [decoder decodeObjectForKey:@"LocationState"];
        self.LocationCountry = [decoder decodeObjectForKey:@"LocationCountry"];

        self.StartMonth = [decoder decodeObjectForKey:@"StartMonth"];
        self.StartYear = [decoder decodeObjectForKey:@"StartYear"];
        self.EndMonth = [decoder decodeObjectForKey:@"EndMonth"];
        self.EndYear = [decoder decodeObjectForKey:@"EndYear"];

        self.DateCreated = [decoder decodeObjectForKey:@"DateCreated"];
        self.DateModified = [decoder decodeObjectForKey:@"DateModified"];
    }
    return self;
}
@end


/*---------------------------------------------------------------------------------------------------*/
#pragma mark -
#pragma mark - SKILLS HERE
@implementation C_Model_Skills
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.skillsID forKey:@"skillsID"];
    [encoder encodeObject:self.Skills forKey:@"Skills"];
    [encoder encodeObject:self.DateCreated forKey:@"DateCreated"];

}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.skillsID = [decoder decodeObjectForKey:@"skillsID"];
        self.Skills = [decoder decodeObjectForKey:@"Skills"];
        self.DateCreated = [decoder decodeObjectForKey:@"DateCreated"];
    }
    return self;
}
@end
/*---------------------------------------------------------------------------------------------------*/

#pragma mark -
#pragma mark - RECOMMENDATION HERE
@implementation C_Model_Recommendation
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.recommendID forKey:@"recommendID"];
    [encoder encodeObject:self.Recommendation forKey:@"Recommendation"];
    [encoder encodeObject:self.RecommenderName forKey:@"RecommenderName"];
    [encoder encodeObject:self.DateCreated forKey:@"DateCreated"];

}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.recommendID = [decoder decodeObjectForKey:@"recommendID"];
        self.Recommendation = [decoder decodeObjectForKey:@"Recommendation"];
        self.RecommenderName = [decoder decodeObjectForKey:@"RecommenderName"];
        self.DateCreated = [decoder decodeObjectForKey:@"DateCreated"];
    }
    return self;
}
@end



/*---------------------------------------------------------------------------------------------------*/
#pragma mark -
#pragma mark - FINAL MODEL HERE
@implementation C_MyUser
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.UserId forKey:@"UserId"];
    [encoder encodeObject:self.Email forKey:@"Email"];
    [encoder encodeObject:self.FirstName forKey:@"FirstName"];
    [encoder encodeObject:self.LastName forKey:@"LastName"];
    [encoder encodeObject:self.LinkedInId forKey:@"LinkedInId"];
    [encoder encodeObject:self.Token forKey:@"Token"];
    [encoder encodeObject:self.PhotoURL forKey:@"PhotoURL"];
    [encoder encodeObject:self.Summary forKey:@"Summary"];

    
    [encoder encodeObject:self.ExperienceLevel forKey:@"ExperienceLevel"];
    [encoder encodeObject:self.Industry forKey:@"Industry"];
    [encoder encodeObject:self.Industry2 forKey:@"Industry2"];

    [encoder encodeObject:self.LocationCity forKey:@"LocationCity"];
    [encoder encodeObject:self.LocationState forKey:@"LocationState"];
    [encoder encodeObject:self.LocationCountry forKey:@"LocationCountry"];

    [encoder encodeObject:self.NumberOfUnreadMessage forKey:@"NumberOfUnreadMessage"];
    [encoder encodeObject:self.DateCreated forKey:@"DateCreated"];
    [encoder encodeObject:self.DateModified forKey:@"DateModified"];
    
    [encoder encodeObject:self.arr_EducationALL forKey:@"arr_EducationALL"];
    [encoder encodeObject:self.arr_WorkALL forKey:@"arr_WorkALL"];
    [encoder encodeObject:self.arr_RecommendationALL forKey:@"arr_RecommendationALL"];
    [encoder encodeObject:self.arr_SkillsALL forKey:@"arr_SkillsALL"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.UserId = [decoder decodeObjectForKey:@"UserId"];
        self.Email = [decoder decodeObjectForKey:@"Email"];
        self.FirstName = [decoder decodeObjectForKey:@"FirstName"];
        self.LastName = [decoder decodeObjectForKey:@"LastName"];
        self.LinkedInId = [decoder decodeObjectForKey:@"LinkedInId"];
        self.Token = [decoder decodeObjectForKey:@"Token"];
        self.PhotoURL = [decoder decodeObjectForKey:@"PhotoURL"];
        self.Summary = [decoder decodeObjectForKey:@"Summary"];

        self.ExperienceLevel = [decoder decodeObjectForKey:@"ExperienceLevel"];
        self.Industry = [decoder decodeObjectForKey:@"Industry"];
        self.Industry2 = [decoder decodeObjectForKey:@"Industry2"];

        self.LocationCity = [decoder decodeObjectForKey:@"LocationCity"];
        self.LocationState = [decoder decodeObjectForKey:@"LocationState"];
        self.LocationCountry = [decoder decodeObjectForKey:@"LocationCountry"];

        self.NumberOfUnreadMessage = [decoder decodeObjectForKey:@"NumberOfUnreadMessage"];
        self.DateCreated = [decoder decodeObjectForKey:@"DateCreated"];
        self.DateModified = [decoder decodeObjectForKey:@"DateModified"];

        self.arr_EducationALL = [decoder decodeObjectForKey:@"arr_EducationALL"];
        self.arr_WorkALL = [decoder decodeObjectForKey:@"arr_WorkALL"];
        self.arr_RecommendationALL = [decoder decodeObjectForKey:@"arr_RecommendationALL"];
        self.arr_SkillsALL = [decoder decodeObjectForKey:@"arr_SkillsALL"];

    }
    return self;
}

#pragma mark - ADD USER
+(C_MyUser *)addNewUser:(NSDictionary *)dictTTTT
{
    NSDictionary *dictUserInfo = dictTTTT[@"GetUserResult"];
    C_MyUser *myUser = [[C_MyUser alloc]init];

    @try
    {
        myUser.UserId = [[NSString stringWithFormat:@"%@",dictUserInfo[@"UserId"]] isNull];
        myUser.Email = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Email"]] isNull];
        myUser.FirstName = [[NSString stringWithFormat:@"%@",dictUserInfo[@"FirstName"]] isNull];
        myUser.LastName = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LastName"]] isNull];
        myUser.LinkedInId = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LinkedInId"]] isNull];
        myUser.Token = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Token"]] isNull];
        myUser.PhotoURL = [[NSString stringWithFormat:@"%@",dictUserInfo[@"PhotoURL"]] isNull];
        myUser.Summary = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Summary"]] isNull];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    @try
    {
        myUser.ExperienceLevel = [[NSString stringWithFormat:@"%@",dictUserInfo[@"ExperienceLevel"]] isNull];
        myUser.Industry = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Industry"]] isNull];
        myUser.Industry2 = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Industry2"]] isNull];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    @try
    {
        myUser.LocationCity = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LocationCity"]] isNull];
        myUser.LocationState = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LocationState"]] isNull];
        myUser.LocationCountry = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LocationCountry"]] isNull];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    @try
    {
        myUser.NumberOfUnreadMessage = [[NSString stringWithFormat:@"%@",dictUserInfo[@"NumberOfUnreadMessage"]] isNull];
        
        myUser.DateCreated = [[NSString stringWithFormat:@"%@",dictUserInfo[@"DateCreated"]] isNull];
        myUser.DateModified = [[NSString stringWithFormat:@"%@",dictUserInfo[@"DateModified"]] isNull];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
   
    @try
    {
        /*--- education ---*/
        myUser.arr_EducationALL = ([dictTTTT[@"GetUserEducationWithCourseResult"] isKindOfClass:[NSArray class]])?[self getEducationUser_withDict:dictTTTT]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    @try
    {
        /*--- Work ---*/
        myUser.arr_WorkALL = ([dictTTTT[@"GetUserEmploymentResult"] isKindOfClass:[NSArray class]])?[self getWorkUser_withDict:dictTTTT]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    
    @try
    {
        /*--- Recommendation ---*/
        myUser.arr_RecommendationALL =  ([dictTTTT[@"GetUserEmploymentRecommendationResult"] isKindOfClass:[NSArray class]])?[self getRecommendationUser_withDict:dictTTTT]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    @try
    {
        /*--- Skills ---*/
        myUser.arr_SkillsALL =  ([dictTTTT[@"GetUserSkillResult"] isKindOfClass:[NSArray class]])?[self getSkillsUser_withDict:dictTTTT]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }

    return myUser;
}


+(NSMutableArray *)getEducationUser_withDict:(NSDictionary *)dictUserInfo
{
    /*--- Education ---*/
    NSMutableArray *arrEduTemp = [[NSMutableArray alloc]init];
    @try
    {
        NSArray *arrEducation = dictUserInfo[@"GetUserEducationWithCourseResult"];
        
        for (int i = 0;i<arrEducation.count;i++)
        {
            NSDictionary *dictT = arrEducation[i];
            C_Model_Education *eduction = [[C_Model_Education alloc]init];
            
            @try
            {
                eduction.educationID = [[NSString stringWithFormat:@"%@",dictT[@"ID"]]isNull];
                eduction.Name = [[NSString stringWithFormat:@"%@",dictT[@"Name"]]isNull];
                eduction.Degree = [[NSString stringWithFormat:@"%@",dictT[@"Degree"]]isNull];
                
                @try
                {
                    eduction.StartMonth = [[NSString stringWithFormat:@"%@",dictT[@"StartMonth"]] isNull];
                    eduction.StartYear = [[NSString stringWithFormat:@"%@",dictT[@"StartYear"]] isNull];
                    eduction.EndMonth = [[NSString stringWithFormat:@"%@",dictT[@"EndMonth"]] isNull];
                    eduction.EndYear = [[NSString stringWithFormat:@"%@",dictT[@"EndYear"]] isNull];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                }
                eduction.DateCreated = [[NSString stringWithFormat:@"%@",dictT[@"DateCreated"]] isNull];
                eduction.DateModified = [[NSString stringWithFormat:@"%@",dictT[@"DateModified"]] isNull];

                NSArray *arrCourse = arrEducation[i][@"GetUserEducationCourseResult"];
                NSMutableArray *arrC = [[NSMutableArray alloc]init];
                for (NSDictionary *dictCource in arrCourse)
                {
                    C_Model_Courses *myCourse = [[C_Model_Courses alloc]init];
                    
                    @try
                    {
                        myCourse.courseID = [[NSString stringWithFormat:@"%@",dictCource[@"ID"]]isNull];
                        myCourse.Course = [[NSString stringWithFormat:@"%@",dictCource[@"Course"]]isNull];
                        myCourse.DateCreated = [[NSString stringWithFormat:@"%@",dictCource[@"DateCreated"]]isNull];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@",exception.description);
                    }
                    @finally {
                    }
                    [arrC addObject:myCourse];
                }
                
                eduction.arrCourses = arrC;
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            
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






+(NSMutableArray *)getWorkUser_withDict:(NSDictionary *)dictUserInfo
{
    /*--- Work ---*/
    NSMutableArray *arrWorkFinal = [[NSMutableArray alloc]init];
    @try
    {
        NSArray *arrWork = dictUserInfo[@"GetUserEmploymentResult"];
        
        for (int i = 0;i<arrWork.count;i++)
        {
            NSDictionary *dictT = arrWork[i];
            C_Model_Work *myWork = [[C_Model_Work alloc]init];
            @try
            {
                myWork.EmployerName = [[NSString stringWithFormat:@"%@",dictT[@"EmployerName"]]isNull];
                myWork.Title = [[NSString stringWithFormat:@"%@",dictT[@"Title"]]isNull];
                myWork.workID = [[NSString stringWithFormat:@"%@",dictT[@"ID"]]isNull];
                myWork.Summary = [[NSString stringWithFormat:@"%@",dictT[@"Summary"]]isNull];
                
                myWork.LocationCity = [[NSString stringWithFormat:@"%@",dictT[@"LocationCity"]]isNull];
                myWork.LocationState = [[NSString stringWithFormat:@"%@",dictT[@"LocationState"]]isNull];
                myWork.LocationCountry = [[NSString stringWithFormat:@"%@",dictT[@"LocationCountry"]]isNull];
                
                @try
                {
                    myWork.StartMonth = [[NSString stringWithFormat:@"%@",dictT[@"StartMonth"]]isNull];
                    myWork.StartYear = [[NSString stringWithFormat:@"%@",dictT[@"StartYear"]]isNull];
                    myWork.EndMonth = [[NSString stringWithFormat:@"%@",dictT[@"EndMonth"]]isNull];
                    myWork.EndYear = [[NSString stringWithFormat:@"%@",dictT[@"EndYear"]]isNull];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                }
                
                
                myWork.DateCreated = [[NSString stringWithFormat:@"%@",dictT[@"DateCreated"]]isNull];
                myWork.DateModified = [[NSString stringWithFormat:@"%@",dictT[@"DateModified"]]isNull];

            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            [arrWorkFinal addObject:myWork];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return arrWorkFinal;
}



+(NSMutableArray *)getRecommendationUser_withDict:(NSDictionary *)dictUserInfo
{
    /*--- Recommendation ---*/
    NSMutableArray *arrRecomendationTemp = [[NSMutableArray alloc]init];
    
    @try
    {
        NSArray *arrRecomment = dictUserInfo[@"GetUserEmploymentRecommendationResult"];
        
        for (int i = 0;i<arrRecomment.count;i++)
        {
            NSDictionary *dictT = arrRecomment[i];
            C_Model_Recommendation *myRecomment = [[C_Model_Recommendation alloc]init];
            @try
            {
                myRecomment.recommendID = [[NSString stringWithFormat:@"%@",dictT[@"ID"]]isNull];
                myRecomment.Recommendation = [[NSString stringWithFormat:@"%@",dictT[@"Recommendation"]]isNull];
                myRecomment.RecommenderName = [[NSString stringWithFormat:@"%@",dictT[@"RecommenderName"]]isNull];
                myRecomment.DateCreated = [[NSString stringWithFormat:@"%@",dictT[@"DateCreated"]]isNull];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
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

+(NSMutableArray *)getSkillsUser_withDict:(NSDictionary *)dictUserInfo
{
    /*--- Skills ---*/
    NSMutableArray *arrSkillsTemp = [[NSMutableArray alloc]init];
    @try
    {
        NSArray *arrSkills = dictUserInfo[@"GetUserSkillResult"];
        
        for (int i = 0;i<arrSkills.count;i++)
        {
            NSDictionary *dictT = arrSkills[i];
            C_Model_Skills *mySkills = [[C_Model_Skills alloc]init];
            @try
            {
                mySkills.skillsID = [[NSString stringWithFormat:@"%@",dictT[@"ID"]]isNull];
                mySkills.Skills = [[NSString stringWithFormat:@"%@",dictT[@"Skills"]]isNull];
                mySkills.DateCreated = [[NSString stringWithFormat:@"%@",dictT[@"DateCreated"]]isNull];
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
