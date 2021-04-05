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
Revision         0.0.3
Date             2020/06/05
Author           jiangliheng
Email            jiang_liheng@163.com
Website          https://jiangliheng.github.io/
Description      删除 N 天前的日志
Copyright        Copyright (c) jiangliheng
License          GNU General Public License
```

### 变更记录

* Version 0.0.3 2020/07/28
  * 增加 支持仅匹配目录类型，默认是查询每个文件并删除

* Version 0.0.2 2020/07/21
  * 优化 支持正则表达式匹配日志文件
  * 增加 支持配置多目录清理
  * 增加 支持调试模式


* Version 0.0.1 2020/06/05
   * 删除 N 天前的日志文件，仅删除匹配  "*.log*"  的日志文件

### 概要

```
sh clear-logs.sh [options] <value> ...
```

### 选项
```
* -p <value>                 删除日志的路径，多个目录用 "," 隔开，如："/logs1,/logs2"
  -d <value>                 删除 N 天前的日志文件，即保留 N 天日志，默认：7
  -e <value>                 正则表达式匹配日志文件，如："*.log*"
  -D                         仅匹配目录类型，默认是查询每个文件并删除，即 find 命令增加 “-type d” 参数
  -t                         调试模式，控制台打印日志，不删除日志文件
  --help                     帮助信息
  -v, --version              版本信息

  * 表示必输，& 表示条件必输，其余为可选
```

### 示例
```
1. 清理多个目录中 7 天前的日志文件
sh clear-logs.sh -p /home/nacos/logs,/home/nacos/nacos/logs
sh clear-logs.sh -p /home/nacos/logs,/home/nacos/nacos/logs -d 7

2. 清理 30 天前的日志文件
sh clear-logs.sh -p /home/nacos/logs -d 30

3. 清理 30 天前的匹配正则表达式的日志文件，调试模式
sh clear-logs.sh -p /home/nacos/logs -d 30 -e "*.log*" -t

4. 清理 30 天前的日志目录，调试模式
sh clear-logs.sh -p /home/nacos/logs -d 30 -D -t
```
