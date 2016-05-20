//
//  ViewController.m
//  NSURLSession-NSURLProtocol-WebviewCache
//
//  Created by Mark on 16/5/20.
//  Copyright © 2016年 Mark. All rights reserved.
//

#import "ViewController.h"
#import "TURLSessionProtocol.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.233.com"]];
    //设置特定的请求头 不然不会进行网络拦截 也不会将请求的内容缓存下来
    [request setValue:@"233" forHTTPHeaderField:KProtocolHttpHeadKey];
    [self.webView loadRequest:request];
    
    self.webView.scalesPageToFit = YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
