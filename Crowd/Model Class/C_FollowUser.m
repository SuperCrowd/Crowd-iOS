//
//  C_FollowUser.m
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_FollowUser.h"
#import "AppConstant.h"
#pragma mark -
#pragma mark - WORK HERE
@implementation C_Model_Work_Follower
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

@implementation C_FollowUser

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
    
    [encoder encodeObject:self.IsAvailableForCall forKey:@"IsAvailableForCall"];
    
    [encoder encodeObject:self.arr_WorkALL forKey:@"arr_WorkALL"];
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
        
        self.arr_WorkALL = [decoder decodeObjectForKey:@"arr_WorkALL"];
        
        self.IsAvailableForCall = [decoder decodeObjectForKey:@"IsAvailableForCall"];
        
    }
    return self;
}


+(C_FollowUser *)addNewUser:(NSDictionary *)dictUserInfo
{
    C_FollowUser *myUser = [[C_FollowUser alloc]init];
    myUser.UserId = [[NSString stringWithFormat:@"%@",dictUserInfo[@"UserId"]] isNull];
    myUser.Email = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Email"]] isNull];
    myUser.FirstName = [[NSString stringWithFormat:@"%@",dictUserInfo[@"FirstName"]] isNull];
    myUser.LastName = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LastName"]] isNull];
    myUser.LinkedInId = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LinkedInId"]] isNull];
    myUser.Token = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Token"]] isNull];
    myUser.PhotoURL = [[NSString stringWithFormat:@"%@",dictUserInfo[@"PhotoURL"]] isNull];
    myUser.Summary = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Summary"]] isNull];
    
    myUser.ExperienceLevel = [[NSString stringWithFormat:@"%@",dictUserInfo[@"ExperienceLevel"]] isNull];
    myUser.Industry = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Industry"]] isNull];
    myUser.Industry2 = [[NSString stringWithFormat:@"%@",dictUserInfo[@"Industry2"]] isNull];
    
    myUser.LocationCity = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LocationCity"]] isNull];
    myUser.LocationState = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LocationState"]] isNull];
    myUser.LocationCountry = [[NSString stringWithFormat:@"%@",dictUserInfo[@"LocationCountry"]] isNull];
    
    myUser.NumberOfUnreadMessage = [[NSString stringWithFormat:@"%@",dictUserInfo[@"NumberOfUnreadMessage"]] isNull];
    
    myUser.DateCreated = [[NSString stringWithFormat:@"%@",dictUserInfo[@"DateCreated"]] isNull];
    myUser.DateModified = [[NSString stringWithFormat:@"%@",dictUserInfo[@"DateModified"]] isNull];
        
    myUser.IsAvailableForCall = [[NSString stringWithFormat:@"%@", dictUserInfo[@"IsAvailableForCall"]]isNull];
                                                                                
    @try
    {
        /*--- Work ---*/
        myUser.arr_WorkALL = ([dictUserInfo[@"UserCurrentEmployer"] isKindOfClass:[NSArray class]])?[self getWorkUser_withDict:dictUserInfo]:[NSMutableArray array];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    return myUser;
}

+(NSMutableArray *)getWorkUser_withDict:(NSDictionary *)dictUserInfo
{
    /*--- Work ---*/
    NSMutableArray *arrWorkFinal = [[NSMutableArray alloc]init];
    @try
    {
        NSArray *arrWork = dictUserInfo[@"UserCurrentEmployer"];
        
        for (int i = 0;i<arrWork.count;i++)
        {
            NSDictionary *dictT = arrWork[i];
            C_Model_Work_Follower *myWork = [[C_Model_Work_Follower alloc]init];
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

@end
