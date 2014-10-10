//
//  UpdateProfile.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "UpdateProfile.h"
#import "AppConstant.h"

@interface UpdateProfile()
{
    JSONParser *parser;
    SuccessBlock mySuccessblock;
    FailBlock myFailblock;

}
@end

@implementation UpdateProfile

-(void)updateProfile_WithModel:(C_MyUser *)myModel withSuccessBlock:(SuccessBlock)successBlock withFailBlock:(FailBlock)failBlock
{
    //    NSLog(@"%@",[UserHandler_LoggedIn getDict_To_RegisterUser]);
    mySuccessblock = successBlock;
    myFailblock = failBlock;
    @try
    {
        showHUD_with_Title(@"Updating Profile");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableDictionary *dictT = [UserHandler_LoggedIn getDict_To_Update_withProfileModel:myModel];
            parser = [[JSONParser alloc]initWith_withURL:Web_IS_USER_REGISTER_OR_UPDATE withParam:dictT withData:nil withType:kURLPost withSelector:@selector(getDataDone:) withObject:self];
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
    else if([objResponse objectForKey:@"AddEditUserDetailsResult"])
    {
        /*--- Save data here ---*/
        BOOL isRegisterSuccess = [[objResponse valueForKeyPath:@"AddEditUserDetailsResult.ResultStatus.Status"] boolValue];
        if (isRegisterSuccess)
        {
            // save user now
            
            userInfoGlobal = nil;
            userInfoGlobal = [C_MyUser addNewUser:[objResponse objectForKey:@"AddEditUserDetailsResult"]];
            [UserHandler_LoggedIn saveMyUser_LoggedIN:userInfoGlobal];
            userInfoGlobal = [UserHandler_LoggedIn getMyUser_LoggedIN];
            
            
            imgProfilePictureToUpdate = nil;
//            [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,userInfoGlobal.PhotoURL]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                
//            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                NSLog(@"Image Downloaded : %@",userInfoGlobal.PhotoURL);
//            }];
            
            hideHUD;
            mySuccessblock();
            

        }
        else
        {
            hideHUD;
            NSString *str = [objResponse valueForKeyPath:@"AddEditUserDetailsResult.ResultStatus.StatusMessage"];
            myFailblock(str);
        }
    }
    else
    {
        hideHUD;
        myFailblock([objResponse objectForKey:kURLFail]);
    }
}

@end
