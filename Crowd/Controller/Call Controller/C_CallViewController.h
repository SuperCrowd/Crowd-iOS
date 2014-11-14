//
//  C_CallViewController.h
//  Crowd
//
//  Created by Bobby Gill on 11/1/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_CallViewController : UIViewController

@property (nonatomic,strong) IBOutlet UIButton *btnHangUp;
@property (nonatomic,strong) IBOutlet UILabel *lblStatusText;
@property BOOL isCalling;
+ (C_CallViewController*)createForDialing:(NSString*)user;
+ (C_CallViewController*)createForReceiving;
@end
