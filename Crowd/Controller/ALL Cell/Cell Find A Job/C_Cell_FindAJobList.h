//
//  C_Cell_FindAJobList.h
//  Crowd
//
//  Created by MAC107 on 29/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_Cell_FindAJobList : UITableViewCell
@property(nonatomic,strong)IBOutlet UILabel *lblTitle;
@property(nonatomic,strong)IBOutlet UILabel *lblCompany;
@property(nonatomic,strong)IBOutlet UILabel *lblCity_State;
@property(nonatomic,strong)IBOutlet UILabel *lblCountry;
@property(nonatomic,strong)IBOutlet UILabel *lblTime;


@property(nonatomic,strong)IBOutlet UIButton *btnInfo;



@end
