---
title: Block深入理解
categories: iOS
tags: [block]

---
## block 你应该了解的知识
为什么不把本部分放到本质部分的下面呢，我以为实用为大，还是先把block的使用及其注意点写在前面吧。

1、为了方便声明block类型的变量，我们一般用typedef `typedef void (^Block)(void)`给block类型起个别名，这样我们就可以直接按如下方式声明block变量了。

```
typedef void (^Block)(void);
int main(int argc, const char * argv[]) {
//这样声明
Block block = ^{};
//而不是这样
//void(^block)(void)=^{};

return 0;
}
```
2、在非ARC情况下，定义块的时候（无论是全局块还是局部块），其所占的内存区域是分配在栈中的。如下声明了一个block，如下面的代码就有危险，在条件语句实现的两个block都分配在栈内存中，于是这两个块只在对应的条件语句范围内有效，这样写的代码可以编译，但是运行起来却是时而对时儿错，若编译器未复写待执行的块，则程序正常运行，若复写则程序奔溃。

```
void (^block)();
if(/*some condition*/){
block = ^{
NSLog(@"Block A");
};
}else{
block = ^{
NSLog(@"Block B");
};
}
block();
```
应该按这样的姿势写

```
void (^block)();
if(/*some condition*/){
block = [^{
NSLog(@"Block A");
} copy];
}else{
block = [^{
NSLog(@"Block B");
} copy];
}
block();
```

3、同理2，将block声明为属性的时候，要用copy，还要注意如果你不确定你生命的这个block属性会不会被其他线程修改，你就用atomic加个原子锁，这样就线程安全了

```
@property (copy) Block block; //属性默认就是atomic

```

4、调用block的时候，有些童鞋的姿势不太对，假如我声明了一个block属性，正确调用姿势如下

```
Block block  = self.block;
if(block){
block();
}
```
大部分童鞋会按下面这样写，那些连判断都不做的童鞋我就不批评你了，回去面壁去

```
if(self.block){

//我是其他线程，我要这里要捣乱

block();
}

```

上面的写法为什么不妥呢，因为即使self.block当时存在，如果另一个线程在该线程执行到我注释的那一行的时候把block置空了咋办，你再调用是不是就得到了一个完美的闪退，但是我如果把self.block 赋值给了一个局部变量的话，其他线程修改的是self.block而修改不了这个零时变量，所以上面的那种姿势不太稳妥。如果你看过AF的源码你就会发现，歪果仁就是按着我说的上面的正确姿势写的。

5、为什么用了__block就可以修改所截获的变量了？

因为block的特性，编译器不允许在block内直接修改所捕获的变量，但是我们可以修改`__block`修饰的自动变量，因为用`__block`修饰过之后，原先存储在栈中的变量就变成了存在堆中了，查看用clang过后的cpp文件你会发现在block中多了一个与该变量同名的`__Block_byref_i_0`结构体的指针变量，其中包含了存储在堆中的那个变量，可以通过结构体指针变量来直接更改变量的值，而没有用`__block`修饰的变量，block会把截获的变量copy为自己的一个变量。

6、避免循环引用，如果你把一个block声明成了对象的一个属性，那么该对象就会持有这个block，如果在该对象中要实现block属性的话，用到self的时候要用__weak修饰过的，不然会循环引用。

7、block的存储位置，栈、堆、全局数据区（强调一下如非特殊说明，block都是函数中实现）
block是否截获外围变量会影响他的存储区域的。

