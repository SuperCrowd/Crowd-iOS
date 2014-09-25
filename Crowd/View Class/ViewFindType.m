//
//  ViewFindType.m
//  Crowd
//
//  Created by MAC107 on 25/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "ViewFindType.h"
#import "AppConstant.h"
@interface ViewFindType ()

@end

@implementation ViewFindType
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]))
    {
        UIView *selfview = [[[NSBundle mainBundle] loadNibNamed:@"ViewFindType" owner:self options:nil] objectAtIndex:0];
        
        [self addSubview: selfview];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
            
        _lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 17, screenSize.size.width-30, 21)];
        _lblTitle.font = kFONT_LIGHT(16.0);
        _lblTitle.adjustsFontSizeToFitWidth = YES;
        _lblTitle.textColor = RGBCOLOR(33, 33, 33);
        [self addSubview:_lblTitle];
        
        _btnEditType = [[UIButton alloc]initWithFrame:CGRectMake(10, 41, 22, 22)];
        [_btnEditType setImage:[UIImage imageNamed:@"edit_icon_green"] forState:UIControlStateNormal];
        [self addSubview:_btnEditType];
        
        _lblType = [[UILabel alloc]initWithFrame:CGRectMake(32, 41, screenSize.size.width-64, 21)];
        _lblType.font = kFONT_REGULAR(16.0);
        _lblType.adjustsFontSizeToFitWidth = YES;
        _lblType.textColor = [UIColor blackColor];
        [self addSubview:_lblType];
        
        _btnDelete = [[UIButton alloc]initWithFrame:CGRectMake(screenSize.size.width-10-22, 41, 22, 22)];
        [_btnEditType setImage:[UIImage imageNamed:@"edit_icon_green"] forState:UIControlStateNormal];
        [self addSubview:_btnDelete];

        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}



@end
