//
//  C_Cell_Find_CandidateList.h
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_Cell_Find_CandidateList : UITableViewCell
@property(nonatomic,strong)IBOutlet UILabel *lblName;
@property(nonatomic,strong)IBOutlet UILabel *lblCompany;
@property(nonatomic,strong)IBOutlet UILabel *lblCity_State;
@property(nonatomic,strong)IBOutlet UILabel *lblCountry;

@property(nonatomic,strong)IBOutlet UIImageView *imgVUserPic;

@property(nonatomic,strong)IBOutlet UIButton *btnInfo;
@end
