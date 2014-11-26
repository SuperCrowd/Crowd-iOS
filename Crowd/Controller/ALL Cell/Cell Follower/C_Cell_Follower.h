//
//  C_Cell_Follower.h
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallEnabledCell.h"

@interface C_Cell_Follower : UITableViewCell
{
    id<CallEnabledCell> delegate;
}
@property (nonatomic, assign) id<CallEnabledCell> delegate;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblCompanyName;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (strong, nonatomic) IBOutlet UIButton* btnCall;
@end
