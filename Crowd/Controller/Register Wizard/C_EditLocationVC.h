//
//  C_EditLocationVC.h
//  Crowd
//
//  Created by MAC107 on 12/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_EditLocationVC : UIViewController

@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,readwrite)NSInteger selectedIndexToUpdate;

@property (nonatomic,strong)NSMutableArray *arrContent;
@property(nonatomic,strong)NSString *strComingFrom;

@end
