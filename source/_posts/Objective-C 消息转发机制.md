---
title: Objective-C 消息转发机制
categories: iOS
tags: [消息转发]

---

一图胜千言，习惯性的先来一张图以便对消息转发有个整体的把握
### 运行时系统库方法查询流程图
![运行时系统库方法查询](http://upload-images.jianshu.io/upload_images/1229960-edd81dfe76dacf77.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
>对于对象无法处理的消息，如果不做转发处理的话，程序最终会调用NSObjective的doesNotRecognizeSelector:消息将程序crash掉。

### Objective-C提供了两种消息转发选项
* 快速转发：NSObject类的子类A可以通过重写NSObject类的forwardingTargetForSelector:方法，将A的实例无法识别的消息转发给目标对象B，从而实现快速转发。*该技巧就像是将对象的实现代码与转发对象合并到一起。这类似于实现的多继承行为。如果你有一个定了对象 能够消化哪些消息的目标类，这个技巧可以取得很好的效果*
* 标准（完整）转发：NSObject类的子类A可以通过重写NSObject类的forwardInvocation:方法，实现标准转发。标准转发巧可以通过methodSignatureForSelector：方法获取一个methodsignature对象最终被封为NSInvocation对象传递给forwardInvocation:方法（注意如果methodSignatureForSelector：方法返回一个nil，程序会crash）从该对象能获取消息的全部内容（包含目标，方法名，和参数）。

如果你拥有了一个定义了对象能够消化哪些消息的目标类，快速转发可以取得很好的效果。如果你没有这样目标类或想要执行其他处理过程（如记录日志并‘吞下’消息），就应该使用完整转发。

### 写了一大推字感觉很抽象，下面来点干货
下面我要把Test实例的logName消息转发给Target实例，代码如下
Test头文件
```
//
//  Test.h
//  ForwardMsg
//
//  Created by 孙磊 on 2017/2/25.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Test : NSObject

-(void)logName;

@end
```
Test实现文件

```
//
//  Test.m
//  ForwardMsg
//
//  Created by 孙磊 on 2017/2/25.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import "Test.h"
#import "Target.h"
#import <objc/runtime.h>

@implementation Test{
    Target *mTarget;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //创建目标对象
        mTarget = [Target new];
    }
    return self;
}

#if 0
//当一个对象无法识别消息后，会执行resolveInstanceMethod或者resolveClassMethod方法
//如果不想进行消息转发，可以在此方法中动态添加消息来做处理
//如果不重写此方法或者此方法返回NO，系统会执行forwardingTargetForSelector进行快速转发

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    
    if(sel == @selector(logName)){
        //第四个参数详解地址  https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        //v代表返回类型为void
        //@代表一个对象
        //:代表一个selector
        //因为OC中的每个方法都有默认的两个参数sel 和 selector，所以一般都是v@:
        class_addMethod([self class],sel,(IMP)dynamicMethodIMP,"v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//万年备胎
void dynamicMethodIMP(id self, SEL _cmd)
{
    //对无法识别的消息做处理
    NSLog(@"该对象无法识别 %@ 方法------%s", NSStringFromSelector(_cmd),__func__);
}

#else 

/***************==========1、快速消息转发，快速转发只可以获取到方法签名==========*******************/

-(id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"%s",__func__);
    if ([mTarget respondsToSelector:aSelector]) {
        //目标对象有对应的处理方法，则就会快速消息转发，不会再执行完整消息转发了
        return mTarget;
    }
    //目标对象也没有对应的方法，此时系统会执行forwardInvocation进行完整消息转发
    return nil;
}

/***********=============2、标准（完整）消息转发，完整消息转发，可以获取方法签名，参数等详细信息==========*********/

//返回一个完整的方法签名，提供给forwardInvocation以便完整转发消息
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    
     if (!signature)
        signature = [mTarget methodSignatureForSelector:aSelector];

     return signature;
}

-(void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"%s-----完整消息转发------",__func__);
    SEL invSEL = anInvocation.selector;
    if ([mTarget respondsToSelector:invSEL]){
        
        //利用forwardInvocation方法来重新指定消息处理对象
        [anInvocation invokeWithTarget:mTarget];
    }
    else {
        [self doesNotRecognizeSelector:invSEL];
    }
}

#endif

@end
```
目标文件的头文件
```
//
//  Target.h
//  ForwardMsg
//
//  Created by 孙磊 on 2017/2/25.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target : NSObject

-(void)logName;

@end

```
目标文件的实现文件
```
//
//  Target.m
//  ForwardMsg
//
//  Created by 孙磊 on 2017/2/25.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import "Target.h"

@implementation Target

-(void)logName{
NSLog(@"我是备用方法---%s",__func__);
}

@end

```

[推荐一个国外大大利用消息转发避免后台返回NSNull（后台有时候会返回<null>）而引起的奔溃问题，例如你需要一个字符串他却给你返回了一个“<null>”这样一个NSNull对象。用法很简单，直接把NullSafe.m拖到项目中即可，该文件会在运行时自动加载](https://github.com/nicklockwood/NullSafe)

扩展：简单说一下NULL，nil，Nil，NSNull的用处
NULL：用于普通类型，例如NSInteger
nil：用于OC对象（除了类这个对象）,给nil对象发送消息不会crash
Nil：用于Class类型对象的赋值（类是元类的实例，也是对象）
NSNull：用于OC对象的站位，一般会作为集合中的占位元素，给NSNull对象发送消息会crash的，后台给我们返回的<null>就是NSNull对象
