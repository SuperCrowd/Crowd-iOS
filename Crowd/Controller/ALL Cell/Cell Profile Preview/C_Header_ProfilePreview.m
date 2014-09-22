//
//  C_Header_ProfilePreview.m
//  Crowd
//
//  Created by MAC107 on 17/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_Header_ProfilePreview.h"

@implementation C_Header_ProfilePreview
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"C_Header_ProfilePreview"
                                                         owner:self
                                                       options:nil];
        UIView *nibView = [objects firstObject];
        UIView *contentView = self.contentView;
        CGSize contentViewSize = contentView.frame.size;
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        nibView.frame = CGRectMake(0, 0, contentViewSize.width, contentViewSize.height);
        [contentView addSubview:nibView];
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
