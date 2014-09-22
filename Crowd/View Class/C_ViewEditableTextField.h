//
//  C_ViewEditableTextField.h
//  Crowd
//
//  Created by MAC107 on 08/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextFieldExtended.h"
@interface C_ViewEditableTextField : UIView
@property (nonatomic,strong)IBOutlet UITextFieldExtended *txtName;
@property (nonatomic,strong)IBOutlet UILabel *lblName;
@property (nonatomic,strong)IBOutlet UIButton *btnEdit;

@property (nonatomic,strong)IBOutlet UIButton *btnTextField;

//@property (nonatomic,weak)id viewDelegate;
@end
