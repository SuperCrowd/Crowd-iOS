//
//  C_MessageModel.h
//  Crowd
//
//  Created by MAC107 on 13/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C_MessageModel : NSObject

@property NSString *msgID;
@property BOOL IsUnreadMessages;
@property BOOL State;
@property NSString *Message;
@property NSString *Type;

@property NSString *DateCreated;

//sender details
@property NSString *SenderID;
@property NSString *PhotoURL;
@property NSString *FirstName;
@property NSString *LastName;
@property NSString *Email;
@property NSString *strDisplayText;
@property NSString *strDisplayDate;
+(C_MessageModel *)addMessageList:(NSDictionary *)dictMessageInfo;

/*{
    DateCreated = "10/12/2014 6:05:41 PM";
    ID = 163;
    IsUnreadMessages = False;
    LincJobID = 97;
    LincURL = "<null>";
    LincUserID = "";
    Message = "Job Application";
    ReceiverID = 61;
    SenderDetail =                 {
        DateCreated = "10/9/2014 8:06:50 PM";
        DateModified = "10/12/2014 6:00:53 PM";
        Email = "kantha.s23@gmail.com";
        ExperienceLevel = 2;
        FirstName = Kantha;
        Industry = "Information Technology and Services";
        Industry2 = "Computer Software";
        LastName = Shyamsundar;
        LinkedInId = QYRNCFHmzR;
        LocationCity = Chennai;
        LocationCountry = India;
        LocationState = "&";
        PhotoURL = "Profilee6e49f30-6d4a-4bfd-8806-c284c4fc3ae0.PNG";
        Summary = "";
        UserId = 67;
    };
    SenderID = 67;
    State = False;
    Type = 2;
}*/
@end
