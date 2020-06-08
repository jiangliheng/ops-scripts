# Log

* [clear-logs.sh](#clear-logs.sh)
  * [简介](#简介)
  * [概要](#概要)
  * [选项](#选项)
  * [示例](#示例)

## clear-logs.sh

### 简介
```
Filename         clear-logs.sh
Revision         0.0.1
Date             2020/06/05
Author           jiangliheng
Email            jiang_liheng@163.com
Website          https://jiangliheng.github.io/
Description      删除 N 天前的日志文件
Copyright        Copyright (c) jiangliheng
License          GNU General Public License
```

### 变更记录

* Version 0.0.1 2020/06/05
  * 删除 N 天前的日志文件，仅删除匹配  "*.log*"  的日志文件


### 概要

```
sh clear-logs.sh [options] <value> ...
```

### 选项
```
-p<value>                            删除日志的路径，必输参数
-d<value>                            删除 N 天前的日志文件，即保留 N 天日志，默认：7
--help                               帮助信息
-v, --version                        版本信息
```

### 示例
```
1. 清理 7 天前的日志文件
sh clear-logs.sh -p /home/nacos/logs
sh clear-logs.sh -p /home/nacos/logs -d 7

2. 清理 30 天前的日志文件
sh clear-logs.sh -p /home/nacos/logs -d 30
```
