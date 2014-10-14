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
    myMessage.Message = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"Message"]] isNull];
    
    myMessage.LincURL = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"LincURL"]] isNull];
    myMessage.DateCreated = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"DateCreated"]] isNull];

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
