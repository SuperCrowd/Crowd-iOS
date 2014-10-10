//
//  C_Cell_FindAJobList_Info.h
//  Crowd
//
//  Created by MAC107 on 30/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBtn.h"
@interface C_Cell_FindAJobList_Info : UITableViewCell

@property(nonatomic,strong)IBOutlet CustomBtn *btnLocation;
@property(nonatomic,strong)IBOutlet CustomBtn *btnEditJob;
@property(nonatomic,strong)IBOutlet UILabel *lblDescription;
@end
