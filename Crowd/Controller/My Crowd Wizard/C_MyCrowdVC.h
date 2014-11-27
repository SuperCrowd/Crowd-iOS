//
//  C_MyCrowdVC.h
//  Crowd
//
//  Created by Mac009 on 10/9/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallEnabledCell.h"
@protocol selectUserProtocol<NSObject>
-(void)userSelected:(NSString *)strUserID;
@end

@interface C_MyCrowdVC : UIViewController<CallEnabledCell>
@property(nonatomic,readwrite)BOOL isPresented;
@property(nonatomic,strong)NSString *strReceiverID;
@property(nonatomic,strong)id <selectUserProtocol> delegate;
@end
