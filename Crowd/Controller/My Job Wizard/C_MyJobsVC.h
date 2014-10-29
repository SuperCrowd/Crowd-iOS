//
//  C_MyJobsVC.h
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol selectJobProtocol<NSObject>
-(void)jobSelected:(NSString *)strJobID withJobCreaterID:(NSString *)strJobCreaterID;
@end


@interface C_MyJobsVC : UIViewController
@property(nonatomic,readwrite)BOOL isPresented;
@property(nonatomic,strong)id <selectJobProtocol> delegate;
@end
