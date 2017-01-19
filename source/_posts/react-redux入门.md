---
title: react-redux入门
categories: react-native
tags: [react-native,redux,react-redux]

---


## redux基础
### action
**Action** ：一般我们是不允许用户直接操作类的state，而是通过触发消息来执行对应的操作，用户或后台服务器通过store.dispatch()来向store发送一个消息（消息至少一个标识该消息的字段type，还可以添加其他字段用户数据传送），store会在内部根据消息的类型type去reducer中执行相应的处理，这个消息我们就叫他为Action，Action本质上是一个JavaScript对象。
<!-----More----->
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
随着程序越来越大，你会发现action太多太乱了，所以我们也会把action按业务分类放在各个指定的文件中，但是又有一个问题，若果每个action的字段都有五六个，我们在如下写法岂不是太乱了
```javascript
store.dispatch(
	{
  type: ADD_TODO,
  text: 'Build my first Redux app'
}
)
```
于是乎我们就想起来可以将action封装在函数中，这个函数返回一个action对象，这个返回一个action对象的函数我们就称之为ActionCreator，如下所示
```javascript
export let todo = ()=> {
    return {
	 	type: ADD_TODO,
  		text: 'Build my first Redux app'
	}
}
```
### reducer
**reducer** ：是一个纯函数，要求有相同的输入（参数）就一定会有相同的输出，它会根据旧的state和action来进行逻辑处理返回一个新的state
参数一：旧的state对象
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
**注意**：一定不要修改state，而是用Object.assign()函数生成一个新的state对象，如上所示


**combineReducers**：随着应用变得复杂，需要对 reducer 函数 进行拆分，拆分后的每一块独立负责管理 state 的一部分。combineReducers 辅助函数的作用是，把一个由多个不同 reducer 函数作为 value 的 object，合并成一个最终的 reducer 函数，然后就可以对这个 reducer 调用 createStore。合并后的 reducer 可以调用各个子 reducer，并把它们的结果合并成一个 state 对象。state 对象的结构由传入的多个 reducer 的 key 决定。

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
### store
**store**：一个应用只有一个store，store 就是用来维持应用所有的 state 树 的一个对象。 改变 store 内 state 的惟一途径是对它 dispatch 一个 action，它有三个函数
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
	
	
## redux-redux基础

**react-redux**:有两宝，provider和connect
**Provider**：有一个store属性，我们要将应用的根标签放到Provider标签中，这样应用的所有标签就可以通过context来获取store对象了，但是我们一般不会通过此法来获取store对象，Provider标签是为了给connect函数使用的。


**connect([mapStateToProps], [mapDispatchToProps], [mergeProps], [options])**

参数一：[mapStateToProps(state, [ownProps]): stateProps] (Function)
>如果定义该参数，组件将会监听 Redux store 的变化。任何时候，只要 Redux store 发生改变，mapStateToProps 函数就会被调用。该回调函数必须返回一个纯对象，这个对象会与组件的 props 合并。如果你省略了这个参数，你的组件将不会监听 Redux store。如果指定了该回调函数中的第二个参数 ownProps，则该参数的值为传递到组件的 props，而且只要组件接收到新的 props，mapStateToProps 也会被调用（例如，当 props 接收到来自父组件一个小小的改动，那么你所使用的 ownProps 参数，mapStateToProps 都会被重新计算）。

参数二：[mapDispatchToProps(dispatch, [ownProps]): dispatchProps] (Object or Function):
>如果传递的是一个对象，那么每个定义在该对象的函数都将被当作 Redux action creator，而且这个对象会与 Redux store 绑定在一起，其中所定义的方法名将作为属性名，合并到组件的 props 中。如果传递的是一个函数，该函数将接收一个 dispatch 函数，然后由你来决定如何返回一个对象，这个对象通过 dispatch 函数与 action creator 以某种方式绑定在一起（提示：你也许会用到 Redux 的辅助函数 bindActionCreators()）。如果你省略这个 mapDispatchToProps 参数，默认情况下，dispatch 会注入到你的组件 props 中。如果指定了该回调函数中第二个参数 ownProps，该参数的值为传递到组件的 props，而且只要组件接收到新 props，mapDispatchToProps 也会被调用

参数三：[mergeProps(stateProps, dispatchProps, ownProps): props] (Function)
>如果指定了这个参数，mapStateToProps() 与 mapDispatchToProps() 的执行结果和组件自身的 props 将传入到这个回调函数中。该回调函数返回的对象将作为 props 传递到被包装的组件中。你也许可以用这个回调函数，根据组件的 props 来筛选部分的 state 数据，或者把 props 中的某个特定变量与 action creator 绑定在一起。如果你省略这个参数，默认情况下返回 Object.assign({}, ownProps, stateProps, dispatchProps) 的结果。
[options] (Object) 如果指定这个参数，可以定制 connector 的行为。

参数四：[options] (Object) 如果指定这个参数，可以定制 connector 的行为。
>[pure = true] (Boolean): 如果为 true，connector 将执行 shouldComponentUpdate 并且浅对比 mergeProps 的结果，避免不必要的更新，前提是当前组件是一个“纯”组件，它不依赖于任何的输入或 state 而只依赖于 props 和 Redux store 的 state。默认值为 true。
[withRef = false] (Boolean): 如果为 true，connector 会保存一个对被包装组件实例的引用，该引用通过 getWrappedInstance() 方法获得。默认值为 false。

## redux-redux使用
### react native 组件的生命周期
![redux flow](http://7xqg0d.com1.z0.glb.clouddn.com/hexoBlog/react-native%E5%A3%B0%E6%98%8E%E5%91%A8%E6%9C%9F.PNG
)

### react-redux 数据流向
>redux是不允许用户来管理state的，而是交给redux管理，redux中有一个全局唯一的store来存放和管理state树。用户通过界面（或者网络请求等）来dispatch一个action，store接收到action后根据action的类型找到reducer中对应的逻辑进行数据处理，reducer处理后会返回一个新的state对象，然后程序根据store.subscribe订阅监听state的变化进行界面更新。

![redux flow](http://7xqg0d.com1.z0.glb.clouddn.com/hexoBlog/redux-flow.JPG
)

>react-redux是redux的作者为react native封装的一个库，原理和redux一样，只是使用起来更方便了。

*注：图片来源于互联网，如有侵权，请告知*
