//
//  MultilineTextView.m
//  Multiline-TextView
//
//  Created by Mounir Dellagi on 14.10.13.
//  Copyright (c) 2013 Mounir Dellagi. All rights reserved.
//

#import "MDMultilineTextView.h"

@interface MDMultilineTextView ()
@property (nonatomic) UILabel *placeholderLabel;

@end

@implementation MDMultilineTextView

#pragma mark - Init
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Default Values (can be set via properties)
        _maxHeight = 120.0;
        _placeholderColor = [UIColor grayColor];
        _placeholder = @"Type Message Here";
        _verticalPadding = 9.0;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0] CGColor];
    }
    
    return self;
}

#pragma mark - Auto Layout
/** Calculates the content size of the text view used by auto layout to adjust the constraints */
- (CGSize)intrinsicContentSize
{
    CGSize newContentSize;
    if ([self.text length] == 0) {
        NSDictionary *attributes = @{NSFontAttributeName: self.font};
        CGRect rect = [self.placeholder boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil];
        CGSize textSize = rect.size;
        newContentSize = CGSizeMake(textSize.width, textSize.height + (2 * _verticalPadding));
        [self showPlaceholderInFrame:CGRectMake(0.0, 0.0, newContentSize.width, newContentSize.height)];
        
    }
    else {
        // Hack to detect Newlines
        NSString *str = self.text;
        if ([self.text hasSuffix:@"\n"]) {
            str = [self.text stringByAppendingString:@"."];
        }
        
        // Calc height
        NSDictionary *attributes = @{NSFontAttributeName: self.font};
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.bounds.size.width - 10.0, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        CGSize textSize = rect.size;
        newContentSize = CGSizeMake(textSize.width, textSize.height + (2 * _verticalPadding));
        [self removePlaceholder];
    }
    return newContentSize;
}

#pragma mark - Placeholder

/** Adds the placeholder label as a subview */
- (void)showPlaceholderInFrame:(CGRect)placeholderFrame
{
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0f, _verticalPadding, placeholderFrame.size.width, placeholderFrame.size.height - (2 * _verticalPadding))];
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.textColor  = self.placeholderColor;
    self.placeholderLabel.font = self.font;
    
    if (![self.placeholderLabel isDescendantOfView:self]) {
        [self addSubview:self.placeholderLabel];
    }
}

/** Removes the placeholder label subview */
- (void)removePlaceholder
{
    if ([self.placeholderLabel isDescendantOfView:self]) {
        [self.placeholderLabel removeFromSuperview];
    }
}

@end
