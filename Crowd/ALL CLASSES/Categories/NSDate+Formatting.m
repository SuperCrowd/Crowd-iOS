//
//  NSDate+Formatting.m
//  MiMedic
//
//  Created by MAC107 on 14/08/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)
-(NSString *)convertDateinFormat:(NSString *)strFormat
{
    NSCalendar *sysCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    // set your NSDateFormatter with calendar.
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.calendar = sysCalendar;
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat:strFormat];
    return [df stringFromDate:self];
}
-(NSDate *)addDay:(int)day
{
    NSCalendar *sysCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    // set your NSDateFormatter with calendar.
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = day;
    NSDate *nextDate = [sysCalendar dateByAddingComponents:dayComponent toDate:self options:0];
    return nextDate;
}
-(NSDate *)addMonth:(int)month
{
    NSCalendar *sysCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    // set your NSDateFormatter with calendar.
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.month = month;
    NSDate *nextDate = [sysCalendar dateByAddingComponents:dayComponent toDate:self options:0];
    return nextDate;
}
-(NSDate *)addYear:(int)year
{
    NSCalendar *sysCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    // set your NSDateFormatter with calendar.
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.year = year;
    NSDate *nextDate = [sysCalendar dateByAddingComponents:dayComponent toDate:self options:0];
    return nextDate;
}
-(NSDate *)changeTime:(NSString *)strTime
{
    NSCalendar *sysCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    // set your NSDateFormatter with calendar.
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.calendar = sysCalendar;
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *strNewDate = [df stringFromDate:self];
    strNewDate = [NSString stringWithFormat:@"%@ %@",strNewDate,strTime];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [df dateFromString:strNewDate];
    
}
@end