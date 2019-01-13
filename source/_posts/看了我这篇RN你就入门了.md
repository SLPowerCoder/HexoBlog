---
title: 看了我这篇RN你就入门了
date: 2016-12-30 16:44:51
categories: react-native
tags: [redux,react-redux,react-native]

---

## 前言
React认为每个组件都是一个有限状态机，状态与UI是一一对应的。我们只需管理好APP的state就能控制UI的显示，我们可以在每个component类中来通过`this.state`和`this.setState`来管理组件的state，但是如果APP交互比较多比较复杂，或者说该组件的某一状态需要和其他组件共享的话，这种方式就有点复杂了。
有没有一种能统一管理APP状态的框架呢，这时候Redux就应用而生了，它是一个用于统一管理APP 所有的state的一个的js框架，它不建议我们在component中直接操作state，而是交给redux的store中进行处理。而react-redux是在react的基础上为移动端定制的状态管理容器。

## redux的设计思想
`（1）Web 应用是一个状态机，视图与状态是一一对应的。`
`（2）所有的状态，保存在一个对象里面，由其统一管理。`
`（3）遵循严格的单项数据流，一个组件所需要的数据，必须由父组件传过来，而不能像flux中直接从store取。`
`（4）状态在组件中是‘只读’的，要交给redux处理`

