//
//  MainViewController.h
//  dynamicTable
//
//  Created by Mac009 on 9/29/14.
//  Copyright (c) 2014 Tatva. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainViewController : UIViewController
@property(nonatomic)BOOL isEdit,isForCandidate;
- (IBAction)btnSearchPressed:(id)sender;
- (IBAction)btnAddCriteriaPressed:(id)sender;
@end
