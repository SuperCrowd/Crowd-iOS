//
//  C_PostJob_UpdateVC.h
//  Crowd
//
//  Created by MAC107 on 23/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol postJobProtocol <NSObject>
@optional
-(void)deletedJobProtocol_with_JobID:(NSString *)jobID;
@end

@class C_JobListModel;
@interface C_PostJob_UpdateVC : UIViewController
@property (nonatomic,strong)NSString *strComingFrom;
@property(nonatomic,readwrite)BOOL isNewJobPost;
@property(nonatomic,strong)C_JobListModel *obj_JobListModel;

@property(nonatomic,strong)id <postJobProtocol> delegate;
@end
