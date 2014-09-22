//
//  R_ScrollViewKeyboard.h
//  Rudder_iOS
//
//  Created by MAC236 on 25/07/14.
//  Copyright (c) 2014 MAC 227. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C_ScrollViewKeyboard : UIScrollView
{
    UIEdgeInsets    _priorInset;
    BOOL            _priorInsetSaved;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
    CGSize          _originalContentSize;
}

- (void)adjustOffsetToIdealIfNeeded;
@end
