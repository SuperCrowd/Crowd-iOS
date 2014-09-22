//
//  NSAttributedString+Validation.m
//  MiMedic
//
//  Created by MAC107 on 30/07/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "NSAttributedString+Validation.h"

@implementation NSAttributedString (Validation)
-(float)getHeight_HTML_with_width:(float)myWidth
{
    CGSize textSize;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:context:)])
    {
        CGRect newSize = [self boundingRectWithSize:CGSizeMake(myWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];

        textSize = newSize.size;
    }
    else
    {
        //textSize = [self sizeWithFont:myFont constrainedToSize:CGSizeMake(myWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return textSize.height;
}
@end
