//
//  C_Cell_Message_Simple.h
//  Crowd
//
//  Created by MAC107 on 13/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_Cell_Message_Simple : UITableViewCell
@property (nonatomic,strong)IBOutlet UIImageView *imgVUserPic;
@property (nonatomic,strong)IBOutlet UIImageView *imgVUnreadMSG;

@property (nonatomic,strong)IBOutlet UILabel *lblText;
@property (nonatomic,strong)IBOutlet UILabel *lblTime;

@end
