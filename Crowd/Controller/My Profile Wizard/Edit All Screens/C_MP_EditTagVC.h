//
//  C_MP_EditTagVC.h
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol updateTag<NSObject>
@optional
-(void)updateTags:(NSString *)strText;
//-(void)reloadTable;
@end

@class C_MyUser;

@interface C_MP_EditTagVC : UIViewController
@property(nonatomic,strong)NSString *strTags;
@property(nonatomic,strong)id  <updateTag> delegate;

@property(nonatomic,strong)NSString *strComingFrom;


@property(nonatomic,readwrite)NSInteger selectedIndexToUpdate;
@property (nonatomic,strong)NSMutableArray *arrContent;

@property(nonatomic,strong)C_MyUser *obj_ProfileUpdate;


@end
