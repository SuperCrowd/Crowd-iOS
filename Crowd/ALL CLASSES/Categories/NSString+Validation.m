//
//  NSString+URLEncoding.m
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "NSString+Validation.h"
#import "AppConstant.h"
@implementation NSString (OAURLEncodingAdditions)

- (NSString *)encodedURLString {
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self,
                                                                                             NULL,                   // characters to leave unescaped (NULL = all escaped sequences are replaced)
                                                                           CFSTR("?=&+"),          // legal URL characters to be escaped (NULL = all legal characters are replaced)
                                                                           kCFStringEncodingUTF8)); // encoding
	return result ;
}

- (NSString *)encodedURLParameterString {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self,NULL,CFSTR(":/=,!$&'()*+;[]@#?"),kCFStringEncodingUTF8));
	return result;
}

- (NSString *)decodedURLString
{
	NSString *result = (NSString*)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)self,CFSTR(""),kCFStringEncodingUTF8));
	return result;
}

-(NSString *)removeQuotes
{
	NSUInteger length = [self length];
	NSString *ret = self;
	if ([self characterAtIndex:0] == '"') {
		ret = [ret substringFromIndex:1];
	}
	if ([self characterAtIndex:length - 1] == '"') {
		ret = [ret substringToIndex:length - 2];
	}
	
	return ret;
}
#pragma mark - Not Null String
-(NSString *)RemoveNull
{
    if(self == nil)
    {
        return @"";
    }
    else if(self == (id)[NSNull null] ||
            [self caseInsensitiveCompare:@"(null)"] == NSOrderedSame ||
            [self caseInsensitiveCompare:@"<null>"] == NSOrderedSame ||
            [self caseInsensitiveCompare:@"null"] == NSOrderedSame ||
            [self caseInsensitiveCompare:@""] == NSOrderedSame ||
            [self length]==0)
    {
        return @"";
    }
    else
    {
        return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}


#pragma mark - Validate Email
-(BOOL)StringIsValidEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

#pragma mark - Validate for Integer Number string
-(BOOL)StringIsIntigerNumber
{
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"[0-9]" options:0 error:NULL];
    NSUInteger matches = [regex numberOfMatchesInString:self options:0
                                                  range:NSMakeRange(0, [self length])];
    if (matches == [self length])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma mark - Validate for Float Number string
-(BOOL)StringIsFloatNumber
{
    if([self rangeOfString:@"."].location == NSNotFound)
    {
        return NO;
    }
    else
    {
        
        NSString *regx = @"(-){0,1}(([0-9]+)(.)){0,1}([0-9]+)";
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regx];
        return [test evaluateWithObject:self];
    }
}


#pragma mark - Complete Number string
-(BOOL)StringIsComplteNumber
{
    NSString *regx = @"(-){0,1}(([0-9]+)(.)){0,1}([0-9]+)";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regx];
    return [test evaluateWithObject:self];
}


