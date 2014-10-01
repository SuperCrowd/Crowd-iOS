//
//  C_WebVC.m
//  Crowd
//
//  Created by MAC107 on 01/10/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_WebVC.h"
#import "AppConstant.h"
@interface C_WebVC ()<UIWebViewDelegate>
{
    __weak IBOutlet UIWebView *webV;
    __weak IBOutlet UIActivityIndicatorView *indicator;
}
@end

@implementation C_WebVC
-(void)back
{
    popView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"More Information";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    
    webV.delegate = self;
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_strURL]]];

}
#pragma mark - Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [indicator startAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [indicator stopAnimating];
    [CommonMethods displayAlertwithTitle:error.localizedDescription withMessage:nil withViewController:self];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicator stopAnimating];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
