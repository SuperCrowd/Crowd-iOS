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
/*
 "UserID": "0",
 "UserToken": "",
 "Email": "chintan@crowd.com",
 "FirstName": "Chintan",
 "LastName": "Ramani",
 "LocationCity": "Ahmedabad",
 "LocationState": "Gujarat",
 "LocationCountry": "India",
 "Industry": "Computers",
 "Industry2": "Industry2",
 "Summary": "Chintan Ramani Summary",
 "PhotoData": "",
 "LinkedInId": "Chintan",
 "DeviceToken": "Simulator",
 "ExperienceLevel": "1",
 */
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
/*
 "UserSkills": [
 {
 "Skill": "iOS"
 },
 {"Skill": ".NET"},{"Skill": "SQL"}],
 
 "UserEmployments": [
 {
 "EmployerName": "Tatvasoft",
 "Title": "Sr. Software Engg",
 "LocationCity": "Ahmedabad",
 "LocationState": "Gujarat",
 "LocationCountry": "India",
 "StartMonth": "11",
 "StartYear": "2013",
 "EndMonth": "",
 "EndYear": "",
 "Summary": "Tatvasoft Summary Here",
 }
 ],
 */
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
//        [dictT setObject:[self getRecommendations:myModel] forKey:@"EmploymentRecommendation"];

        
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
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        [arrE addObject:dictT];
    }
    return arrE;
}
/*
 {
 "UserID": "0",
 "UserToken": "",
 "Email": "chintan@crowd.com",
 "FirstName": "Chintan",
 "LastName": "Ramani",
 "LocationCity": "Ahmedabad",
 "LocationState": "Gujarat",
 "LocationCountry": "India",
 "Industry": "Computers",
 "Industry2": "Industry2",
 "Summary": "Chintan Ramani Summary",
 "PhotoData": "",
 "LinkedInId": "Chintan",
 "DeviceToken": "Simulator",
 "ExperienceLevel": "1",
 
 
 "UserSkills": [
 {
 "Skill": "iOS"
 },
 {"Skill": ".NET"},{"Skill": "SQL"}],
 
 "UserEmployments": [
 {
 "EmployerName": "Tatvasoft",
 "Title": "Sr. Software Engg",
 "LocationCity": "Ahmedabad",
 "LocationState": "Gujarat",
 "LocationCountry": "India",
 "StartMonth": "11",
 "StartYear": "2013",
 "EndMonth": "",
 "EndYear": "",
 "Summary": "Tatvasoft Summary Here",
  }
 ],
 
 "EmploymentRecommendation": [
 {
 "Recommendation": "Recommendation1",
 "RecommenderName": "RecommenderName1"
 }
 ]
 
 
 "UserEducations": [
 {
 "Name": "College",
 "Degree": "B.E.",
 "StartMonth": "4",
 "StartYear": "2009",
 "EndMonth": "5",
 "EndYear": "2013",
 "UserEducationCourse": [
 {
 "Course": "Fiber Optics"
 }
 ]
 }
 ]
 }
 */

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
@end
