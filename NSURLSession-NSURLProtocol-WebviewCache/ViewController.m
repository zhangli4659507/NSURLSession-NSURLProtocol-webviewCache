//
//  ViewController.m
//  NSURLSession-NSURLProtocol-WebviewCache
//
//  Created by Mark on 16/5/20.
//  Copyright © 2016年 Mark. All rights reserved.
//

#import "ViewController.h"
#import "TURLSessionProtocol.h"
@interface ViewController ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSMutableData *cacheData;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self actionRefrash:nil];
    
    
}

- (IBAction)actionRefrash:(id)sender {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.233.com"]];
    
    [self.webView loadRequest:request];
    
    self.webView.scalesPageToFit = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
