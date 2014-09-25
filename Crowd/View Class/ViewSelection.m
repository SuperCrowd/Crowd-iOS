//
//  ViewSelection.m
//  Crowd
//
//  Created by MAC107 on 25/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "ViewSelection.h"

@interface ViewSelection ()

@end

@implementation ViewSelection

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        
        UIView *selfview = [[[NSBundle mainBundle] loadNibNamed:@"ViewSelection" owner:self options:nil] objectAtIndex:0];
        [self addSubview: selfview];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}

@end
