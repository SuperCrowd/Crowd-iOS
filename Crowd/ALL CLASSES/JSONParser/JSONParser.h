//
//  JSONParser.h
//  Recognized_iOS
//
//  Created by MAC236 on 29/01/14.
//  Copyright (c) 2014 MAC 227. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UpdateProgressDelegate <NSObject>

@optional
- (void)uploadProgress:(CGFloat)progress;
@end

@interface JSONParser : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    SEL mySelector;
    NSString *strReqType;
    NSObject *Object;
    
    //Set Delegate For ProgressUpdate
    id __unsafe_unretained _UpdateProgressDelegate;
}
@property (nonatomic,unsafe_unretained) id _UpdateProgressDelegate;
@property(nonatomic,strong)NSMutableData *webData;
@property(nonatomic,strong)NSURLConnection *connection;
-(id)initWith_withURL:(NSString *)strURL withParam:(NSDictionary *)dictParameter withData:(NSDictionary *)dictData withType:(NSString *)type withSelector:(SEL)sel withObject:(NSObject *)objectReceive;


@end
