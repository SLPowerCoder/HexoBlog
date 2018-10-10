#!/bin/sh
cd /Users/sunlei/Documents/HexoBlog
echo 请输入文章名称[不带后缀 .md]：
read blogName 
sudo hexo new $blogName
sudo hexo clean
sudo hexo g #生成静态文件
sudo hexo server
#sudo open -a "/Applications/Safari.app" http://localhost:4000/

