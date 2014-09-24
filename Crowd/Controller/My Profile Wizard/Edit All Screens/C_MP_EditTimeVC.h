//
//  C_MP_EditTimeVC.h
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C_MyUser;

@interface C_MP_EditTimeVC : UIViewController
@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,readwrite)NSInteger selectedIndexToUpdate;

@property (nonatomic,strong)NSMutableArray *arrContent;
@property(nonatomic,strong)NSString *strComingFrom;

@property(nonatomic,strong)C_MyUser *obj_ProfileUpdate;
@end
