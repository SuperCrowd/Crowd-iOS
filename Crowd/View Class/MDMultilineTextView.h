//
//  MultilineTextView.h
//  Multiline-TextView
//
//  Created by Mounir Dellagi on 14.10.13.
//  Copyright (c) 2013 Mounir Dellagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDMultilineTextView : UITextView

/** The maximum height of the text view in points */
@property (nonatomic, assign) CGFloat maxHeight;

/** The string displayed when the text view is empty */
@property (nonatomic, strong) NSString *placeholder;

/** The text color of the placeholder */
@property (nonatomic, strong) UIColor *placeholderColor;

/** The border width of the text view outline */
@property (nonatomic, assign) CGFloat borderWidth;

/** The border color of the text view outline */
@property (nonatomic, strong) UIColor *borderColor;

/** The border color of the text view outline */
@property (nonatomic) CGFloat verticalPadding;

@end
