//
//  C_PostJob_UpdateVC.h
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C_JobListModel;
@interface C_PostJob_UpdateVC : UIViewController
@property (nonatomic,strong)NSString *strComingFrom;
@property(nonatomic,strong)C_JobListModel *obj_JobListModel;
@end
