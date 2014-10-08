//
//  Update_PostJob.m
//  Crowd
//
//  Created by MAC107 on 08/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "Update_PostJob.h"
#import "AppConstant.h"
#import "C_PostJobModel.h"
@interface Update_PostJob()
{
    JSONParser *parser;
    SuccessBlock mySuccessblock;
    FailBlock myFailblock;
    
}
@end
@implementation Update_PostJob
-(void)update_JobPost_with_withSuccessBlock:(SuccessBlock)successBlock withFailBlock:(FailBlock)failBlock
{
    //    NSLog(@"%@",[UserHandler_LoggedIn getDict_To_RegisterUser]);
    mySuccessblock = successBlock;
    myFailblock = failBlock;
    @try
    {
        showHUD_with_Title(@"Job updating");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"%@",[self getDictParam]);
            parser = [[JSONParser alloc]initWith_withURL:Web_POST_JOB withParam:[self getDictParam] withData:nil withType:kURLPost withSelector:@selector(getDataDone:) withObject:self];
        });
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        hideHUD;
        myFailblock(@"Please Try Again");
    }
    @finally {
    }
    
}
-(void)getDataDone:(id)objResponse
{
    NSLog(@"%@",objResponse);
    if (![objResponse isKindOfClass:[NSDictionary class]])
    {
        hideHUD;
        myFailblock(@"Please Try Again");
        return;
    }
    
    if ([objResponse objectForKey:kURLFail])
    {
        hideHUD;
        myFailblock([objResponse objectForKey:kURLFail]);
    }
    else if([objResponse objectForKey:@"AddEditJobResult"])
    {
        /*--- Save data here ---*/
        BOOL isNewJobPostSuccess = [[objResponse valueForKeyPath:@"AddEditJobResult.ResultStatus.Status"] boolValue];
        if (isNewJobPostSuccess)
        {
            
            //hideHUD;
            //[self updateModelList];
            showHUD_with_Success(@"Job Updated Successfully");
            mySuccessblock();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                hideHUD;
            });
            
        }
        else
        {
            hideHUD;
            NSString *str = [objResponse valueForKeyPath:@"AddEditJobResult.ResultStatus.StatusMessage"];
            myFailblock(str);
        }
    }
    else
    {
        hideHUD;
        myFailblock([objResponse objectForKey:kURLFail]);
    }
}

#pragma mark - Get Updated Dictionary
-(NSDictionary *)getDictParam
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userInfoGlobal.UserId forKey:@"UserID"];
    [dict setValue:userInfoGlobal.Token forKey:@"UserToken"];
    [dict setValue:postJob_ModelClass.JobID forKey:@"JobID"];
    [dict setValue:postJob_ModelClass.Title forKey:@"Title"];
    [dict setValue:postJob_ModelClass.Company forKey:@"Company"];
    [dict setValue:postJob_ModelClass.Industry forKey:@"Industry"];
    [dict setValue:postJob_ModelClass.Industry2 forKey:@"Industry2"];
    
    [dict setValue:postJob_ModelClass.LocationCity forKey:@"LocationCity"];
    [dict setValue:postJob_ModelClass.LocationState forKey:@"LocationState"];
    [dict setValue:postJob_ModelClass.LocationCountry forKey:@"LocationCountry"];
    
    [dict setValue:postJob_ModelClass.ExperienceLevel forKey:@"ExperienceLevel"];
    [dict setValue:postJob_ModelClass.Responsibilities forKey:@"Responsibilities"];
    [dict setValue:postJob_ModelClass.URL forKey:@"JobURL"];
    
    [dict setValue:postJob_ModelClass.EmployerIntroduction forKey:@"EmployerIntroduction"];
    [dict setValue:postJob_ModelClass.Qualifications forKey:@"Qualifications"];
    
    [dict setObject:postJob_ModelClass.arrSkills forKey:@"Skills"];
    return dict;
}
//-(void)updateModelList
//{
//    _obj_JobListModel.Title = postJob_ModelClass.Title;
//    _obj_JobListModel.Company = postJob_ModelClass.Company;
//    _obj_JobListModel.Industry = postJob_ModelClass.Industry;
//    _obj_JobListModel.Industry2 = postJob_ModelClass.Industry2;
//    
//    _obj_JobListModel.LocationCity = postJob_ModelClass.LocationCity;
//    _obj_JobListModel.LocationState = postJob_ModelClass.LocationState;
//    _obj_JobListModel.LocationCountry = postJob_ModelClass.LocationCountry;
//    
//    _obj_JobListModel.ExperienceLevel = postJob_ModelClass.ExperienceLevel;
//    _obj_JobListModel.Responsibilities = postJob_ModelClass.Responsibilities;
//    _obj_JobListModel.URL = postJob_ModelClass.URL;
//    
//    _obj_JobListModel.EmployerIntroduction = postJob_ModelClass.EmployerIntroduction;
//    _obj_JobListModel.Qualifications = postJob_ModelClass.Qualifications;
//    
//    _obj_JobListModel.arrSkills = postJob_ModelClass.arrSkills;
//    
//}


@end
