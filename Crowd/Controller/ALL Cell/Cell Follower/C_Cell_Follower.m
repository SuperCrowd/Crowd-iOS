//
//  C_Cell_Follower.m
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_Cell_Follower.h"
#import "AppConstant.h"
@implementation C_Cell_Follower

- (void)awakeFromNib {
    self.ivPhoto.layer.cornerRadius = 35.0;
    [self.ivPhoto.layer masksToBounds];
    [self.ivPhoto setClipsToBounds:YES];
    self.ivPhoto.layer.borderWidth = 1.0;
    self.ivPhoto.layer.borderColor = RGBCOLOR_GREEN.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)onCallButtonPressed:(id)sender
{
    if (self.delegate != nil)
    {
        [self.delegate onCellCallButtonPressed:self];
    }
}

@end
