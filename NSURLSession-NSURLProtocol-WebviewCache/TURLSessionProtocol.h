//
//  TURLSessionProtocol.h
//  CachedWebView
//
//  Created by Mark on 16/5/19.
//
//

#import <Foundation/Foundation.h>

extern NSString *const KProtocolHttpHeadKey;

@interface TURLSessionProtocol : NSURLProtocol
//添加需要过滤的请求前缀
+ (NSSet *)filterUrlPres;
+ (void)setFilterUrlPres:(NSSet *)filterUrlPre;
@end
