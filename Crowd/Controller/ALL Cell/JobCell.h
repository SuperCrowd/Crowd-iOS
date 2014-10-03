//
//  JobCellTableViewCell.h
//  dynamicTable
//
//  Created by Mac009 on 9/30/14.
//  Copyright (c) 2014 Tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblCategoryName;
@property (strong, nonatomic) IBOutlet UILabel *lblSearch;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;

@end
