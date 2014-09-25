//
//  ViewSelection.h
//  Crowd
//
//  Created by MAC107 on 25/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewSelection : UIView
/*--- Selection Button ---*/
@property (nonatomic,strong)IBOutlet UIButton *btnIndustry;
@property (nonatomic,strong)IBOutlet UIButton *btnPosition;
@property (nonatomic,strong)IBOutlet UIButton *btnExperience;
@property (nonatomic,strong)IBOutlet UIButton *btnLocation;
@property (nonatomic,strong)IBOutlet UIButton *btnCompany;

@property (nonatomic,strong)IBOutlet NSLayoutConstraint *con_btnIndustry;
@property (nonatomic,strong)IBOutlet NSLayoutConstraint *con_btnPosition;
@property (nonatomic,strong)IBOutlet NSLayoutConstraint *con_btnExperience;
@property (nonatomic,strong)IBOutlet NSLayoutConstraint *con_btnLocation;
@property (nonatomic,strong)IBOutlet NSLayoutConstraint *con_btnCompany;
@end