#pragma mark - alpha numeric string
-(BOOL)StringIsAlphaNumeric
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([self rangeOfCharacterFromSet:set].location != NSNotFound)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - Contain Space string
-(BOOL)StringIsWhiteSpace
{
    NSRange whiteSpaceRange = [self rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - illegal char in string
-(BOOL)StringWithIlligalChar
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    if ([self rangeOfCharacterFromSet:set].location != NSNotFound)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -Strong Password
-(BOOL)StringWithStrongPassword:(int)minimumLength
{
    if([self length] <minimumLength)
    {
        return NO;
    }
    BOOL isCaps = FALSE;
    BOOL isNum = FALSE;
    BOOL isSymbol = FALSE;
    
    NSRegularExpression *regexCaps = [[NSRegularExpression alloc]
                                      initWithPattern:@"[A-Z]" options:0 error:NULL];
    NSUInteger intMatchesCaps = [regexCaps numberOfMatchesInString:self options:0
                                                             range:NSMakeRange(0, [self length])];
    if (intMatchesCaps > 0)
    {
        isCaps = TRUE;
    }
    
    NSRegularExpression *regexNum = [[NSRegularExpression alloc]
                                     initWithPattern:@"[0-9]" options:0 error:NULL];
    NSUInteger intMatchesNum = [regexNum numberOfMatchesInString:self options:0
                                                           range:NSMakeRange(0, [self length])];
    if (intMatchesNum > 0)
    {
        isNum = TRUE;
    }
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    if ([self rangeOfCharacterFromSet:set].location != NSNotFound)
    {
        isSymbol = TRUE;
    }
    
    if(isCaps == TRUE && isNum == TRUE && isSymbol == TRUE)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

#pragma mark - Get height + Width
-(CGFloat)getWidth_withFont:(UIFont *)myFont height:(CGFloat)myHeight
{
    CGRect frame;
    CGSize textSize;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              myFont, NSFontAttributeName,
                                              nil];
        
        frame = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,myHeight)
                                   options:NSStringDrawingTruncatesLastVisibleLine
                                attributes:attributesDictionary
                                   context:nil];
        textSize = frame.size;
    }
    else
    {
        //textSize = [self sizeWithFont:myFont constrainedToSize:CGSizeMake(myWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return ceilf(textSize.width);
}
-(CGFloat)getHeight_withFont:(UIFont *)myFont widht:(CGFloat)myWidth
{
    CGRect frame;
    CGSize textSize;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              myFont, NSFontAttributeName,
                                              nil];
        
        frame = [self boundingRectWithSize:CGSizeMake(myWidth,CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributesDictionary
                                          context:nil];
        textSize = frame.size;
    }
    else
    {
        //textSize = [self sizeWithFont:myFont constrainedToSize:CGSizeMake(myWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return ceilf(textSize.height);
}

#pragma mark - Formatting Date
-(NSString *)FormateDate_withCurrentFormate:(NSString *)currentFormate newFormate:(NSString *)dateFormatter
{
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSCalendar *sysCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    // set your NSDateFormatter with calendar.
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.calendar = sysCalendar;
    [df setLocale:enUSPOSIXLocale];

    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat:currentFormate];
    NSDate *date = [df dateFromString:self];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat:dateFormatter];
    return [df stringFromDate:date];
}

-(NSDate *)dateFromStringDateFormate:(NSString*)format Type:(int)type{
    
    // Set up an NSDateFormatter for UTC time zone
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDateFormatter* formatterUtc = [[NSDateFormatter alloc] init];
    [formatterUtc setDateFormat:format];
    [formatterUtc setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatterUtc setLocale:enUSPOSIXLocale];

    // Cast the input string to NSDate
    NSDate* utcDate = [formatterUtc dateFromString:self];
    
    // Set up an NSDateFormatter for the device's local time zone
    NSDateFormatter* formatterLocal = [[NSDateFormatter alloc] init];
    [formatterLocal setDateFormat:format];
    [formatterLocal setTimeZone:[NSTimeZone localTimeZone]];
    [formatterLocal setLocale:enUSPOSIXLocale];

    // Create local NSDate with time zone difference
    NSDate* localDate = [formatterUtc dateFromString:[formatterLocal stringFromDate:utcDate]];
    
    if (type == 0) {
        return utcDate;
    }
    else
        return localDate;
}
-(NSString *)getDate_From_Timestamp
{
    double unixTimeStamp =[self doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setDateFormat:@"dd/MM/yyyy à HH:mm"];
    NSString *_date=[_formatter stringFromDate:date];
    return _date;
}
-(NSDate *)getDate_withCurrentFormate:(NSString *)currentFormate
{
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSCalendar *sysCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    // set your NSDateFormatter with calendar.
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.calendar = sysCalendar;
    [df setLocale:enUSPOSIXLocale];

    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat:currentFormate];
    return [df dateFromString:self];
}
#pragma mark - Check File Already Exist
- (BOOL)fileAlreadyExist
{
    NSString *FinalPath = [DocumentsDirectoryPath() stringByAppendingPathComponent:self];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:FinalPath]) { // Directory exists
        return YES;
    }
    return NO;
}

#pragma mark - Check Contains String
- (BOOL)containsString: (NSString*) substring
{
    NSRange range = [self rangeOfString:substring options:NSCaseInsensitiveSearch];
    //NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

@end
