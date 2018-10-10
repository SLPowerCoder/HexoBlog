---
title: iOS中为什么非要用runtime才能在分类中扩展属性呢
categories: iOS
tags: [runtime,category]

---
想必大家都知道在分类中能扩展属性，而对于能不能扩展属性，能不能扩展成员变量是不是有点模糊，今天元宵节，我就清清嗓子说上两句吧

##### 论点
1.分类中是能扩展属性的
2.分类是不能给一个类扩展成员变量的

##### 先唠唠嗑
强调一下，分类不是类，它只是对类的一个扩展，没有ISA指针，我们知道我们可以通过runtime在不影响原来模块的情况下给模块扩展方法，有没有感觉这一句话好像也可以描述分类，*所以你可以认为分类是实现这一功能的捷径*，不然你觉得是用分类扩展方法容易还是用runtime来实现容易啊（正值年轻，说话有点冲~_~ !!）。
##### 论据
先说说属性，属性是对成员变量的一个封装，当我们声明一个属性的时候，Xcode会给我们默认创建一个 **_属性名** 的成员变量，也会给我们自动创建getter和setter方法。当然我们也可以用@synthesize指定其关联的变量
例如给属性name指定其关联的变量`@synthesize name = xxx；self.name`其实是操作的实例变量xxx，而不是_name了。
窝草，扯远了，回归正传。。
所以我们要添加一个属相得有三样东西，setter、getter以及关联的成员变量。
在分类中Xcode不会为我们自动创建setter、getter方法，我们可以手动实现，但是如何把一个变量关联到属性上呢，直接声明一个全局变量然后不行吗，事实证明不太行，对于getter方法还好说，直接返回一个变量就行，可是setter方法却不行，因为你要找到该属性关联的变量你才能给人家赋值啊，怎么办？怎么办？？这只能用runtime的对象关联来实现了

```OC 
.m文件中
// 定义关联的key
static const char *key = "name";

@implementation NSObject (Property)

- (NSString *)name
{
  // 根据关联的key，获取关联的值。
  return objc_getAssociatedObject(self, key);
}

- (void)setName:(NSString *)name
{
  // 参数一：目标对象
  // 参数二：关联的key，可以通过这个key获取
  // 参数三：关联的value
  // 参数四：关联的策略
  objc_setAssociatedObject(self, key, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
```
看到这里你也许就会说，这TMD不是把变量给添加上去了吗？我表示默默一笑，如果你打印IVarList你就会发现并没有这个变量，只能打印出添加的属性。
其实**对象关联**只是关联上去了，并没有把变量添加进去，说了这么多这回你该信了吧。
***原因就是分类不是类，他没有ISA指针，下面是ISA指针，可以看出他本质上是一个结构体（只是换了个马甲被称之为Class类型，怕你迷糊，再说明白一点，ISA指针就是Class类型），通过ISA指针才能找指向变量的ivars，也就是说你都不知道变量的家，你怎么去给它生猴子啊，但是奇怪了，ISA指针里没有指向属性数组的指针，没有是对的，要不然这一段的解释就废了，可是讲真，属性指针在哪啊？？？有知道的小伙伴请告诉我一下 >_< !!!***

```OC
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;
    const char *name                                         OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
/* Use Class instead of `struct objc_class *` */
```
##### 结论
分类中可以给一个对象（类也是对象）添加属性，但是不能添加成员变量，只能**关联**上去。
**注意：**如果不信，你可以自己再打印一遍吧，会发现只能打印出添加的属性，打印不出变量。
