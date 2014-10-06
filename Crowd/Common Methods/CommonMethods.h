//
//  CommonMethods.h
//  MiMedic
//
//  Created by MAC107 on 17/07/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MMDrawerController;
@class C_UserModel;
@interface CommonMethods : NSObject

+ (NSString *)totalDiskSpace;
+ (NSString *)freeDiskSpace;
+ (NSString *)usedDiskSpace;

+(NSString *)getAppVersionNum;
+(NSString *)getSystemVersion;
+(NSString *)getDeviceType;

/*--- Get Document Directory path ---*/
NSString *DocumentsDirectoryPath() ;


/*--- Do not back up on iCloud ---*/
+ (BOOL)addSkipBackupAttributeToItemAtPath;



/*--- to check that url last path is image or video ---*/
+(BOOL)isImage:(NSString *)strLastComponent;
+(BOOL)isVideo:(NSString *)strLastComponent;
+(BOOL)isPDF:(NSString *)strLastComponent;


/*--- Set attibuted text to specific button ---*/
+(void)setAttribText:(UIButton *)btn withText:(NSString *)strText withFontSize:(UIFont *)fonts withColor:(UIColor *)color;

+(void)addEvent_withTitle:(NSString *)strTitle withStartDate:(NSDate *)dateStart withEndData:(NSDate *)dateEnd withHandler:(void(^)(BOOL Success,BOOL granted))compilation;


+ (void)displayAlertwithTitle:(NSString*)title withMessage:(NSString*)msg withViewController:(UIViewController*)viewCtr;


+(C_UserModel *)getMyUser;
+(void)saveMyUser:(C_UserModel *)myUser;

+ (UIBarButtonItem*)leftMenuButton:(UIViewController *)viewC withSelector:(SEL)mySelector;
+ (UIBarButtonItem*)backBarButtton;
+ (UIBarButtonItem*)backBarButtton_Dismiss:(UIViewController *)viewC withSelector:(SEL)mySelector;
+ (UIBarButtonItem*)backBarButtton_NewNavigation:(UIViewController *)viewC withSelector:(SEL)mySelector;

+ (UIBarButtonItem*)createRightButton_withVC:(UIViewController *)vc withText:(NSString *)strText withSelector:(SEL)mySelector;

+(NSString *)getMonthName:(NSString *)strMonthNumber;
+(NSInteger)getMonthNumber:(NSString *)strMonthName;

+(NSArray *)getTagArray:(NSString *)strFinal;
+(void)HideMyKeyboard:(MMDrawerController *)draw;

+ (BOOL) isValidateUrl: (NSString *)url;
+(void)addBottomLine_to_Label:(UILabel *)lbl;
@end
