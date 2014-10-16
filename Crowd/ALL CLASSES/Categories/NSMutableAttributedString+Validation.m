//
//  NSMutableAttributedString+Validation.m
//  MiMedic
//
//  Created by MAC107 on 20/08/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "NSMutableAttributedString+Validation.h"
#import "AppConstant.h"
@implementation NSMutableAttributedString (Validation)
-(NSMutableAttributedString *)replaceFonts
{
    UIFont *fontSelected = (iPhone)?kFONT_REGULAR(14.0):kFONT_REGULAR(28.0);
    @try
    {
        [self beginEditing];
        [self enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                UIFont *oldFont = (UIFont *)value;
                //NSLog(@"%@",oldFont.fontName);
                
                [self removeAttribute:NSFontAttributeName range:range];
                
                if ([oldFont.fontName isEqualToString:@"TimesNewRomanPSMT"])//TimesNewRomanPSMT
                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
                else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldMT"])
                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
                else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-ItalicMT"])
                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
                else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldItalicMT"])
                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
                else
                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
            }
        }];
        return self;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        return nil;
    }
    @finally {
    }
    
}

-(NSMutableAttributedString *)replaceFonts_Quicksand
{
    UIFont *fontSelected = (iPhone)?kFONT_REGULAR(14.0):kFONT_REGULAR(28.0);
    @try
    {
        [self beginEditing];
        [self enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                //UIFont *oldFont = (UIFont *)value;
                //NSLog(@"%@",oldFont.fontName);
                
                [self removeAttribute:NSFontAttributeName range:range];
                [self addAttribute:NSFontAttributeName value:fontSelected range:range];
//                if ([oldFont.fontName isEqualToString:@"TimesNewRomanPSMT"])//TimesNewRomanPSMT
//                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
//                else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldMT"])
//                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
//                else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-ItalicMT"])
//                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
//                else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldItalicMT"])
//                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
//                else
//                    [self addAttribute:NSFontAttributeName value:fontSelected range:range];
            }
        }];
        return self;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        return nil;
    }
    @finally {
    }
    
}


-(float)getHeight_with_width:(float)myWidth
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
