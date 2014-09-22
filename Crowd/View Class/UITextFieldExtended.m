//
//  UITextFieldExtended.m
//  Crowd
//
//  Created by MAC107 on 11/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "UITextFieldExtended.h"

@implementation UITextFieldExtended
- (instancetype)initWithFrame:(CGRect )frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;

        return self;
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;

        return self;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
