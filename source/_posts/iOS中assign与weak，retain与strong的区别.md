---
title: iOS中assign与weak，retain与strong的区别
categories: iOS
tags: [assign,weak,retain,strong]

---
>以前在没有ARC的时候我们使用assign与retain来修饰属性，后来引入了更安全的weak和strong来修饰属性

* assign与weak
两者都是弱引用，assign通常用于普通类型属性（如int,NSInteger），还有代理属性的修饰，基本上来说两者是可以通用的。
只是后者比前者多了一个功能，后者会在引用被释放的时候将该属性置为nil，而前者就会变成野指针（或者空对象）。在oc中你给你一个nil对象发送消息不会crash，但是给一个空对象发送消息是会crash的，所以总的来说weak要比assign安全一些。
<!-----More----->
* retain和strong
他俩都是强引用，除了某些情况下不一样，其他的时候也是可以通用的。
在修饰block属性的时候，相信大家都知道要用copy吧，因为如果不copy的话，block是存放在栈连里面的，他的生命周期会随着函数的出栈而结束的，copy之后会放在堆里面。
strong在修饰block的时候就相当于copy，而retain修饰block的时候就相当于assign，这样block会出现提前被释放掉的危险。