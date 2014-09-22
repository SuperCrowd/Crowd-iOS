//
//  C_EditTimeVC.h
//  Crowd
//
//  Created by MAC107 on 11/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_EditTimeVC : UIViewController

@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,readwrite)NSInteger selectedIndexToUpdate;

@property (nonatomic,strong)NSMutableArray *arrContent;
@property(nonatomic,strong)NSString *strComingFrom;

@end
