//
//  ContactModel.h
//  dynamicTable
//
//  Created by Mac009 on 9/30/14.
//  Copyright (c) 2014 Tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstant.h"
@interface ContactModel : NSObject
@property(nonatomic,strong)NSString *name;// For contacts
@property(nonatomic,strong)NSString *city , *state , *country;// For locations
@property(nonatomic,strong)NSString *experience;//experience
@property(nonatomic,strong)NSString *company;//comapny
@property(nonatomic,strong)NSString *position;//position
@property(nonatomic)ViewType type;
@property(nonatomic)NSUInteger indexId;
@end
