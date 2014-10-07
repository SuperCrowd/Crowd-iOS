//
//  C_LoggedIn_UserHandler.m
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "UserHandler_LoggedIn.h"
#import "AppConstant.h"
#import "C_UserModel.h"

#import "C_MyUser.h"


@implementation UserHandler_LoggedIn

#pragma mark - REGISTER
+(NSMutableDictionary *)getDict_To_RegisterUser
{
    NSMutableDictionary *dictR = [NSMutableDictionary dictionary];
    C_UserModel *myModel = [CommonMethods getMyUser];
    [dictR setValue:@"0" forKey:@"UserID"];
    [dictR setValue:@"" forKey:@"UserToken"];
    
    [dictR setValue:myModel.emailAddress forKey:@"Email"];
    [dictR setValue:myModel.firstName forKey:@"FirstName"];
    [dictR setValue:myModel.lastName forKey:@"LastName"];
    
    [dictR setValue:myModel.location_city forKey:@"LocationCity"];
    [dictR setValue:myModel.location_state forKey:@"LocationState"];
    [dictR setValue:myModel.location_country forKey:@"LocationCountry"];
    
    [dictR setValue:myModel.industry forKey:@"Industry"];
    [dictR setValue:myModel.industry2 forKey:@"Industry2"];

    [dictR setValue:myModel.summary forKey:@"Summary"];
    
    if (myModel.imgUserPic==nil)
    {
        [dictR setValue:@"" forKey:@"PhotoData"];
    }
    else
    {
        @try
        {
            NSString *strBase64Image = [Base64 encode:UIImagePNGRepresentation(myModel.imgUserPic)];
            [dictR setValue:strBase64Image forKey:@"PhotoData"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
    }
    [dictR setValue:myModel.linkedin_id forKey:@"LinkedInId"];
    [dictR setValue:[UserDefaults valueForKey:DEVICE_TOKEN] forKey:@"DeviceToken"];
    [dictR setValue:myModel.experienceTotal forKey:@"ExperienceLevel"];

    /*--- Skills array ---*/
    [dictR setObject:[self getSkills:myModel] forKey:@"UserSkills"];
    
    /*--- Position array ---*/
    [dictR setObject:[self getPositions:myModel] forKey:@"UserEmployments"];
    
    /*--- Recommendation array ---*/
    [dictR setObject:[self getRecommendations:myModel] forKey:@"EmploymentRecommendation"];

    /*--- Education array ---*/
    [dictR setObject:[self getEducations:myModel] forKey:@"UserEducations"];
    
    return dictR;
}

+(NSMutableArray *)getSkills:(C_UserModel *)myModel
{
    NSMutableArray *arrS = [NSMutableArray array];
    for (Skills *mySkills in myModel.arrSkillsUser)
    {
        [arrS addObject:@{@"Skill":mySkills.name}];
    }
    return arrS;
}

+(NSMutableArray *)getPositions:(C_UserModel *)myModel
{
    NSMutableArray *arrP = [NSMutableArray array];
    for (Positions *myPositions in myModel.arrPositionUser)
    {
        NSMutableDictionary *dictT = [NSMutableDictionary dictionary];
        [dictT setValue:myPositions.company_name forKey:@"EmployerName"];
        [dictT setValue:myPositions.title forKey:@"Title"];
        [dictT setValue:myPositions.location_city forKey:@"LocationCity"];
        [dictT setValue:myPositions.location_state forKey:@"LocationState"];
        [dictT setValue:myPositions.location_country forKey:@"LocationCountry"];

        @try
        {
            [dictT setValue:[myPositions.startDate_month isNull] forKey:@"StartMonth"];
            [dictT setValue:[myPositions.startDate_year isNull] forKey:@"StartYear"];
            [dictT setValue:[myPositions.endDate_month isNull] forKey:@"EndMonth"];
            [dictT setValue:[myPositions.endDate_year isNull] forKey:@"EndYear"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        
        [dictT setValue:myPositions.summary forKey:@"Summary"];
        [arrP addObject:dictT];
    }

    return arrP;
}
+(NSMutableArray *)getRecommendations:(C_UserModel *)myModel
{
    NSMutableArray *arrR = [NSMutableArray array];
    for (Recommendations *myRec in myModel.arrRecommendationsUser)
    {
        NSMutableDictionary *dictT = [NSMutableDictionary dictionary];
        @try
        {
            [dictT setValue:myRec.recommendationText forKey:@"Recommendation"];
            [dictT setValue:[NSString stringWithFormat:@"%@ %@",myRec.recommender_firstName,myRec.recommender_lastName] forKey:@"RecommenderName"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        [arrR addObject:dictT];
    }
    return arrR;
}


+(NSMutableArray *)getEducations:(C_UserModel *)myModel
{
    NSMutableArray *arrE = [NSMutableArray array];
    for (Education *myEdu in myModel.arrEducationUser)
    {
        NSMutableDictionary *dictT = [NSMutableDictionary dictionary];
        @try
        {
            [dictT setValue:myEdu.schoolName forKey:@"Name"];
            [dictT setValue:myEdu.degree forKey:@"Degree"];
            
            [dictT setValue:[myEdu.startDate_month isNull] forKey:@"StartMonth"];
            [dictT setValue:[myEdu.startDate_year isNull] forKey:@"StartYear"];
            [dictT setValue:[myEdu.endDate_month isNull] forKey:@"EndMonth"];
            [dictT setValue:[myEdu.endDate_year isNull] forKey:@"EndYear"];

            /*--- add Course ---*/
            if (myEdu.fieldOfStudy.length > 0) {
                NSArray *arrCource = [myEdu.fieldOfStudy componentsSeparatedByString:@","];
                NSMutableArray *arrTemp = [NSMutableArray array];
                for (NSString *strC  in arrCource)
                {
                    @try
                    {
                        [arrTemp addObject:@{@"Course":strC}];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@",exception.description);
                    }
                    @finally {
                    }
                }
                
                [dictT setObject:arrTemp forKey:@"UserEducationCourse"];
            }
            else
            {
                [dictT setObject:[NSMutableArray array] forKey:@"UserEducationCourse"];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        [arrE addObject:dictT];
    }
    return arrE;
}



#pragma mark - Get Profile + Save profile
+(C_MyUser *)getMyUser_LoggedIN
{
    @try
    {
        NSData *myDecodedObject = [UserDefaults objectForKey:APP_USER_INFO];
        C_MyUser *myUser = [NSKeyedUnarchiver unarchiveObjectWithData:myDecodedObject];
        return myUser;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        return nil;
    }
    @finally {
    }
    return nil;
}
+(void)saveMyUser_LoggedIN:(C_MyUser *)myUser
{
    @try
    {
        NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:myUser];
        [UserDefaults setObject:myEncodedObject forKey:APP_USER_INFO];
        [UserDefaults synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}





/*----------------------------------------------------------------------------------------------------------*/
+(NSMutableDictionary *)getDict_To_Update_withProfileModel:(C_MyUser *)myModel
{
    NSMutableDictionary *dictR = [NSMutableDictionary dictionary];
    [dictR setValue:myModel.UserId forKey:@"UserID"];
    [dictR setValue:myModel.Token forKey:@"UserToken"];
    
    [dictR setValue:myModel.Email forKey:@"Email"];
    [dictR setValue:myModel.FirstName forKey:@"FirstName"];
    [dictR setValue:myModel.LastName forKey:@"LastName"];
    
    [dictR setValue:myModel.LocationCity forKey:@"LocationCity"];
    [dictR setValue:myModel.LocationState forKey:@"LocationState"];
    [dictR setValue:myModel.LocationCountry forKey:@"LocationCountry"];
    
    [dictR setValue:myModel.Industry forKey:@"Industry"];
    [dictR setValue:myModel.Industry2 forKey:@"Industry2"];
    
    [dictR setValue:myModel.Summary forKey:@"Summary"];
    if (imgProfilePictureToUpdate!=nil)
    {
        NSString *strBase64Image = [Base64 encode:UIImagePNGRepresentation(imgProfilePictureToUpdate)];
        [dictR setValue:strBase64Image forKey:@"PhotoData"];
    }
    else
    {
        @try
        {
            UIImage *img = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,myModel.PhotoURL]];
            if (img) {
                NSString *strBase64Image = [Base64 encode:UIImagePNGRepresentation(img)];
                [dictR setValue:strBase64Image forKey:@"PhotoData"];
            }
            else
                [dictR setValue:@"" forKey:@"PhotoData"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
    }
    
    [dictR setValue:myModel.LinkedInId forKey:@"LinkedInId"];
    [dictR setValue:[UserDefaults valueForKey:DEVICE_TOKEN] forKey:@"DeviceToken"];
    [dictR setValue:myModel.ExperienceLevel forKey:@"ExperienceLevel"];
    
    /*--- Skills array ---*/
    [dictR setObject:[self updated_Skills:myModel] forKey:@"UserSkills"];
    
    /*--- Position array ---*/
    [dictR setObject:[self updated_Work:myModel] forKey:@"UserEmployments"];
    
    /*--- Recommendation array ---*/
    [dictR setObject:[self updated_Recommendations:myModel] forKey:@"EmploymentRecommendation"];
    
    /*--- Education array ---*/
    [dictR setObject:[self updated_Educations:myModel] forKey:@"UserEducations"];
    
    return dictR;
}

+(NSMutableArray *)updated_Skills:(C_MyUser *)myModel
{
    NSMutableArray *arrS = [NSMutableArray array];
    for (C_Model_Skills *mySkills in myModel.arr_SkillsALL)
    {
        [arrS addObject:@{@"Skill":mySkills.Skills}];
    }
    return arrS;
}

+(NSMutableArray *)updated_Work:(C_MyUser *)myModel
{
    NSMutableArray *arrP = [NSMutableArray array];
    for (C_Model_Work *myWork in myModel.arr_WorkALL)
    {
        NSMutableDictionary *dictT = [NSMutableDictionary dictionary];
        [dictT setValue:myWork.EmployerName forKey:@"EmployerName"];
        [dictT setValue:myWork.Title forKey:@"Title"];
        [dictT setValue:myWork.LocationCity forKey:@"LocationCity"];
        [dictT setValue:myWork.LocationState forKey:@"LocationState"];
        [dictT setValue:myWork.LocationCountry forKey:@"LocationCountry"];
        
        @try
        {
            [dictT setValue:[myWork.StartMonth isNull] forKey:@"StartMonth"];
            [dictT setValue:[myWork.StartYear isNull] forKey:@"StartYear"];
            [dictT setValue:[myWork.EndMonth isNull] forKey:@"EndMonth"];
            [dictT setValue:[myWork.EndYear isNull] forKey:@"EndYear"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        
        [dictT setValue:myWork.Summary forKey:@"Summary"];
        [arrP addObject:dictT];
    }
    
    return arrP;
}
+(NSMutableArray *)updated_Recommendations:(C_MyUser *)myModel
{
    NSMutableArray *arrR = [NSMutableArray array];
    for (C_Model_Recommendation *myRec in myModel.arr_RecommendationALL)
    {
        NSMutableDictionary *dictT = [NSMutableDictionary dictionary];
        @try
        {
            [dictT setValue:myRec.Recommendation forKey:@"Recommendation"];
            [dictT setValue:[NSString stringWithFormat:@"%@",myRec.RecommenderName] forKey:@"RecommenderName"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        [arrR addObject:dictT];
    }
    return arrR;
}


+(NSMutableArray *)updated_Educations:(C_MyUser *)myModel
{
    NSMutableArray *arrE = [NSMutableArray array];
    for (C_Model_Education *myEdu in myModel.arr_EducationALL)
    {
        NSMutableDictionary *dictT = [NSMutableDictionary dictionary];
        @try
        {
            [dictT setValue:myEdu.Name forKey:@"Name"];
            [dictT setValue:myEdu.Degree forKey:@"Degree"];
            
            [dictT setValue:[myEdu.StartMonth isNull] forKey:@"StartMonth"];
            [dictT setValue:[myEdu.StartYear isNull] forKey:@"StartYear"];
            [dictT setValue:[myEdu.EndMonth isNull] forKey:@"EndMonth"];
            [dictT setValue:[myEdu.EndYear isNull] forKey:@"EndYear"];
            
            /*--- add Course ---*/
            NSMutableArray *arrTemp = [NSMutableArray array];
            for (C_Model_Courses *myCourse  in myEdu.arrCourses)
            {
                @try
                {
                    [arrTemp addObject:@{@"Course":myCourse.Course}];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                }
                @finally {
                }
            }
            
            [dictT setObject:arrTemp forKey:@"UserEducationCourse"];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        [arrE addObject:dictT];
    }
    return arrE;
}

@end
