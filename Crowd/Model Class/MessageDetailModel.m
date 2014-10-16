//
//  MessageDetailModel.m
//  Crowd
//
//  Created by MAC107 on 14/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "MessageDetailModel.h"
#import "AppConstant.h"
@implementation MessageDetailModel
+(MessageDetailModel *)addMessageDetail:(NSDictionary *)dictMessageInfo
{
    /*
     msgID;
     Message;
     LincURL;
     DateCreated;
     strDisplayDate;
     */
    MessageDetailModel *myMessage = [[MessageDetailModel alloc]init];
    
    myMessage.msgID = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"ID"]] isNull];
    myMessage.SenderID = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"SenderID"]] isNull];
    
    myMessage.Message = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"Message"]] isNull];
    
    myMessage.LincURL = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"LincURL"]] isNull];
    myMessage.LincJobID = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"LincJobID"]] isNull];
    myMessage.LincUserID = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"LincUserID"]] isNull];
    myMessage.DateCreated = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"DateCreated"]] isNull];

//    CGFloat getWidth = [myMessage.Message getWidth_withFont:kFONT_LIGHT(14.0) height:16.0];
//    if (getWidth > screenSize.size.width - 70.0)
//    {
    if ([myMessage.SenderID isEqualToString:userInfoGlobal.UserId])
    {
        CGFloat getHeight = [myMessage.Message getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 83.0];
        myMessage.heightText = getHeight + 2.0;
        myMessage.widthText = screenSize.size.width - 83.0;
    }
    else
    {
        CGFloat getHeight = [myMessage.Message getHeight_withFont:kFONT_LIGHT(14.0) widht:screenSize.size.width - 70.0];
        myMessage.heightText = getHeight + 2.0;
        myMessage.widthText = screenSize.size.width - 70.0;
    }
    
    
    
//    }
//    else
//    {
//        myMessage.heightText = 16.0;
//        myMessage.widthText = getWidth;
//    }
    
    @try
    {
        NSDate *dateS = [myMessage.DateCreated dateFromStringDateFormate:@"MM/dd/yyyy h:mm:ss a" Type:0];
        
        //11:50 PM August 20th 2014
        NSString *str_To_Month = [dateS convertDateinFormat:@"h:mm a MMMM"];
        NSString *str_DD = [dateS getPostFixString];
        NSString *str_To_Year = [dateS convertDateinFormat:@"YYYY"];
        
        myMessage.strDisplayDate = [NSString stringWithFormat:@"%@ %@ %@",str_To_Month,str_DD,str_To_Year];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        myMessage.strDisplayDate = @"";
    }
    @finally {
    }
    
    return myMessage;
}

@end