## redux概念
有图有真相，先来一张redux数据流图，让你有一个整体的把握
![redux flow](http://upload-images.jianshu.io/upload_images/1229960-9cae53256b3bba52.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### action
一般是不允许用户直接操作类的state，而是通过触发消息来执行对应的操作来产生一个新的state，用户或后台服务器可以通过store.dispatch(action)来向store发送一个消息（消息至少一个标识该消息的字段type，还可以添加其他字段用于数据传送），store会在内部根据消息的类型type去reducer中执行相应的处理，这个消息我们就叫他为Action，Action本质上是一个JavaScript对象。

实际编码中一般会把整个应用的消息类型统一放在一个文件ActionTypes.js中

```javascript
export const ADD_TODO = 'ADD_TODO'
```
Action的结构如下，各个字段的key的名字可以随意命名，但是类型的key一般都是type，数据类型最好为字符串

```javascript
{
  type: ADD_TODO,
  text: 'Build my first Redux app'
}
```
随着程序越来越大，你会发现一个组件中的action太多太乱了，所以我们也会把action按业务分类放在各个指定的文件中，但是又有一个问题，若果每个action的字段都有五六个，我们在如下写法岂不是太乱了

```javascript
store.dispatch({
  type: ADD_TODO,
  text: 'Build my first Redux app'
})
```
于是乎我们就想起来可以将action对象封装在函数中，这个函数返回一个action对象，这个返回一个action对象的函数我们就称之为ActionCreator，如下所示

```javascript
export let todo = ()=> {
    return {
	 	type: ADD_TODO,
  		text: 'Build my first Redux app'
	}
}
```
我们直接store.dispatch(todo)就好了，看着是不是整洁多了啊
### reducer
它是一个纯函数，要求有相同的输入（参数）就一定会有相同的输出，它会根据当前的state和action来进行逻辑处理返回一个新的state
参数一：当前的state对象
参数二：action对象
返回值：产生一个新的state对象

```javascript
import { VisibilityFilters } from './actions'
//初始state
const initialState = {
  visibilityFilter: VisibilityFilters.SHOW_ALL,
  todos: []
};

function todoApp(state = initialState, action) {
  switch (action.type) {
    case SET_VISIBILITY_FILTER:
      return Object.assign({}, state, {
        visibilityFilter: action.filter
      })
    default:
      return state
  }
}
```
**注意**：reducer函数中一定不要去修改state，而是用Object.assign()函数生成一个新的state对象，如上所示


**combineReducers**：随着应用变得复杂，把APP的所有状态都放在一个reducer中处理会造成reducer函数非常庞大，因此需要对 reducer 函数 进行拆分，拆分后的每一个子reducer独立负责管理 APP state 的一部分。combineReducers 辅助函数的作用是，把多个不同子reducer 函数合并成一个最终的根reducer ，最后将根 reducer 作为createStore的参数就可以创建store对象了。合并后的 reducer 可以调用各个子 reducer，并把它们的结果合并成一个 state 对象。state 对象的结构由传入的多个 reducer 的 key 决定。

最终，state 对象的结构会是这样的：

```javascript
{
  reducer1: ...
  reducer2: ...
}
```
使用方法如下所示

```javascript
import { combineReducers } from 'redux';
import Strolling from './strollingReducer';
import Foods from './foodsReducer';
import FoodsList from './foodsListReducer';
import FoodCompare from './foodCompareReducer';
import FoodInfo from './foodInfoReducer';
import Search from './searchReducer';
import User from './userReducer';

export default rootReducer = combineReducers({
    Strolling,
    Foods,
    FoodsList,
    FoodCompare,
    FoodInfo,
    Search,
    User,
})

// export default rootReducer = combineReducers({
//     Strolling:Strolling,
//     Foods:Foods,  
//     FoodsList:FoodsList,
//     FoodCompare:FoodCompare,
//     FoodInfo:FoodInfo,
//     Search:Search,
//     User:User,
// })
 
// export default function rootReducer(state = {},action){

//     return{
//         Strolling: Strolling(state.Strolling,action),
//         Foods:Foods(state.Foods,action),
//         FoodsList:FoodsList(state.FoodsList,action),
//         FoodCompare:FoodCompare(state.FoodCompare,action),
//         FoodInfo:FoodInfo(state.FoodInfo,action),
//         Search:Search(state.Search,action),
//         User:User(state.User,action)
//     }
// }

//以上三种方式是等价的,key可以设置也可以省略
```
**注意：我们不一定非要用combineReducers来组合子reducer，我们可以自定义类似功能的方法来组合，state的结构完全由我们决定。**
### store
一个应用只有一个store，store 就是用来维持应用所有的 state 树 的一个对象。 改变 store 内 state 的惟一途径是对它 dispatch 一个 action，它有三个函数

* **getState()**
	返回应用当前的 state 树。
* **dispatch(action)**
	分发 action。这是触发 state 变化的惟一途径。
	会使用当前 getState() 的结果和传入的 action 以同步方式的调用 store 的 reduce 函数。返回值会被作为下一个 state。从现在开始，这就成为了 getState() 的返回值，同时变化监听器(change listener)会被触发。
* **subscribe(listener)**
	当state树发生变化的时候store会调用subscribe函数，我们可以传一个我们订制的函数作为参数来进行处理
	参数：一个函数
	返回值：返回一个解绑定函数
	```JavaScript
	//添加监听
	let unsubscribe = store.subscribe(handleChange)
	//解除监听
	unsubscribe()
	```
*  **replaceReducer(nextReducer)**
	替换 store 当前用来计算 state 的 reducer。
	这是一个高级 API。只有在你需要实现代码分隔，而且需要立即加载一些 reducer 的时候才可能会用到它。在实现 Redux 热加载机制的时候也可能会用到。
	
	
## react-redux基础
前言已经提到过react-redux的由来，这里在啰嗦一下，react-redux是redux作者专门为react native订制的，这样使用起来更方便，我们只需在我们的组件中通过属性props获取dispatch方法，就可以直接向store发送一个action，而不需要再获取store对象，通过store对象的dispatch方法发送。
react-redux有两宝，**provider**和**connect**，下面详细介绍一下。
####  Provider：
有一个store属性，我们要将应用的根标签放到Provider标签中，这样应用的所有标签就可以通过context来获取store对象了，但是我们一般不会通过此法来获取store对象，Provider是为了给connect函数使用的，这样才能通过connect函数的参数获取到store的state和dispatch了。

#### connect([mapStateToProps], [mapDispatchToProps], [mergeProps], [options])
connect是一个高阶函数，`connect()`本身会返回一个函数变量（假如名字为func），给这个函数变量传递一个参数func(MainContainer)会生成一个MainContainer容器组件，形如下面的写法：

```
export default connect((state) => {
    const { Main } = state;
    return {
        Main
    }
})(MainContainer);
```
参数一：[mapStateToProps(state, [ownProps]): stateProps] (Function)
>如果定义该参数，组件将会监听 Redux store 的变化。任何时候，只要 Redux store 发生改变，mapStateToProps 函数就会被调用。该回调函数必须返回一个纯对象，这个对象会与组件的 props 合并。如果你省略了这个参数，你的组件将不会监听 Redux store。如果指定了该回调函数中的第二个参数 ownProps，则该参数的值为传递到组件的 props，而且只要组件接收到新的 props，mapStateToProps 也会被调用（例如，当 props 接收到来自父组件一个小小的改动，那么你所使用的 ownProps 参数，mapStateToProps 都会被重新计算）。

参数二：[mapDispatchToProps(dispatch, [ownProps]): dispatchProps] (Object or Function):
>如果传递的是一个对象，那么每个定义在该对象的函数都将被当作 Redux action creator，而且这个对象会与 Redux store 绑定在一起，其中所定义的方法名将作为属性名，合并到组件的 props 中。如果传递的是一个函数，该函数将接收一个 dispatch 函数，然后由你来决定如何返回一个对象，这个对象通过 dispatch 函数与 action creator 以某种方式绑定在一起（提示：你也许会用到 Redux 的辅助函数 bindActionCreators()）。`如果你省略这个 mapDispatchToProps 参数，默认情况下，dispatch 会注入到你的组件 props 中。`如果指定了该回调函数中第二个参数 ownProps，该参数的值为传递到组件的 props，而且只要组件接收到新 props，mapDispatchToProps 也会被调用。

参数三：[mergeProps(stateProps, dispatchProps, ownProps): props] (Function)
>如果指定了这个参数，mapStateToProps() 与 mapDispatchToProps() 的执行结果和组件自身的 props 将传入到这个回调函数中。该回调函数返回的对象将作为 props 传递到被包装的组件中。你也许可以用这个回调函数，根据组件的 props 来筛选部分的 state 数据，或者把 props 中的某个特定变量与 action creator 绑定在一起。如果你省略这个参数，默认情况下返回 Object.assign({}, ownProps, stateProps, dispatchProps) 的结果。
[options] (Object) 如果指定这个参数，可以定制 connector 的行为。

参数四：[options] (Object) 如果指定这个参数，可以定制 connector 的行为。
>[pure = true] (Boolean): 如果为 true，connector 将执行 shouldComponentUpdate 并且浅对比 mergeProps 的结果，避免不必要的更新，前提是当前组件是一个“纯”组件，它不依赖于任何的输入或 state 而只依赖于 props 和 Redux store 的 state。默认值为 true。
[withRef = false] (Boolean): 如果为 true，connector 会保存一个对被包装组件实例的引用，该引用通过 getWrappedInstance() 方法获得。默认值为 false。

## redux-redux使用
上面说了provider和connect方法，下面是实用讲解

创建store对象的js文件

下面的代码里包括应用中间件redux-thunk，和创建store对象两步，[这里有更多关于中间件的详情](http://www.ruanyifeng.com/blog/2016/09/redux_tutorial_part_two_async_operations.html)

```
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from '../reducers/rootRudcer';
//使用thunk中间件
let createStoreWithMiddleware = applyMiddleware(thunk)(createStore);
//创建store对象，一个APP只有一个store对象
let store = createStoreWithMiddleware(rootReducer);
export default store;

```

程序的入口文件

```
import React from 'react';
import { Provider } from 'react-redux';
import store from './store/store';

import App from './containers/app';

export default class Root extends React.Component {
    render() {
        return (
        	//将APP的根视图组件包含在provider标签中
            <Provider store = {store} >
                <App />
            </Provider>
        )
    }
}
```

在容器组件中，将redux和容器组件关联起来，这里是redux与组件关联的地方，大多数童鞋使用redux最迷惑的地方估计就在这一块了。

```
import React from 'react';
import {connect} from 'react-redux';
import Brand from '../Components/Brand';

//BrandContainer容器组件
class BrandContainer extends React.Component {
    
    render() {
        return (
        	//把容器组件的属性传递给UI组件
            <Brand {...this.props} />
        )
    }
}

export default connect((state) => {
    const { BrandReducer } = state;
    return {
        BrandReducer
    }
})(BrandContainer);
```

这样UI组件Brand中就可以通过属性获取dispatch方法以及处理后的最新state了

```
const {dispatch, BrandReducer} = this.props;
```

下面来解释一下上面的代码

将当前的BrandContainer组件关联起来，上面介绍了store中的state对象的结构会是这样的：

{<br/>
  reducer1: ...<br/>
  reducer2: ...<br/>
}

所以可以通过解构的方式，获取对应模块的state，如下面的const { BrandReducer } = state;

下面这一块代码的作用就是将store中state传递给关联的容器组件中，当store中的state发生变化的时候，connect的第一参数mapStateToProps回调函数就会被调用，并且将该回调函数的返回值映射成其关联组件的一个属性，这样容器组件的属性就会发生变化，而UI组件又通过{...this.props}将容器组件的属性传递给了UI组件，所以UI组件的属性也会发生变化，我们知道属性的变化会导致UI组件重新render。好了，我们就能知道为什么我们在UI组件中dispatch一个action后UI组件能更新了，因为UI组件的属性发生变化导致RN重绘了UI。

## react native 组件的生命周期
### 弄明白了这个图我认为你就能基本掌握RN了
![react-native lifecircle](https://github.com/SLPowerCoder/SLPowerCoder.github.io/blob/master/uploads/react-native%E5%A3%B0%E6%98%8E%E5%91%A8%E6%9C%9F.PNG?raw=true)
注意：上图的最右边componentWillMount改成componentWillUnmount
### 项目的推荐目录
这种结构适合业务逻辑不太复杂的中小型项目，其优点是逻辑模块清晰，缺点是文件目录跨度较大，对于大型项目建议按项目的功能模块来划分。
![项目的推荐目录](http://upload-images.jianshu.io/upload_images/1229960-e38436556eda2e19.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 热更新
暂时不说了，苹果粑粑这两天不高兴了，凡是热更新的APP不能上架，已上线的APP也应该收到了一份批评邮件了。
![你尽管hot patch吧](http://upload-images.jianshu.io/upload_images/1229960-24ed9d2bcfd08bde.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 相关文章
[React 实践心得：react-redux 之 connect 方法详解](http://www.tuicool.com/articles/MrmYN36)
[Redux 入门教程（一）：基本用法](http://www.ruanyifeng.com/blog/2016/09/redux_tutorial_part_one_basic_usages.html)
[redux中文文档](http://www.redux.org.cn/)

*注：部分图片来源于互联网*

[原文链接，转载请注明此链接](https://slpowercoder.github.io/2016/12/30/一名iOSer对react-redux的理解/)