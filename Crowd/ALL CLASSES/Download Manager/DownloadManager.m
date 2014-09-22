//
//  UserDetailsModal.m
//  Dedicaring
//
//  Created by pratik on 31/10/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "DownloadManager.h"
#import "UIImageView+WebCache.h"
#import "AppConstant.h"
#import "C_UserModel.h"
@implementation DownloadManager

- (void)initialize {

}

+ (DownloadManager *)sharedManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initialize];
    });
    return sharedInstance;
}
- (void)startDownloadWithURL:(NSString *)downloadUrl handler:(DownloadBlock)completionHandler {
   if (!operation)
   {
        NSURL *url = [NSURL URLWithString:[downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //NSURL *url = [NSURL URLWithString:@"http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSString *targetPath = DocumentsDirectoryPath();
        operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:targetPath shouldResume:YES];
        operation.shouldOverwrite = YES;
       }
   [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       NSLog(@"Done");
       completionHandler(YES,100.0,nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure");
        completionHandler(NO,0.0,error);
    }];
    
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile)
    {
        float progress = totalBytesReadForFile / (float)totalBytesExpectedToReadForFile;
        completionHandler(NO,progress*100,nil);
    }];
    
    if (!operation.isExecuting && !operation.isFinished) {
        [operation start];
    }
}

-(void)downloadImagewithURL:(NSString *)strURL
{
    if (![strURL isEqualToString:@""])
    {
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:strURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             if (finished)
             {
                 myUserModel.imgUserPic = image;
                 [CommonMethods saveMyUser:myUserModel];
                 myUserModel = [CommonMethods getMyUser];
             }
             
         }];
    }
}
@end