7.1 下图是ARC模式下执行的代码
![ARC下的block.png](http://upload-images.jianshu.io/upload_images/1229960-46005086cdd8bc09.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000)
7.2 下图是非ARC模式下执行的代码
![MRC下的block.png](http://upload-images.jianshu.io/upload_images/1229960-5c079f6944335315.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000)

解释一下上面的结果，学过C的都知道，malloc是分配到堆中了，global是分配到全局数据区了。

7.3.1 MRC下此种写法Xcode会报错，但是如果不引用外围变量的话就没事，如果你仔细看7.1与7.2的介绍，你就知道原因了，不过我还是想说一下。因为在MRC情况下引入外围变量时，此种写法的block存在栈里面，而该函数的却返回了block，return标志着一个函数的结束，所以在return的时候block会被释放而报错，在MRC情况下不引入外围变量的话，此种写法的block存在全局数据区里，所以没问题。

![MRC下此种写法报错.png](http://upload-images.jianshu.io/upload_images/1229960-925bdc8941a771d5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)
7.3.2 ARC下，无论引不引入外围变量，都没事，不引入返回的block存在全局数据区，引入的话存在堆中。就不截图了。

7.4 下面这种情况，ARC与MRC下block都存储在全局数据区，这种情况不常出现，一般我们都是在函数中来是实现block的。

![ARC与MRC下都存储在全局数据区.png](http://upload-images.jianshu.io/upload_images/1229960-e11c0f8b876f7297.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000)

7.5 总结（强调一下如非特殊说明，block都是函数中实现）：

**ARC模式下：**不论你声明的是局部block还是全局block，它们只要不截获外围变量，它们都会存储在全局数据区的，如果截获外围变量，block就会存储在堆（heap）中。

**非ARC模式下：**不论你声明的是局部block还是全局block，它们只要不截获外围变量，它们都会存储在全局数据区的，如果截获外围变量，block就会存储在栈(stack)中。

**两种模式下的差别：**只要不截获外围变量block一律都存在全局数据区，只有截获了外围变量ARC和MRC才有所区别，而开发中往往我们的block都是后面这么一个情况，现在很少有人使用非ARC了吧，所以还是关注ARC的情况吧，即你只需要记住结论的第一条就好了。

## block 的本质
block其本质是一个struct，也可以说是一个含有[自动变量](http://www.cnblogs.com/candyming/archive/2011/11/25/2262826.html)的匿名函数，通过clang编译器转换成C++代码可以看出，执行`clang -rewrite-objc 要转换的OC文件`命令，可以在同级目录下获得一个.cpp文件，里面就是转换后的OC代码，下面我会分三种情况给出OC代码及其对应的cpp代码。

1、只是纯粹的在入口函数中定义了一个block，block中也没有引入外围变量

```
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {

void(^block)(void)=^{
NSLog(@"Block!!");
};
block();

return 0;
}
```
下面是转换后的C++代码，为了方便观察，我把文件最下方的有关block的代码摘录如下

``` 
//block的结构体
struct __main_block_impl_0 {
//block的实现
struct __block_impl impl;
//block的描述（包含block的大小以及copy，dispose等）
struct __main_block_desc_0* Desc;
//block的构造函数，对block结构体成员变量的初始化
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
impl.isa = &_NSConcreteStackBlock;
impl.Flags = flags;
impl.FuncPtr = fp;
Desc = desc;
}
};

//block内的代码实现部分
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

NSLog((NSString *)&__NSConstantStringImpl__var_folders_1q_hr0kg_v15rj7ry_618ljfldr0000gn_T_hellow_a5b27a_mi_0);
}

//block的描述，包含block的大小以及copy，dispose
static struct __main_block_desc_0 {
size_t reserved;
size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

//OC中的main函数
int main(int argc, char * argv[]) {

void(*block)(void)=((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
return 0;
}

```
2、在入口函数中定义了一个block，并在block中引入外围整型变量i

```
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {

//自动变量i
int i = 10;
void(^block)(void)=^{

NSLog(@"Block!!---%d",i);
};
block();

return 0;
}
```
转换后的cpp代码

```
struct __main_block_impl_0 {
struct __block_impl impl;
struct __main_block_desc_0* Desc;
//这是block捕获的变量
int i; 
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _i, int flags=0) : i(_i) {
impl.isa = &_NSConcreteStackBlock;
impl.Flags = flags;
impl.FuncPtr = fp;
Desc = desc;
}
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
int i = __cself->i; // bound by copy
NSLog((NSString *)&__NSConstantStringImpl__var_folders_1q_hr0kg_v15rj7ry_618ljfldr0000gn_T_main_1b12e5_mi_0,i);
}

static struct __main_block_desc_0 {
size_t reserved;
size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

int main(int argc, const char * argv[]) {

int i = 10;
void(*block)(void)=((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, i));
((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);

return 0;
}
```
3、在入口函数中定义了一个block，并在block中引入外围整型变量i，并且i用__block修饰

```

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {

__block int i = 10;
void(^block)(void)=^{
i += 1;
NSLog(@"Block!!---%d",i);
};
block();

return 0;
}
```
转换后的cpp代码

```
//存储block截获的外围变量的一个结构体
struct __Block_byref_i_0 {
void *__isa;
__Block_byref_i_0 *__forwarding;
int __flags;
int __size;
int i;
};

struct __main_block_impl_0 {
struct __block_impl impl;
struct __main_block_desc_0* Desc;
//这是block捕获的变量
__Block_byref_i_0 *i; // by ref
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_i_0 *_i, int flags=0) : i(_i->__forwarding) {
impl.isa = &_NSConcreteStackBlock;
impl.Flags = flags;
impl.FuncPtr = fp;
Desc = desc;
}
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
__Block_byref_i_0 *i = __cself->i; // bound by ref

(i->__forwarding->i) += 1;
NSLog((NSString *)&__NSConstantStringImpl__var_folders_1q_hr0kg_v15rj7ry_618ljfldr0000gn_T_main_10e8d1_mi_0,(i->__forwarding->i));
}

//下面两个指针函数是__main_block_desc_0结构体中的函数指针的实现，前者是要保留block截获的对象，后者则将之释放

static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->i, (void*)src->i, 8/*BLOCK_FIELD_IS_BYREF*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->i, 8/*BLOCK_FIELD_IS_BYREF*/);}

//block的描述
static struct __main_block_desc_0 {
size_t reserved;
size_t Block_size;
void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

//主函数
int main(int argc, const char * argv[]) {

__attribute__((__blocks__(byref))) __Block_byref_i_0 i = {(void*)0,(__Block_byref_i_0 *)&i, 0, sizeof(__Block_byref_i_0), 10};
void(*block)(void)=((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_i_0 *)&i, 570425344));
((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);

return 0;
}
```
第一种和第二种比较可知，当block截获外围变量时，block会把截获的变量注册成为自己的成员变量，这也是为什么block不能直接修改截获的变量的原因，因为在block内操作的外围变量其实是block的同名的成员变量。

第一种和第三种比较可知，当block截获外围变量时，block会把截获的变量封装成`__Block_byref_i_0`结构体，并把结构体指针变量注册为自己的成员变量。

被`__block`修饰的外围变量会变成堆变量，这样这个外围变量就不会随函数的结束而被释放了，`__Block_byref_i_0`结构体i指针变量中有一个指向自己的`__forwarding`指针，通过`i->__forwarding->i`来修改存在堆中的外围变量。
