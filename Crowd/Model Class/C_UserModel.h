//
//  C_UserModel.h
//  Crowd
//
//  Created by MAC107 on 05/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 educations =     {
 values = (
 {
 degree = "Bachelor's Degree";
 endDate =                 {
 year = 2014;
 };
 id = 238235053;
 notes = "Bechlor Description.";
 schoolName = "IIT ahmedabad";
 startDate =                 {
 year = 2011;
 };
 })}
 */

#pragma mark - Education
/*-------------- EDUCATION -----------------*/
@interface Education : NSObject
@property NSString *degree;
@property NSString *schoolName;
@property NSString *fieldOfStudy;

@property NSString *startDate_month;
@property NSString *startDate_year;

@property NSString *endDate_month;
@property NSString *endDate_year;


@end

/*-------------- EDUCATION -----------------*/


/*
 recommendationsReceived =     {
 "_total" = 1;
 values =         (
     {
         id = 552464351;
         recommendationText = Reccomenddddddd;
         recommendationType =                 {
         code = colleague;
         };
         recommender =                 {
         firstName = test;
         id = FjBQAqtLDs;
         lastName = soft;
         };
     }
 );
 };
 */


/*-------------- Recommendations -----------------*/
@interface Recommendations : NSObject
@property NSString *recommender_firstName;
@property NSString *recommender_lastName;

@property NSString *recommendationText;
@property NSString *recommendationType;
@end

/*-------------- Recommendations -----------------*/


/*
 positions =     {
values = (
     {
         company =                 {
         id = 128592;
         
         industry = "Computer Software";
         name = TatvaSoft;
         size = "201-500 employees";
         type = Partnership;
         };
         id = 579319681;
         isCurrent = 1;
         startDate =                 {
         month = 6;
         year = 2014;
         };
         title = "Project Manager";
     }
 )
 }
 */
#pragma mark - Position

/*-------------- positions -----------------*/
@interface Positions : NSObject
@property NSString *company_name;
@property NSString *title;
@property NSString *isCurrent;
@property NSString *startDate_month;
@property NSString *startDate_year;
@property NSString *endDate_month;
@property NSString *endDate_year;
@property NSString *summary;
@property NSString *location_city;
@property NSString *location_state;
@property NSString *location_country;
@end

/*-------------- positions -----------------*/
/*
skills =     {
    values =  (
  {
      id = 3;
      skill =                 {
          name = "Software Project Management";
      };
  },
 )
 }
 */
#pragma mark - Skills
/*-------------- Skills -----------------*/
@interface Skills : NSObject
@property NSString *name;

@end
/*-------------- Skills -----------------*/


@interface C_UserModel : NSObject
@property NSString *linkedin_id;
@property NSString *firstName;
@property NSString *lastName;

@property NSString *emailAddress;
@property NSString *experienceTotal;

@property NSString *industry;
@property NSString *industry2;

@property NSString *location_city;
@property NSString *location_state;
@property NSString *location_country;
@property NSString *location_countrycode;
@property NSString *pictureUrl;
@property NSString *summary;

@property NSMutableArray *arrEducationUser;
@property NSMutableArray *arrPositionUser;
@property NSMutableArray *arrSkillsUser;
@property NSMutableArray *arrRecommendationsUser;
@property UIImage *imgUserPic;
@property BOOL isUpdateProfilePic;


+(C_UserModel *)addLinkedInProfile:(NSDictionary *)dictLinkedIn;
@end
/*
 firstName = Tatva;
 id = "Su6w-O9Cnp";
 industry = "Computer Software";
 lastName = Second;
 location =     {
 name = "Ahmedabad Area, India";
 };
 */



