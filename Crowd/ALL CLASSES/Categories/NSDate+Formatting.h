//
//  NSDate+Formatting.h
//  MiMedic
//
//  Created by MAC107 on 14/08/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)
-(NSString *)convertDateinFormat:(NSString *)strFormat;
-(NSDate *)addDay:(int)day;
-(NSDate *)addMonth:(int)month;
-(NSDate *)addYear:(int)year;

-(NSDate *)changeTime:(NSString *)strTime;

//get st/th/nd/rd
-(NSString *)getPostFixString;
-(NSString *)getGMTDateString:(NSString*)format;
@end
