---
title: 运行react native 官方例子出错的解决办法
categories: react-native
tags: [react-native]

---

学习一样新的东西官网文档和官方源码例子无疑是最好的选择，所以今天clone了官方的例子，100多兆，如果网速不好的话会等待很长时间 ~_~!!，然后直接cd到根目录执行了npm install安装了依赖，可是安装的过程中出错了（也有可能安装成功了，但是运行失败了），估计例子上的版本跟我安装的rn版本不兼容吧。
我目前的RN版本是0.39，命令行的版本是react-native-cli:2.0.1

先上官方运行效果图：
![官方效果图](http://upload-images.jianshu.io/upload_images/1229960-edb9d9b477259960.gif?imageMogr2/auto-orient/strip)
### 解决办法：
情况一：如果npm install安装失败的话<br/>
1、git checkout 0.xx-stable切换到稳定的分支，我切换的是0.41-stable版本，安装运行成功。<br/>
2、npm install<br/>
3、找到Examples，里面有四个例子，可以用Xcode打开运行<br/>

情况二：npm install 安装成功，但运行失败<br/>
1、git checkout 0.xx-stable切换到稳定的分支<br/>
2、fm -rf node_modules && npm install<br/>
3、找到Examples，里面有四个例子，可以用Xcode打开运行<br/>
