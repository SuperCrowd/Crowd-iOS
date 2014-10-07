//
//  C_MP_IndustryListVC.h
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C_MyUser;
@protocol textSelectedProtocol<NSObject>
@optional
-(void)addText:(NSString *)strText;
-(void)updateText:(NSString *)strText;
@end
@interface C_MP_IndustryListVC : UIViewController

@property(nonatomic,strong)C_MyUser *obj_ProfileUpdate;

@property(nonatomic,readwrite)BOOL isUpdate;
@property(nonatomic,strong)id <textSelectedProtocol> delegate;
@end
