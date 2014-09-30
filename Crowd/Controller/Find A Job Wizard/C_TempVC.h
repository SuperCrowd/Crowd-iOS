//
//  C_TempVC.h
//  Crowd
//
//  Created by MAC107 on 25/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TypeSelectedDelegate<NSObject>
-(void)updateContentOffsetWhenSelectTextfield;
-(void)IndustrySelected:(NSString *)industryName;


@end
@interface C_TempVC : UIViewController
@property(nonatomic,readwrite)BOOL isFirstTime;

@property(nonatomic,strong)id <TypeSelectedDelegate> delegate;
@end
