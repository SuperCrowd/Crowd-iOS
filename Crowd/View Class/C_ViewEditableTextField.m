//
//  C_ViewEditableTextField.m
//  Crowd
//
//  Created by MAC107 on 08/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_ViewEditableTextField.h"
#import "AppConstant.h"
@implementation C_ViewEditableTextField
//@synthesize viewDelegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        
        UIView *selfview = [[[NSBundle mainBundle] loadNibNamed:@"C_ViewEditableTextField" owner:self options:nil] objectAtIndex:0];
        
        [self addSubview: selfview];   
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

        _lblName = [[UILabel alloc]initWithFrame:CGRectMake(7, 17, 63, 21)];
        _lblName.font = kFONT_LIGHT(11.0);
        _lblName.textColor = RGBCOLOR(33, 33, 33);
        [self addSubview:_lblName];
        
        
        _txtName = [[UITextFieldExtended alloc]initWithFrame:CGRectMake(53, 2, 215, 51)];
        _txtName.font = kFONT_THIN(30.0);
        _txtName.background = [UIImage imageNamed:@"textfiled2"];
        _txtName.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:_txtName];
        
        _btnTextField = [[UIButton alloc]initWithFrame:CGRectMake(53, 2, 215, 51)];
        [_btnTextField setTitle:@"" forState:UIControlStateNormal];
        _btnTextField.alpha = 0.0;
        [self addSubview:_btnTextField];
        
        _btnEdit = [[UIButton alloc]initWithFrame:CGRectMake(295, 17, 22, 22)];
        [_btnEdit setImage:[UIImage imageNamed:@"edit_icon_green"] forState:UIControlStateNormal];
        [self addSubview:_btnEdit];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Configure View

//-(void)setEditingEnabled:(BOOL)enabled
//{
//    if (enabled)
//    {
//        _btnEdit.hidden = NO;
//        _txtName.enabled = YES;
//    }
//    else
//    {
//        _btnEdit.hidden = YES;
//        _txtName.enabled = NO;
//        _txtName.background = nil;
//    }
//}

@end
