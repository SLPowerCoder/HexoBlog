---
title: react native集成到原有的项目中(iOS)
date: 2017-05-02 00:44:35
categories: react-native
tags: [react-native]

---
接触RN也有一段时间了，基本上来说算是入门了，到目前RN的应用还没有达到期望的广泛度，大部分还是以原生+RN的方式进行混合开发，今天抽空写一下关于RN嵌入到iOS原生项目中的知识点。

### 前期准备
现在大部分嵌入方式都是采用cocoapods的方式引入RN依赖库到原生项目中，当然你也可以选择手动方式，不过很麻烦，本文采用的cocoapods来管理依赖。
RN所需要的环境也要装好，[中文网有](http://reactnative.cn/docs/0.43/getting-started.html#content)，具体我就不说了

### 集成
用Xcode创建一个项目，然后在项目中创建一个目录，把RN相关的都放在里面，如下图，我创建了一个js目录（这个目录你也可以放到iOS项目的根目录，任意）。
![示例.png](http://upload-images.jianshu.io/upload_images/1229960-a6e617a8586a6cfa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
然后cd到刚刚创建的js目录中，执行`npm init`，这时js目录中会多出一个package.json文件，这个文件和iOS中的Podfile类似，是用来记录着RN工程中要安装的依赖，目前你只需要关注dependencies这一项(把下面的内容覆盖到你生成的package.json文件中)，该项中记录着RN项目要安装的依赖库。

```javascript
{
  "name": "MixRNAndIOS",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "node node_modules/react-native/local-cli/cli.js start",
    "test": "jest"
  },
  "dependencies": {
    "react": "15.3.2",
    "react-native": "^0.36.1"
  },
  "jest": {
    "preset": "jest-react-native"
  },
  "devDependencies": {
    "babel-jest": "16.0.0",
    "babel-preset-react-native": "1.9.0",
    "jest": "16.0.2",
    "jest-react-native": "16.0.0",
    "react-test-renderer": "15.3.2"
  }
}

```
紧接着我们用npm包管理器来安装RN的依赖库，还是在js目录执行`npm install`,安装完毕之后，js目录会多出一个名为node_modules文件夹，RN所必须依赖的库都在这里面，然后我们创建一个index.ios.js作为RN项目的入口文件（名字可以任意起），然后我们就可以在入口文件中愉快的写RN代码了。

上面的步骤顺利执行完之后，RN项目已经完成了，现在我们要把RN集成到iOS原生项目中。

在项目根目录创建一个Podfile文件，如下所示，在项目的根目录执行pod install 来安装Podfile中指定的依赖库。

```Objective-c
# The target name is most likely the name of your project.
target 'MixRNAndIOS' do

  # Your 'node_modules' directory is probably in the root of your project,
  # but if not, adjust the `:path` accordingly
  pod 'React', :path => ‘./MixRNAndIOS/js/node_modules/react-native', :subspecs => [
    'Core',
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket', # needed for debugging
    # Add any other subspecs you want to use in your project
    'RCTImage',
  ]

end
```

**注意：**Podfile文件中的path路径
用pod安装完iOS所依赖的RN库之后我们就可以着手集成RN了。

RN为我们在iOS平台上提供了一个RCTRootView，RCTRootView是继承自iOS中UIView类，所以你可以像使用UIView一样使用RCTRootView，RN与iOS的交互都要在RCTRootView中进行，本篇文章先不讲交互的事，只讲集成，先把代码贴上，如下所示：


``` Objective-c
import "ViewController.h"
import "RCTRootView.h"

@interface ViewController ()

@property (nonatomic, strong) NSDictionary *props;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.props =   @{ @"param" : @[
                                @{
                                  @"name" : @"Alex",
                                  @"des": @"hello，我是从原生传递给RN界面的参数"
                                  }
                              ]
                      };
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bounds.size.width - 300)/2, 200, 300, 40)];
    [btn setTitle:@"点我进入react native界面" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(highScoreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)highScoreButtonPressed{
    NSURL *jsCodeLocation;
    
#ifdef DEBUG
    //开发的时候用，需要打开本地服务器
    jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios"];
#else
    //发布APP的时候用
    jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"jsbundle"];
#endif
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL : jsCodeLocation
                                                 moduleName        : @"RNHighScores"
                                                 initialProperties : self.props  //将native数据传送到RN中
                                                 launchOptions     : nil];
    
    rootView.frame = [UIScreen mainScreen].bounds;
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor redColor];
    [vc.view addSubview:rootView];
    [self presentViewController:vc animated:YES completion:nil];
}
```
创建RCTRootView，将RCTRootView添加到VC中的view上就OK了
`jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"jsbundle"];`
这一行你先忽略，后面会说。
然后cd到js目录，执行`react-native start`或者执行`npm start`，来启动本地node服务器，如果没有错误的话我们就只需最后一步了，用Xcode打开项目，运行项目，大功告成。

#### 打RN离线包
此时我们的项目是依赖于刚刚启动的本地服务器的，要是上线怎么办，所以我们需要打个RN离线包，这样就可以摆脱本地服务器了。
进入js目录，创建一个bundle目录，这里面存放打包后的RN资源，包括RN代码和图片等静态资源，在js目录里执行下面的打包命令，
```
react-native bundle --entry-file ./index.ios.js --bundle-output ./bundle/index.ios.jsbundle --platform ios --assets-dest ./bundle --dev false
```
如果成功的话，在bundle目录下会生成存放RN静态资源的assert目录和RN的index.ios.jsbundle代码文件，将这俩家伙拖进Xcode中

![拖.png](http://upload-images.jianshu.io/upload_images/1229960-9acc384414a84b12.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
**注意：**要以引用的方式拖进Xcode中。

在文章的集成部分我粘贴了一大段代码，源代码中有两句代码用来生成RN资源的URL，第一句是依赖本地服务器的，一般调试RN代码时用，第二句是引入打包后的RN资源的URL，发布APP的时候用的，我用宏来进行控制。
```
jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"jsbundle"];
```

**注意：**假如我们把第一种获取URL的方式注释掉，宏也注释掉，如果iOS项目是DEBUG模式，而我们加载的明明是RN的离线包，你会发现从原生页面跳转到RN页面的时候，顶部的statusBar会有加载资源的进度显示，不要纠结，运行项目的时候改成release模式就好了，来张效果图。

友情提示，在RN中想引入iOS中Assets.xcassets里面的图片的话可以直接写图片的文件名，如下面这样。
```
<Image source={{uri:'happiness.jpg'}} style={styles.happy}/>
```
![ReactNativeDemo.gif](http://upload-images.jianshu.io/upload_images/1229960-b6bb0e112ce45465.gif?imageMogr2/auto-orient/strip)
