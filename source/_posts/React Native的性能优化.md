---
title: React Native的性能优化
date: 2018-06-27 22:58:51
categories: react-native
tags: [react-native]
---

### React Native的性能优化
众所周知RN由于应用了virtual DOM 、diff算法等一些列调优机制，使RN应用几乎达到了与原生一样的体验，但是毕竟RN只是原生APP的一个线程而已，RN和原生还隔着一道桥梁batch bridge，最终RN的代码还是要通过jscore引擎转换成原生代码来执行，这就决定了RN不可能超越原生，除非RN能越过这道坎，尽管官方替我们做了一些优化，但是有些优化只能交给了用户来决定，比如`sholdComponentUpdate`是返回true还是false，这是需要我们来决定的，再比如APP的页面如果非常多的话，打包之后bundle非常大，而加载和初始化bundle又很耗时间，这又需要拆分bundle，所以还是有许多需要人工来优化。

既然是性能优化那就肯定得找出RN的性能瓶颈在哪

### 一、基础优化（目的是尽量减少页面的渲染）

1. 比较吃性能的、耗时的操作可以放到`componentDidMount`中，然后再用`Interaction manager`在包裹一下，比如网络请求。
2. 尽量少用状态组件，尽可能用无状态组件，**无状态组件不会被实例化**，可以提升性能
3. 自定义的有状态组件尽量继承自`pure component`，这样系统会自动在`shouldComponentUpdate`中**默认做一层浅比较（直接拿两个对象做比较，对象中的子元素不做比较）**，可以减少一些不必要的渲染，当然你也也可以在该方法中做**深**层次的比较，如果组件不是继承自`PureComponent`则该方法默认返回true，这样会导致很多无用的渲染，比如父组件的改变会导致子组件的重新render。
4. 利用`immutable`不可变数据，提升性能，它可以避免本来应该渲染而实际却没有发生渲染的问题，因为框架默认在`shouldComponentUpdate`做的是一层浅比较，如果在state改变的过程中做的是浅拷贝，则state改变之前和改变之后是相等的，指向的是同一个对象，这样浅比较会认为state没有改变而不做渲染。
5. 对于同层级的相同类型的组件，要给每个组件指定唯一的key值。例如通常我们在一个容器组件中创建多个子组件的时候，我们会把这些子组件放在一个数组里，然后把数组直接放到容器页面中，形如下面的伪代码：

	```
	banner = ()=>{
		let childArr = [];
		while(let i < 10) {
			childArr.push(<Child key={XXXXXX}></Child>)
		}
		return <View> {childArr} </View>
	}
	```
	Child组件的key一定要有，这涉及到diff算法的原理，diff算法是按层级进行比较的，当前的virtual DOM 和之前的virtual DOM进行同层级比较的时候，对于属于同一个父组件的同一层级的子组件，**如果没有key值的话，RN需要遍历该父组件的所有子组件来行进对比，才能知道哪一个子组件发生了改变，这样如果子组件的数量很大的时候会很耗性能，RN有可能会因为遍历的耗时而选择放弃对比来重新渲染所有的子组件，但是如果有key值的话可以利用key直接进行两两比较**，效率就高出很多。
6. 列表优化，几乎所有的APP都有列表，所以列表的优化尤为重要，之前RN采用的是listView，数据稍微大的时候会出现明显卡顿，有性能瓶颈，最后RN在xxx版推出了新的列表神器`FlatList`和`SectionList`，他俩都是继承自`VirtualizedList`，比listView的性能更高，并且使用起来也更简单了，无需再想listView一样要先创建一个DataSource对象了。具体优化可以参考官网。。。
7. 用`FlatList`替换`scrollView`，因为在用`scrollView`的时候它会一下子把他上面的所有子组件都渲染出来，而`FlatList`可以设置首屏渲染的行数，这样就不会导致在刚进入这一页的时候出现卡顿现象。

### 二、本地分包优化
从官方给出的RN耗时图可以看出，最耗性能的地方是bundle包的**JS环境的初始化**和**加载**，所以这一块的优化也至关重要，bundle体积过大会导致加载慢，其中bundle包括**react等基础库以及引入的三方库** 和 **你自己的业务代码**，可以先从两方面着手。第一：需要尽可能的优化bundle的体积，去掉一些不必要的资源。第二：做拆分处理，把bundle拆分成`基础bundle`和`业务bundle`。 `基础bundle`是APP必须依赖的公共基础部分。其实拆分之后还是很耗时间，所以我们又做了另一种处理，那就是`预加载`，对`基础bundle`进行预加载，这样可以减少一些加载以及初始化的耗时。

总结如下：

1. **本地分包**： 把bundle拆分成`公共基础bundle`和`业务bundle`
2. **预加载**： 预加载`公共基础bundle`

### 三、按需延迟加载

可以通过`require`来实现动态延迟加载,伪代码如下：

```
import xxx from './xxxx'

let test2;

export default class Test extent Componnet {

	getTest2 = ()=>{
		// 对test2模块进行懒加载（延迟加载），以提高性能
		if(test2 === undefined) {
			test2 = require('./xxxx/test2');
		}
	}
}


```
我们不需要再这个test模块一开始就加载test2模块，这样可以延迟加载一些不是立马需要的其他模块，提升整体加载速度，降低内存。