//
//  C_Find_CandidateListingVC.h
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallEnabledCell.h"
@interface C_Find_CandidateListingVC : UIViewController<CallEnabledCell>
@property(nonatomic,strong)NSMutableDictionary *dictInfoCandidate;

@end
