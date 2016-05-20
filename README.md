# NSURLSession-NSURLProtocol-webviewCache

##产生缘由
 其实项目已经上线了一年多了，一直没时间来将一些有用的东西摘出来。最近还算是比较闲，就将一些自认为值得拿出来分享的东西摘了出来。
 
##与其他公共类比较
之前在GitHub上star最多的莫过于[RNCachingURLProtocol](https://github.com/rnapier/RNCachingURLProtocol),我也认真的看了他的源码，写的非常不错，不的不说有点过时了。而且有一点没处理的好，如果放入直接的将其使用，他会将所有的http请求都缓存下来，不管你是不是来自UIWebView的请求，所以有很大的必要去改进。

##与NSURLCache比较
相信对使用过UIWebView的同学都会知道，其实UIWebView本身是有缓存的，那就是基于NSURLCache来实现的。之前到网上看到过基于他来对NSURLCache实现离线缓存，我开始也封装了个，但是发现不是特别的好用，显得特别的笨重。后面看了一篇关于介绍[NSURLProtocol](https://www.raywenderlich.com/59982/nsurlprotocol-tutorial)的文章,英文还行的同学可以去看看。

另外，之前的请求是基于NSURLConnection来封装的，但是现在看到苹果最近发的通告，所以就改进成了NSURLSession。

##使用方法
 1.在Appdelegate中的`application:didFinishLaunchingWithOptions:`方法中加上：
 `[NSURLProtocol registerClass:[TURLSessionProtocol class]];`
 
 2.在你创建请求时，给请求添加一个请求头：
 `[request setValue:@(YES) forHTTPHeaderField:KProtocolHttpHeadKey];`需要注意key必须是`KProtocolHttpHeadKey`，不然会拦截不到你的请求。
 
 这样就大功告成。
 
###备注
如果需要修改缓存时间，请在`TURLSessionProtocol.m`文件中去将`static NSUInteger const KCacheTime = 30;`修改为你需要缓存时长的时间，单位是秒。

另外就是，最终的缓存一一归档的方式存入到沙盒的`cache`目录下，要是清空缓存也会将缓存的内容删除，如果不想一起删除，可以自定义目录。

##联系方式
如果你在使用过程中遇到任何的问题或者说有Bug和好的建议，请将你的需求发到我的Email:<365764028@qq.com>

我的QQ：1565773005

[新浪微博：比翼双飞之云中游](http://weibo.com/2108195644/profile?topnav=1&wvr=6&is_all=1).

欢迎交流。

 
 