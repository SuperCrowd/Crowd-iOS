//
//  NSObject+Validation.m
//  MiMedic
//
//  Created by MAC107 on 17/07/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "NSObject+Validation.h"

@implementation NSObject (Validation)
- (id)isNull
{
    id object = self;
    if ([object isKindOfClass:(id)[NSNull class]])
    {
        return @"";
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        NSString *str = [(id)self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(str == nil||
            str == (id)[NSNull null] ||
            [str caseInsensitiveCompare:@"(null)"] == NSOrderedSame ||
            [str caseInsensitiveCompare:@"<null>"] == NSOrderedSame ||
            [str caseInsensitiveCompare:@"null"] == NSOrderedSame ||
            [str caseInsensitiveCompare:@""] == NSOrderedSame ||
            [str length]==0 )
        {
            return @"";
        }
        else
        {
            return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    else
        return object;
}

@end
