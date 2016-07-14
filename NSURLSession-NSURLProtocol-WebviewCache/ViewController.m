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
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *data = [session dataTaskWithURL:[NSURL URLWithString:@"http://img.233.com/www/img/index/2016/130X248/jzs1130-248.png"]];
    [data resume];
    
    
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
  
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
    self.cacheData = [NSMutableData data];
    }

-  (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //下载过程中
   
    [self.cacheData appendData:data];
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //    下载完成之后的处理
    
    if (error) {
       
    } else {
        
//        UIImage *image = [UIImage imageWithData:self.cacheData];
//        UIImageView *imav = [[UIImageView alloc] init];
//        imav.frame = CGRectMake(10, 10, 100, 100);
//        imav.image = image;
//        [self.view addSubview:imav];
        //将数据的缓存归档存入到本地文件中
      
    }
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
