---
title: 写这篇blog内心是崩溃的
categories: iOS
tags: [masonry]

---

在某一个月黑风高的夜里，他正在伏案敲代码，敲完之后一脸自信的cmd + run，结果不愉快的事情就此发生了，心塞。。😂
事情是这样的，我们美丽的UI设计了一套图，本来想自定义个flowLayout走个捷径的，事实却发现走了个大弯路，图是下面这样子的👇

![图.png](http://upload-images.jianshu.io/upload_images/1229960-fd829b12d38e19b5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/480)
约束报错，很是无奈，于是我又到GitHub上查看了一遍masonry的使用方式，现总一下。

iOS布局有这么几种方式：
**frame：**你要看吗？我并不打算写
**autoResize：**autoresizingMask是view的一个布局属性，默认值是UIViewAutoresizingNone，这个枚举值有很多值，具体自己查看
**autoLayout：**自动布局出来以后，很受欢迎，为此苹果还设计了[VFL](http://www.tuicool.com/articles/QrUfemz)可视化语言，但是程序员是很懒的（不是说不会偷懒的程序员不是好程序员吗，所以我说程序员懒并不是贬义词），然后[masonry](https://github.com/SnapKit/Masonry)就诞生了，masonry是一个对NSLayoutConstraint的封装具备链式语法的三方布局库，很受大家欢迎，我不敢说没人用frame布局，但是我敢说没几个人还在用NSLayoutConstraint来布局了吧

masonry的具体用法就不说了，GitHub上有详细的用法，下面就提一下masonry一些你值得注意的地方。

1. masrony 提供的一个利于debug约束问题的方法，代码摘自masonry的demo上的，我加了注释

```  Objective-C
  
    UIView *greenView = UIView.new;
    greenView.backgroundColor = UIColor.greenColor;
    [self addSubview:greenView];

    UIView *redView = UIView.new;
    redView.backgroundColor = UIColor.redColor;
    [self addSubview:redView];

    UILabel *blueView = UILabel.new;
    blueView.backgroundColor = UIColor.blueColor;
    [self addSubview:blueView];

    UIView *superview = self;
    int padding = 10;
    // 给视图添加key的方式有两种，如下所示

    // 法一：
    //you can attach debug keys to views like so:
    // greenView.mas_key = @"greenView";
    // redView.mas_key = @"redView";
    // blueView.mas_key = @"blueView";
    // superview.mas_key = @"superview";

    // 法二：
    //OR you can attach keys automagically like so:
    MASAttachKeys(greenView, redView, blueView, superview);

    // 给约束添加key
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        //you can also attach debug keys to constaints
        make.edges.equalTo(@1).key(@"ConflictingConstraint"); //composite constraint keys will be indexed
        make.height.greaterThanOrEqualTo(@5000).key(@"ConstantConstraint");

        make.top.equalTo(greenView.mas_bottom).offset(padding);
        make.left.equalTo(superview.mas_left).offset(padding);
        make.bottom.equalTo(superview.mas_bottom).offset(-padding).key(@"BottomConstraint");
        make.right.equalTo(superview.mas_right).offset(-padding);
        make.height.equalTo(greenView.mas_height);
        make.height.equalTo(redView.mas_height).key(@340954); //anything can be a key
    }];
    
    return self;
}
```
上面的约束有问题，会抛出问题，如果不给视图和约束设置key的话，xcode提示错误如下：
``` Objective-C
Probably at least one of the constraints in the following list is one you don't want. 
	Try this: 
		(1) look at each constraint and try to figure out which you don't expect; 
		(2) find the code that added the unwanted constraint or constraints and fix it. 
(
    "<MASLayoutConstraint:0x6000000a5e20 UILabel:0x7fb318c2c990.left == MASExampleDebuggingView:0x7fb318c15c00.left + 1>",
    "<MASLayoutConstraint:0x6080000a40e0 UILabel:0x7fb318c2c990.left == MASExampleDebuggingView:0x7fb318c15c00.left + 10>"
)
```
给视图和约束添加了key之后的提示如下：
``` Objective-C
Probably at least one of the constraints in the following list is one you don't want. 
	Try this: 
		(1) look at each constraint and try to figure out which you don't expect; 
		(2) find the code that added the unwanted constraint or constraints and fix it. 
(
    "<MASLayoutConstraint:ConflictingConstraint[0] UILabel:blueView.left == MASExampleDebuggingView:superview.left + 1>",
    "<MASLayoutConstraint:0x6000000b7ac0 UILabel:blueView.left == MASExampleDebuggingView:superview.left + 10>"
)

```
是不是看着爽多了。。
这样你就能看到具体是哪个view的哪个约束可能出现问题了，而不是出现一堆的十六进制地址

2.添加或者更新(update、remake)约束的代码应该放在哪，代码如下一看便知

``` Objective-C
// 当你使用autoLayout布局的时候建议写此方法，防止autoresize布局造成的错误
+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
// 苹果推荐添加或者更新（update、remake）约束的地方
- (void)updateConstraints {

    [self.growingButton updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(self.buttonSize.width)).priorityLow();
        make.height.equalTo(@(self.buttonSize.height)).priorityLow();
        make.width.lessThanOrEqualTo(self);
        make.height.lessThanOrEqualTo(self);
    }];
    // according to apple super should be called at end of method
    [super updateConstraints];
}
```

3.autoLayout不允许对其属性例如左、右、centerY等被设置为常量，因此如果你要给这些属性传递一个NSNumber类型的值得时候masonry会将他们转换成与父视图相关的约束。

``` Objective-C

However Auto Layout does not allow alignment attributes such as left, right, centerY etc to be set to constant values. 
So if you pass a NSNumber for these attributes
 Masonry will turn these into constraints relative to the view’s superview ie:
 [view makeConstraints:^(MASConstraintMaker *make) {    
        make.left.lessThanOrEqualTo(@10)
 }];
```
view的左边距等价于 view.left = view.superview.left + 10

4.按比例布局，如果各占一半的话，也可以不用multipliedBy，直接约束两个视图的width isEqual就行了

``` Objective-C
// topInnerView的宽度是高度的1/3
[self.topInnerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.equalTo(self.topInnerView.mas_height).multipliedBy(3);
]
```
5.你用NSAutoLyoutConstraints布局的时候需要设置视图的`view1.translatesAutoresizingMaskIntoConstraints = NO`，默认值是YES，等于YES的时候autoresize会影响autolayout布局，有时会发现效果不是自己想要的，不过如果你用masonry设置约束的时候，masonry会帮你把这个属性值设置为NO，你不用管它，写出来就是想提醒你。

6.看完官方的demo，发现他们会把需要的每个约束都写上，但是有时候不需要全写上，如下面被我注释的代码，但是官方是没有注释的，既然人家官方都这样写，你是不是也应该这样写啊，别注释了，这样不容易出错，如下：

``` Objective-C
 UIView *superview = self;
    int padding = 10;

    //if you want to use Masonry without the mas_ prefix
    //define MAS_SHORTHAND before importing Masonry.h see Masonry iOS Examples-Prefix.pch
    [greenView makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(superview.top).offset(padding);
        make.left.equalTo(superview.left).offset(padding);
        make.bottom.equalTo(blueView.top).offset(-padding);
        make.right.equalTo(redView.left).offset(-padding);
        make.width.equalTo(redView).multipliedBy(1);

        make.height.equalTo(redView.height);
        make.height.equalTo(blueView.height);
    }];

    //with is semantic and option
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).with.offset(padding); //with with
        //make.left.equalTo(greenView.mas_right).offset(padding); //without with
        make.bottom.equalTo(blueView.mas_top).offset(-padding);
        make.right.equalTo(superview.mas_right).offset(-padding);
        // make.width.equalTo(greenView).multipliedBy(1);
        
        make.height.equalTo(@[greenView, blueView]); //can pass array of views
    }];
    
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(greenView.mas_bottom).offset(padding);
        make.left.equalTo(superview.mas_left).offset(padding);
        make.bottom.equalTo(superview.mas_bottom).offset(-padding);
        make.right.equalTo(superview.mas_right).offset(-padding);
        make.height.equalTo(@[greenView.mas_height, redView.mas_height]); //can pass array of attributes
    }];

    return self;
}

```
要注意blueView设置高度依赖的时候设置的是一个数组这样的用法

7.masonry动画

``` Objective-C

@implementation MASExampleUpdateView

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.growingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.growingButton setTitle:@"Grow Me!" forState:UIControlStateNormal];
    self.growingButton.layer.borderColor = UIColor.greenColor.CGColor;
    self.growingButton.layer.borderWidth = 3;
    [self.growingButton addTarget:self action:@selector(didTapGrowButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.growingButton];
    self.buttonSize = CGSizeMake(100, 100);
    return self;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
// 苹果推荐添加或或者更新约束的地方
- (void)updateConstraints {

    [self.growingButton updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(self.buttonSize.width)).priorityLow();
        make.height.equalTo(@(self.buttonSize.height)).priorityLow();
        make.width.lessThanOrEqualTo(self);
        make.height.lessThanOrEqualTo(self);
    }];
    
    // according to apple super should be called at end of method
    [super updateConstraints];
}

- (void)didTapGrowButton:(UIButton *)button {
    self.buttonSize = CGSizeMake(self.buttonSize.width * 1.3, self.buttonSize.height * 1.3);

    // tell constraints they need updating
    // 告诉约束系统要更新，系统会调用上面重写的updateConstraints方法
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change,
    // it will be call by system automatically
    // 该方法不必手动调用
    // [self updateConstraintsIfNeeded];

    // 可以用layoutIfNeeded来实现即时更新，还可以添加动画
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded]; // 需要在此处调用layoutIfNeeded方法才能产生动画
    }];
}
@end
```