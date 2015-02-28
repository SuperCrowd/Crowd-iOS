//
//  C_JobViewVC.h
//  Crowd
//
//  Created by MAC107 on 30/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C_JobListModel;
@interface C_JobViewVC : UIViewController <UIActionSheetDelegate>
@property(nonatomic,strong)C_JobListModel *obj_myJob;
@end
