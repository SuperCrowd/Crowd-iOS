//
//  MessageDetailModel.h
//  Crowd
//
//  Created by MAC107 on 14/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDetailModel : NSObject
//sender details
@property NSString *msgID;
@property NSString *Message;
@property NSString *LincURL;
@property NSString *DateCreated;
@property NSString *strDisplayDate;

+(MessageDetailModel *)addMessageDetail:(NSDictionary *)dictMessageInfo;
@end
/*
 {
 DateCreated = "10/13/2014 9:45:03 AM";
 ID = 168;
 LincJobID = "";
 LincURL = "";
 LincUserID = "";
 Message = Hello;
 ReceiverID = 61;
 SenderID = 60;
 State = True;
 Type = 1;
 }
 */