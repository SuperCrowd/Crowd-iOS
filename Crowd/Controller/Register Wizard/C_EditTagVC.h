//
//  C_SkillsEditVC.h
//  Crowd
//
//  Created by MAC107 on 09/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol updateTag<NSObject>
@optional
-(void)updateTags:(NSString *)strText;
//-(void)reloadTable;
@end


@interface C_EditTagVC : UIViewController
@property(nonatomic,strong)NSString *strTags;
@property(nonatomic,strong)id  <updateTag> delegate;

@property(nonatomic,strong)NSString *strComingFrom;


@property(nonatomic,readwrite)NSInteger selectedIndexToUpdate;
@property (nonatomic,strong)NSMutableArray *arrContent;

@end
