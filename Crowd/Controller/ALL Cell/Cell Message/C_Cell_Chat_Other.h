//
//  C_Cell_Chat_Other.h
//  Crowd
//
//  Created by MAC107 on 15/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_Cell_Chat_Other : UITableViewCell
@property(nonatomic,strong)IBOutlet UIImageView *imgV_OtherProfilePic;
@property(nonatomic,strong)IBOutlet UILabel *lblTime_Other;

@property(nonatomic,strong)IBOutlet UILabel *lblText_Other;
@property(nonatomic,strong)IBOutlet UIImageView *imgV_Other;

@property(nonatomic,strong)IBOutlet NSLayoutConstraint *const_imgV_Other;

@property(nonatomic,strong)IBOutlet UIButton *btnLink;

//@property(nonatomic,strong)IBOutlet NSLayoutConstraint *const_imgV_Height;
@end
