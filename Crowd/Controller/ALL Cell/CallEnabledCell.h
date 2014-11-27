//
//  CallEnabledCell.h
//  Crowd
//
//  Created by Bobby Gill on 11/26/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//
#import <UIKit/UIKit.h>
@protocol CallEnabledCell <NSObject>
@required
- (void) onCellCallButtonPressed:(UITableViewCell*)cell;
@end