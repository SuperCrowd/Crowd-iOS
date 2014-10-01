//
//  CommonMethods.m
//  MiMedic
//
//  Created by MAC107 on 17/07/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "CommonMethods.h"
#import "AppConstant.h"

#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>
#import <EventKit/EventKit.h>

#include <sys/param.h>
#include <sys/mount.h>

#import <mach/mach.h>
#import <mach/mach_host.h>

#import "C_UserModel.h"

#define MB (1024*1024)
#define GB (MB*1024)

@implementation CommonMethods
+ (NSString *)memoryFormatter:(long long)diskSpace {
    NSString *formatted;
    double bytes = 1.0 * diskSpace;
    double megabytes = bytes / MB;
    double gigabytes = bytes / GB;
    if (gigabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f GB", gigabytes];
    else if (megabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else
        formatted = [NSString stringWithFormat:@"%.2f bytes", bytes];
    return formatted;
    
}

#pragma mark - Methods
+ (NSString *)totalDiskSpace {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return [self memoryFormatter:space];
}

+ (NSString *)freeDiskSpace {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return [self memoryFormatter:freeSpace];
}

+ (NSString *)usedDiskSpace {
    return [self memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (CGFloat)totalDiskSpaceInBytes {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return space;
}

+ (CGFloat)freeDiskSpaceInBytes {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace;
}

+ (CGFloat)usedDiskSpaceInBytes {
    long long usedSpace = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}
+(NSString *)getAppVersionNum
{
    //              NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersionNum = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return appVersionNum;

}
+(NSString *)getSystemVersion
{
    //              NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    return currSysVer;
}
+(NSString *)getDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *deviceString = [NSString stringWithFormat:@"%@ (%@)", [[UIDevice currentDevice] model], code];
    
    return deviceString;
}

#pragma mark - Document Directory Path
/*--- Get Document Directory path ---*/
NSString *DocumentsDirectoryPath() {NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);NSString *documentsDirectoryPath = [paths objectAtIndex:0];return documentsDirectoryPath;}

#pragma mark - Do not back up on iCloud

/*--- Do not back up on iCloud ---*/
+ (BOOL)addSkipBackupAttributeToItemAtPath
{
    NSURL *URL = [NSURL fileURLWithPath:DocumentsDirectoryPath()];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


+(UIImage *)generatePDFThumbnail:(NSString *)strPath withSize:(CGSize)size
{
    NSURL* pdfFileUrl = [NSURL fileURLWithPath:strPath];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
    CGPDFPageRef page;
    
    CGRect aRect = CGRectMake(0, 0, size.width, size.height); // thumbnail size
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage* thumbnailImage;
    
    
    //NSUInteger totalNum = CGPDFDocumentGetNumberOfPages(pdf);
    
    for(int i = 0; i < 1; i++ )
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, aRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetGrayFillColor(context, 1.0, 1.0);
        CGContextFillRect(context, aRect);
        
        
        // Grab the first PDF page
        page = CGPDFDocumentGetPage(pdf, i + 1);
        CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
        // And apply the transform.
        CGContextConcatCTM(context, pdfTransform);
        
        CGContextDrawPDFPage(context, page);
        
        // Create the new UIImage from the context
        thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //Use thumbnailImage (e.g. drawing, saving it to a file, etc)
        
        CGContextRestoreGState(context);
        
    }
    UIGraphicsEndImageContext();    
    CGPDFDocumentRelease(pdf);
    
    return thumbnailImage;
}



+(BOOL)isImage:(NSString *)strLastComponent
{
    if ([strLastComponent containsString:@".jpg"] ||
        [strLastComponent containsString:@".jpeg"] ||
        [strLastComponent containsString:@".bmp"] ||
        [strLastComponent containsString:@".gif"] ||
        [strLastComponent containsString:@".png"])
    {
        return YES;
    }
    else
        return NO;
}
+(BOOL)isVideo:(NSString *)strLastComponent
{
    if ([strLastComponent containsString:@".flv"] ||
        [strLastComponent containsString:@".mp4"] ||
        [strLastComponent containsString:@".wmv"])
    {
        return YES;
    }
    else
        return NO;
}
+(BOOL)isPDF:(NSString *)strLastComponent
{
    if ([strLastComponent containsString:@".pdf"])
    {
        return YES;
    }
    else
        return NO;
}

+(void)setAttribText:(UIButton *)btn withText:(NSString *)strText withFontSize:(UIFont *)fonts withColor:(UIColor *)color
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strText];
    
    NSRange goRange = [[attributedString string] rangeOfString:strText];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:goRange];//TextColor
    [attributedString addAttribute:NSFontAttributeName value:fonts range:goRange];//TextFont
    
    btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setAttributedTitle:attributedString forState:UIControlStateNormal];
    
}


