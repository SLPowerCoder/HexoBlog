---
title: iOS你可能不知道的小技巧
date: 2016-09-02 17:48:56
categories: iOS
tags: [iOS]
keywords: Hexo,文章,测试

---

####1.根据十六进制色值返回一个UIColor对象的宏
```
#define USERCOLOR(string) [UIColor colorWithRed:((float)((string & 0xFF0000) >> 16))/255.0 green:((float)((string & 0xFF00) >> 8))/255.0 blue:((float)(string & 0xFF))/255.0 alpha:1.0]
```
####2.控制屏幕是否锁屏
```
//值为yes的时候可以防止屏幕黑屏，注意在程序结束点时候要设置为no
[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
```
<!-----More------>
####3.防止自定义导航栏返回按钮时，返回手势失效
```
self.navigationController.interactivePopGestureRecognizer.enabled = YES;
```
####4.打印函数，可以打印所在的函数，行数，以及你要打印的值

```
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
```
####5.判读当前系统的是否大于7
```
//判断版本是ios7以后版本
#define IOS_CURRENT_VERSION_IOS7 ([[UIDevice currentDevice].systemVersion floatValue] < 7.0 ? NO : YES)
```
####6.单例宏
```
//单利宏 .h文件中声明部分
#define OBJC_DEF_SINGLETON(className) \
+ (className*) shared##className ;\
+ (instancetype) alloc __attribute__((unavailable("alloc not available, call instance instead")));\
+ (instancetype) new __attribute__((unavailable("new not available, call instance instead")));
//单例宏 .m文件实现部分
#define OBJC_IMPL_SINGLETON(className) \
\
+ (className *)shared##className  { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[super alloc] init]; \
}); \
return shared##className; \
}
```