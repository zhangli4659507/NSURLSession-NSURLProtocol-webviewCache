//
//  TURLSessionProtocol.m
//  CachedWebView
//
//  Created by Mark on 16/5/19.
//
//

#import "TURLSessionProtocol.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
NSString *const KProtocolHttpHeadKey = @"KProtocolHttpHeadKey";

static NSUInteger const KCacheTime = 30;//缓存的时间  默认设置为30秒 可以任意的更改

@interface NSString (MD5)
- (NSString *)md5String;
@end

@interface TURLProtocolCacheData : NSObject<NSCoding>
@property (nonatomic, strong) NSDate *addDate;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
//@property (nonatomic, strong) NSURLRequest *request;
@end


@interface TURLSessionProtocol ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *cacheData;
@end

@implementation NSString(MD5)

- (NSString *)md5String {

    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end

@implementation TURLProtocolCacheData
- (void)encodeWithCoder:(NSCoder *)aCoder {

    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i = 0 ; i < count ; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
    free(ivar);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        unsigned int count = 0;
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i= 0 ;i < count ; i++) {
            Ivar var = ivar[i];
            const char *keyName = ivar_getName(var);
            NSString *key = [NSString stringWithUTF8String:keyName];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivar);
    }
    
    return self;
    
}

@end

@implementation TURLSessionProtocol

- (NSURLSession *)session {

    if (!_session) {
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _session;
}

#pragma mark - privateFunc

- (NSString *)p_filePathWithUrlString:(NSString *)urlString {

    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [urlString md5String];
    return [cachesPath stringByAppendingPathComponent:fileName];
}

- (BOOL)p_isUseCahceWithCacheData:(TURLProtocolCacheData *)cacheData {

    if (cacheData == nil) {
        return NO;
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:cacheData.addDate];
    return timeInterval < KCacheTime;
}

#pragma mark - override

+(BOOL)canInitWithRequest:(NSURLRequest *)request {

    if ([request valueForHTTPHeaderField:KProtocolHttpHeadKey]) {
        //拦截请求头中包含KProtocolHttpHeadKey的请求
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {

    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {

    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    
     NSString *url = self.request.URL.absoluteString;//请求的链接
    TURLProtocolCacheData *cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self p_filePathWithUrlString:url]];
    
    if ([self p_isUseCahceWithCacheData:cacheData]) {
        //有缓存并且缓存没过期
        [self.client URLProtocol:self didReceiveResponse:cacheData.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:cacheData.data];
        [self.client URLProtocolDidFinishLoading:self];
        
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        self.downloadTask = [self.session dataTaskWithRequest:request];
        [self.downloadTask resume];

    }
}

- (void)stopLoading {
    [self.downloadTask cancel];
    self.cacheData = nil;
    self.downloadTask = nil;
    self.response = nil;
  
}

#pragma mark - session delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {

    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
    self.cacheData = [NSMutableData data];
    self.response = response;
}

-  (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
//下载过程中
    [self.client URLProtocol:self didLoadData:data];
    [self.cacheData appendData:data];
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//    下载完成之后的处理
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        //将数据的缓存归档存入到本地文件中
        TURLProtocolCacheData *cacheData = [[TURLProtocolCacheData alloc] init];
        cacheData.data = [self.cacheData copy];
        cacheData.addDate = [NSDate date];
        cacheData.response = self.response;
       BOOL state = [NSKeyedArchiver archiveRootObject:cacheData toFile:[self p_filePathWithUrlString:self.request.URL.absoluteString]];
        
        NSLog(@"%d",state);
        [self.client URLProtocolDidFinishLoading:self];
    }

}

@end