+(void)addEvent_withTitle:(NSString *)strTitle withStartDate:(NSDate *)dateStart withEndData:(NSDate *)dateEnd withHandler:(void(^)(BOOL Success,BOOL granted))compilation
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted)
        {
            compilation(NO,NO);
        }
        else
        {
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = strTitle;
            event.startDate = dateStart; //today
            event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
            [event setCalendar:[store defaultCalendarForNewEvents]];
            NSError *err = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
            //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
            compilation(YES,YES);
        }
    }];
}

/*----- alertview for iOS 7 & 8 -----*/
+ (void)displayAlertwithTitle:(NSString*)title withMessage:(NSString*)msg withViewController:(UIViewController*)viewCtr
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                        {[alert dismissViewControllerAnimated:YES completion:nil];
                                        }];
        [alert addAction:defaultAction];
        [viewCtr presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];[alertView show];
    }
}

+(C_UserModel *)getMyUser
{
    @try
    {
        NSData *myDecodedObject = [UserDefaults objectForKey:USER_INFO];
        C_UserModel *myUser = [NSKeyedUnarchiver unarchiveObjectWithData:myDecodedObject];
        return myUser;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        return nil;
    }
    @finally {
    }
    return nil;
}
+(void)saveMyUser:(C_UserModel *)myUser
{
    @try
    {
        NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:myUser];
        [UserDefaults setObject:myEncodedObject forKey:USER_INFO];
        [UserDefaults synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}


+ (UIBarButtonItem*)leftMenuButton:(UIViewController *)viewC withSelector:(SEL)mySelector
{
    UIImage *buttonImage = [UIImage imageNamed:@"menu-icon"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:viewC action:mySelector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return retVal;
}

/*----- back button with custom image -----*/
+ (UIBarButtonItem*)backBarButtton
{
    UIImage *buttonImage = [UIImage imageNamed:@"back_icon"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:appDel.navC action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];

    return retVal;
}

+ (UIBarButtonItem*)backBarButtton_NewNavigation:(UIViewController *)viewC withSelector:(SEL)mySelector
{
    UIImage *buttonImage = [UIImage imageNamed:@"back_icon"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:viewC action:mySelector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return retVal;
}

+ (UIBarButtonItem*)backBarButtton_Dismiss:(UIViewController *)viewC withSelector:(SEL)mySelector
{
    UIImage *buttonImage = [UIImage imageNamed:@"back_icon"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:viewC action:mySelector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return retVal;
}
+ (UIBarButtonItem*)createRightButton_withVC:(UIViewController *)vc withText:(NSString *)strText withSelector:(SEL)mySelector
{
//    UIImage *buttonImage = [UIImage imageNamed:@"back_icon"];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button setTitle:strText forState:UIControlStateNormal];
//    button.titleLabel.tintColor = [UIColor colorWithRed:72/255.0 green:190/255.0 blue:128/255.0 alpha:1.0];
//    button.frame = CGRectMake(0, 0, 64, 64);
//    [button addTarget:vc action:mySelector forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc]initWithTitle:strText style:UIBarButtonItemStyleBordered target:vc action:mySelector];
    retVal.tintColor = [UIColor colorWithRed:72/255.0 green:190/255.0 blue:128/255.0 alpha:1.0];

    return retVal;
}


+(NSString *)getMonthName:(NSString *)strMonthNumber
{
    if ([strMonthNumber isEqualToString:@""])
    {
        return @"";
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
    NSString *monthName = [[df monthSymbols] objectAtIndex:([strMonthNumber integerValue]-1)];
    return monthName;
}
+(NSInteger)getMonthNumber:(NSString *)strMonthName
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSDate *aDate = [formatter dateFromString:strMonthName];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:aDate];
    //NSLog(@"Month: %li", (long)[components month]); /* => 7 */
    return [components month];
}




+(NSArray *)getTagArray:(NSString *)strFinal
{
    NSArray *arrTemp = [strFinal componentsSeparatedByString:@","];
    /*--- Remove Blank String ---*/
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id str, NSDictionary *unused) {
        return ![[str isNull] isEqualToString:@""];
    }];
    
    return [arrTemp filteredArrayUsingPredicate:pred];
}

+(void)HideMyKeyboard:(MMDrawerController *)draw
{
    /*--- Hide Center View Keyboard---*/
    [draw setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture)
     {
         if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
         {
             [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
         }
     }];
}


+ (BOOL) isValidateUrl: (NSString *)url {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:url];
}
@end
