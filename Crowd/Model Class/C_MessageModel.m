//
//  C_MessageModel.m
//  Crowd
//
//  Created by MAC107 on 13/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MessageModel.h"
#import "AppConstant.h"
#import "NSDate+Formatting.h"
/*
 @property NSString *msgID;
 @property BOOL IsUnreadMessages;
 @property NSString *Message;
 @property NSString *Type;
 
 @property NSString *DateCreated;
 
 //sender details
 @property NSString *SenderID;
 @property NSString *PhotoURL;
 @property NSString *FirstName;
 @property NSString *LastName;
 @property NSString *Email;
 */
@implementation C_MessageModel
+(C_MessageModel *)addMessageList:(NSDictionary *)dictMessageInfo
{
    C_MessageModel *myMessage = [[C_MessageModel alloc]init];
    
    myMessage.msgID = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"ID"]] isNull];

    if ([[dictMessageInfo[@"IsUnreadMessages"] isNull] isEqualToString:@"True"])
        myMessage.IsUnreadMessages = YES;
    else
        myMessage.IsUnreadMessages = NO;
    
    
    if ([[dictMessageInfo[@"State"] isNull] isEqualToString:@"True"])
        myMessage.State = YES;
    else
        myMessage.State = NO;
    
    
    myMessage.Message = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"Message"]] isNull];
    myMessage.Type = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"Type"]] isNull];
    myMessage.DateCreated = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"DateCreated"]] isNull];

    myMessage.LincJobID = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"LincJobID"]] isNull];
    myMessage.LincURL = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"LincURL"]] isNull];;
    myMessage.LincUserID = [[NSString stringWithFormat:@"%@",dictMessageInfo[@"LincUserID"]] isNull];;
    
    /*--- Sender Details ---*/
    NSDictionary *dictSender = dictMessageInfo[@"SenderDetail"];
    myMessage.FirstName = [[NSString stringWithFormat:@"%@",dictSender[@"FirstName"]] isNull];
    myMessage.LastName = [[NSString stringWithFormat:@"%@",dictSender[@"LastName"]] isNull];
    myMessage.SenderID = [[NSString stringWithFormat:@"%@",dictSender[@"UserId"]] isNull];
    
    myMessage.PhotoURL = [[NSString stringWithFormat:@"%@",dictSender[@"PhotoURL"]] isNull];
    myMessage.Email = [[NSString stringWithFormat:@"%@",dictSender[@"Email"]] isNull];

    if ([myMessage.Type isEqualToString:@"1"])
    {
        myMessage.strDisplayText = [NSString stringWithFormat:@"Conversation with %@ %@",myMessage.FirstName,myMessage.LastName];
    }
    else
    {
        myMessage.strDisplayText = [NSString stringWithFormat:@"%@ from %@ %@",myMessage.Message,myMessage.FirstName,myMessage.LastName];
    }
    
    @try
    {
        if (![myMessage.DateCreated isEqualToString:@""]) {
            NSDate *dateS = [myMessage.DateCreated dateFromStringDateFormate:@"MM/dd/yyyy h:mm:ss a" Type:0];
            
            NSCalendar *c = [[NSCalendar alloc ] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            NSDateComponents *components = [c components:NSHourCalendarUnit fromDate:dateS toDate:[NSDate date] options:0];
            NSInteger diff = components.hour;
            
            if (diff < 24)
                myMessage.strDisplayDate = [dateS convertDateinFormat:@"h:mm a"];
            else if(diff < 48)
                myMessage.strDisplayDate = @"Yesterday";
            else
                myMessage.strDisplayDate = [dateS convertDateinFormat:@"MM/dd/yyyy"];
        }
        else
        {
            myMessage.strDisplayDate = @"";
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    
    return myMessage;
}

@end
