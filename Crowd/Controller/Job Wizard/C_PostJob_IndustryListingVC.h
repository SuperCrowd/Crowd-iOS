//
//  C_PostJob_IndustryListingVC.h
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol textSelected_PostJob_Industry<NSObject>
@optional
-(void)addText:(NSString *)strText;
-(void)updateText:(NSString *)strText;
@end

@interface C_PostJob_IndustryListingVC : UIViewController
@property(nonatomic,readwrite)BOOL isAdd_1;
@property(nonatomic,readwrite)BOOL isAdd_2;

@property(nonatomic,strong)id <textSelected_PostJob_Industry> delegate;
@end
