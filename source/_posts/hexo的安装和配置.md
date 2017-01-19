---
title: Mac上 Hexo安装与配置
categories: hexo
tags: [hexo,博客]

---

### 安装
#### 1. 安装node.js[传送](https://nodejs.org/en/)
下载node的pkg包，点击直接安装，安装的过程下一步下一步就行了，新版的node.js包含有npm（npm用来安装hexo）
<!-----More----->
#### 2. 安装hexo
``` bash
$ sudo npm install -g hexo-cli
```

**注意：**如果没有用sudo来执行命令可能会出现错误

#### 3. 建立本地站点
现在本地创建一个文件夹，作为本地站点的根目录，例如建立一个HexoBlog文件夹，**cd到HexoBlog的上一级目录执行以下命令**

**1.初始化一个本地站点**

``` bash
hexo init HexoBlog
```

**2.进入站点根目录然后进行安装本地站点**

``` bash
cd HexoBlog
```

``` bash
npm install
```

**3.生成静态页面**

``` bash
hexo g
```

**4.启动本地站点服务器查看效果，执行本命令之后会提示出一个URL，将URL放入浏览器查看效果，按Ctrl+c关闭本地站点服务器**

``` bash
hexo server
```

### 配置
#### 1. 基本配置
**1.在github上创建一个仓库，仓库的名字必须为"github用户名.github.io"**

**2.如果你使用过github，我猜你已经配置好了SSH key,这里我就不多说了，不过即使没有配置SSH key也没关系，只是以后每次提交的时候会提示要求输入密码**

**3.修改站点_config.xml文件，如下：**

```
# Deployment
# Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git    #部署类型, 本文使用Git，发现使用github+SSH的方式会提示找不到github
  repository: https://github.com/SLPowerCoder/SLPowerCoder.github.io  #部署的仓库url,发现使用github+SSH的方式会提示找不到github
  branch: master   #部署分支,一般使用master主分支
```
**4.这些基本的配置完成之后就可以执行命令部署到github上了**

执行下面的命令，安装git部署插件，不然执行了 hexo deploy之后会没有反应，也没有任何提示部署失败，其实是失败的

``` bash 
$ npm install hexo-deployer-git --save
```

**5.执行下面命令，用于生成静态文件并部署到远程站点，你也可以分两步写**

``` bash 
$ hexo g -d
```

上述然后在浏览器中输入 github用户名.github.io就可浏览了

#### 2. 博客主题配置

```
# Hexo Configuration
## Docs: https://hexo.io/docs/configuration.html
## Source: https://github.com/hexojs/hexo/

# Site
title: 枫叶
subtitle: 枫叶
description: 坐看云起时
author: 枫叶
language: zh-Hans 
timezone:
email: sunlei_1030@126.com  # 邮箱


# URL
## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
url: https://slpowercoder.github.io
root: /
permalink: :year/:month/:day/:title/
permalink_defaults:

# Directory
source_dir: source
public_dir: public
tag_dir: tags
archive_dir: archives
category_dir: categories
code_dir: downloads/code
i18n_dir: :lang
skip_render:

# Writing
new_post_name: :title.md # File name of new posts
default_layout: post
titlecase: false # Transform title into titlecase
external_link: true # Open external links in new tab
filename_case: 0
render_drafts: false
post_asset_folder: false
relative_link: false
future: true
highlight:
  enable: true
  line_number: true
  auto_detect: false
  tab_replace:

# Category & Tag
default_category: uncategorized
category_map:
tag_map:

# Date / Time format
## Hexo uses Moment.js to parse and display date
## You can customize the date format as defined in
## http://momentjs.com/docs/#/displaying/format/
date_format: YYYY-MM-DD
time_format: HH:mm:ss

# Pagination
## Set per_page to 0 to disable pagination
per_page: 10
pagination_dir: page

# Disqus  disqus评论,  与多说类似, 国内一般使用多说
# disqus_shortname: 
duoshuo_shortname: fengye1030   # 这里添加多说评论


# Extensions
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: yelee  #默认是landscape 还有yelee,yilia等等

# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git    #部署类型, 本文使用Git，发现使用github+SSH的方式会提示找不到github
  repository: https://github.com/SLPowerCoder/SLPowerCoder.github.io  #部署的仓库url,采用https的,发现使用github+SSH的方式会提示找不到github
  branch: master   #部署分支,一般使用master主分支

```

### hexo的使用

**1.创建文章（也可以把创建好的md文件直接放到根目录source/_posts目录中）**

``` bash
$ hexo new "My New Post"
```
<!-----More------>
**2.清楚缓存的静态页面**

``` bash
$ hexo clean
```

**3.生成静态页面**

``` bash
$ hexo generate
```

**4.运行本地服务器查看效果**

``` bash
$ hexo server
```

**5.部署到远程站点**

``` bash
$ hexo deploy
```

### 参考文献
[hexo官网](https://hexo.io/)
