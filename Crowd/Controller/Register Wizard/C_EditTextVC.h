//
//  C_EditTextVC.h
//  Crowd
//
//  Created by MAC107 on 11/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
//@protocol updateText<NSObject>
//-(void)updateText:(NSString *)strText;
//@end
@interface C_EditTextVC : UIViewController
//@property(nonatomic,strong)id  <updateText> delegate;
@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,readwrite)NSInteger selectedIndexToUpdate;

@property (nonatomic,strong)NSMutableArray *arrContent;

@property(nonatomic,strong)NSString *strComingFrom;

@end
