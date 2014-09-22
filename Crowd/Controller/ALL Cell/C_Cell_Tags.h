//
//  C_Cell_Tags.h
//  Crowd
//
//  Created by MAC107 on 12/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTagList.h"
@interface C_Cell_Tags : UITableViewCell
@property(nonatomic,weak)IBOutlet DWTagList *tagList;
@property(nonatomic,weak)IBOutlet UIButton *btnEdit;
@end
