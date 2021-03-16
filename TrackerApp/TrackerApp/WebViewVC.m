//
//  WebViewVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 10/05/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "WebViewVC.h"

@interface WebViewVC ()

@end

@implementation WebViewVC
@synthesize btnIndex;

- (void)viewDidLoad
{
    self.view.backgroundColor = global_greenColor;
    
    
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy)];
    [viewHeader setBackgroundColor:global_greenColor];
    [self.view addSubview:viewHeader];
    
//    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
//    lblBack.backgroundColor = [UIColor blackColor];
//    lblBack.alpha = 0.5;
//    [viewHeader addSubview:lblBack];
    
    UIImageView * imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-200)/2,-55, 200, 200)];
    imgLogo.image = [UIImage imageNamed:@"logo.png"];
    imgLogo.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgLogo];

    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    //    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    //    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    //    imgMenu.backgroundColor = UIColor.clearColor;
    //    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, yy)];
    [btnMenu addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 84);
        imgLogo.frame = CGRectMake((DEVICE_WIDTH-200)/2,-38, 200, 200);
        backImg.frame = CGRectMake(10, 7+44, 12, 20);
        [btnMenu setFrame:CGRectMake(0, 0, 88, 84)];
        //        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
//        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 84);
        
    }
}
#pragma mark - set UI Frames
-(void) setContentViewFrames
{
    int yy = 64;
    int zz = 0;
    if (IS_IPHONE_X)
    {
        yy = 84;
        zz = 40;
    }
    if (btnIndex == 0)
    {
        WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz) configuration:theConfiguration];
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://benjaminshamoilia.wixsite.com/mysite"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webView loadRequest:request];
        [webView reload];
//        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:webView];
        

    }
    else if (btnIndex == 1)
    {
        WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz) configuration:theConfiguration];
        NSURL *targetURL = [[NSBundle mainBundle] URLForResource:@"PrivacyPolicy" withExtension:@"pdf"];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webView loadRequest:request];
        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:webView];
        

    }
    else if (btnIndex == 2)
    {
        WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz) configuration:theConfiguration];
        NSURL *targetURL = [[NSBundle mainBundle] URLForResource:@"TERMSandCond" withExtension:@"pdf"];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webView loadRequest:request];
        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:webView];
        

    }
    else if (btnIndex == 3)
    {
        WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz) configuration:theConfiguration];
        
        NSURL *targetURL = [[NSBundle mainBundle] URLForResource:@"KuurvHelp" withExtension:@"pdf"];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webView loadRequest:request];
        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:webView];
    }
            

}
#pragma mark - All button click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
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
