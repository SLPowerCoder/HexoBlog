---
title: Mac上 Hexo安装与配置
categories: iOS
tags: [iOS]

---

1. 去掉按钮的高亮黑
```
[funcImgBtn setAdjustsImageWhenHighlighted:NO];
```
2. 设置视图属性防止背景图片变形
关于UIViewContentMode的详解
http://blog.csdn.net/iunion/article/details/7494511<!---More-->
```
//对于UIButton需要设置button中的imageView的contentMode属性
button.imageView.contentMode = UIViewContentModeScaleAspectFill;
//
视图.contentMode = UIViewContentModeScaleAspectFill;
视图.clipsToBounds = YES;
```
3. 当一个页面有多个scrollView（或继承自scrollVIew）的时候，点击状态栏不会回到顶部，可以将非当前显示页的scrollVIew. scrollToTop设置为NO。
4. 去掉在UITableViewStylePlain 样式的时候多余的默认cell
```
_tableView.tableFooterView = [[UIView alloc]init];
```
5. 去掉在UITableViewStyleGrouped 样式的时候默认的组脚高度
```
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001; //越小越好，不能设置为0
}
```
6. 自定义导航栏的返回按钮而造成返回手势的失效的解决办法，对于最顶层的VC我们需要设置enabled = NO，因为最外面一层是不需要该手势的
```
self.navigationController.interactivePopGestureRecognizer.delegate = self;
self.navigationController.interactivePopGestureRecognizer.enabled = YES;
```
7. 导航条的颜色设置，tabbar也类似
```
 //设置状态栏为亮色
 [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
 //设置title的属性
 [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
 //设置导航条的颜色
 [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"back"] forBarMetrics:UIBarMetricsDefault];
 //设置导航条所有字体的颜色。包括title，返回箭头的颜色等
 [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
```
8. 根据十六进制色值返回一个UIColor对象的宏
```
#define USERCOLOR(string) [UIColor colorWithRed:((float)((string & 0xFF0000) >> 16))/255.0 green:((float)((string & 0xFF00) >> 8))/255.0 blue:((float)(string & 0xFF))/255.0 alpha:1.0]
```
9. 控制屏幕是否锁屏
```
//值为yes的时候可以防止屏幕黑屏，注意在程序结束点时候要设置为no
[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
```
10. 防止自定义导航栏返回按钮时，返回手势失效
```
self.navigationController.interactivePopGestureRecognizer.enabled = YES;
```
11. 打印函数，可以打印所在的函数，行数，以及你要打印的值
```
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
```
12. 判读当前系统的是否大于7
```
//判断版本是ios7以后版本
#define IOS_CURRENT_VERSION_IOS7 ([[UIDevice currentDevice].systemVersion floatValue] < 7.0 ? NO : YES)
```

13. UISwitch的大小设置可以通过CGAffineTransformMakeScale缩放来设置
```
        self.switch = [[UISwitch alloc]init];
        [self.switch setOrigin:CGPointMake(Width-60, 15)];
        self.switch.center = CGPointMake(self.switch.center.x, self.height/2);
        self.switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
        self.switch.hidden = YES;
        self.switch.onTintColor = USERCOLOR(0xffd600);
        self.switch.tintColor = USERCOLOR(0x222222);
        self.switch.thumbTintColor = USERCOLOR(0x222222);
        [self addSubview:self.switch];
```

14.  load和initialize
```
//程序在加载类文件时候会调用load，无论实现该方法的类有没有被引用（只要程序运行的时候就会加载该类文件）
+(void)load
//在类被初始化之前会调用一次
+(void)initialize
```