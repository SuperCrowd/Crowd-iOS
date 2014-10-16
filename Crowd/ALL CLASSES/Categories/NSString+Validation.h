//
//  NSString+URLEncoding.h
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import <Foundation/Foundation.h>


@interface NSString (OAURLEncodingAdditions)

- (NSString *)encodedURLString;
- (NSString *)encodedURLParameterString;
- (NSString *)decodedURLString;
- (NSString *)removeQuotes;

//Not Null String
-(NSString *)RemoveNull;

//Validate Email
-(BOOL)StringIsValidEmail;

//Validate for Integer Number string
-(BOOL)StringIsIntigerNumber;

//Validate for Float Number string
-(BOOL)StringIsFloatNumber;

//Complete Number string
-(BOOL)StringIsComplteNumber;

//alpha numeric string
-(BOOL)StringIsAlphaNumeric;

//White Space string
-(BOOL)StringIsWhiteSpace;

//illegal char in string
-(BOOL)StringWithIlligalChar;

//Strong Password
-(BOOL)StringWithStrongPassword:(int)minimumLength;

-(CGFloat)getWidth_withFont:(UIFont *)myFont height:(CGFloat)myHeight;
-(CGFloat)getHeight_withFont:(UIFont *)myFont widht:(CGFloat)myWidth;

//Formate Date
-(NSString *)FormateDate_withCurrentFormate:(NSString *)currentFormate newFormate:(NSString *)dateFormatter;

//Get Date
-(NSDate *)dateFromStringDateFormate:(NSString*)format Type:(int)type;

-(NSString *)getDate_From_Timestamp;
-(NSDate *)getDate_withCurrentFormate:(NSString *)currentFormate;


- (BOOL)fileAlreadyExist;

- (BOOL)containsString: (NSString*) substring;

@end
