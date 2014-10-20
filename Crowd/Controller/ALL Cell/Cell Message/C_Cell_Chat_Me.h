//
//  C_Cell_Chat_Me.h
//  Crowd
//
//  Created by MAC107 on 15/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_Cell_Chat_Me : UITableViewCell
@property(nonatomic,strong)IBOutlet UIImageView *imgV_MeProfilePic;

@property(nonatomic,strong)IBOutlet NSLayoutConstraint *const_lblText_Me;

@property(nonatomic,strong)IBOutlet UILabel *lblText_Me;
@property(nonatomic,strong)IBOutlet UILabel *lblTime_Me;

@property(nonatomic,strong)IBOutlet UIImageView *imgV_Me;

@property(nonatomic,strong)IBOutlet UIButton *btnLink;
@end
