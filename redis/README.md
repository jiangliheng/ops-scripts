# Redis

* [redis-tools.sh](#redis-tools.sh)
  * [前提](#前提)
  * [简介](#简介)
  * [概要](#概要)
  * [选项](#选项)
  * [示例](#示例)

## redis-tools.sh
### 前提
添加 Redis 可执行命令到系统环境变量中。

```
# 添加到系统环境变量
$ cp redis-profile.sh /etc/profile.d/

# 实时生效
$ source /etc/profile.d/redis-profile.sh

# 验证
$ redis-cli -v
```

### 简介
```
Filename         redis-tools.sh
Revision         0.0.2
Date             2020/04/26
Author           jiangliheng
Email            jiang_liheng@163.com
Website          https://jiangliheng.github.io/
Description      Redis 日常运维脚本
Copyright        Copyright (c) jiangliheng
License          GNU General Public License
```

### 变更记录

* Version 0.0.2 2020/05/16
   * 修正 inputYN 多次回车，导致参数丢失问题
   * 修正 部分描述信息，调整格式等
   * 增加 “批量删除相同前缀的 key，支持正则表达式” 方法


* Version 0.0.1 2020/04/26
   * 创建 Redis 集群情况查询、key 查询、key 删除等功能脚本


### 概要

```
redis-tools.sh [options] <value> ...
```

### 选项
```
-h<value>, --host=<value>            Redis IP，可设置默认值参数：HOST
-p<value>, --port=<value>            Redis 端口，可设置默认值参数：PORT
-a<value>, --password=<value>        Redis 密码，可设置默认值参数：PASSWORD
-c<value>, --cluster=<value>         集群相关命令，如：nodes, info
-k<pattern>, --keys=<pattern>        查询 key，支持正则表达式
-g<value>, --get=<value>             获取指定 key 的值
-d<value>, --del=<value>             删除指定 key，不支持正则表达式，原因：redis 的 del 命令不支持正则表达式
-b<pattern>, --bdel=<pattern>        批量删除 key，支持正则表达式
-f, --flushall                       删除所有 key
--help                               帮助信息
-v, --version                        版本信息
```

### 示例
```
redis key示例数据格式：
       "party::123"
       "party::456"

1. 查询集群信息，使用默认参数
sh redis-tools.sh -c info

2. 查询集群节点
sh redis-tools.sh -h 127.0.0.1 -p 8001 -a password -c nodes

3. 查询 key，支持正则表达式
sh redis-tools.sh -k "party::123"
sh redis-tools.sh -k "party*"

4. 获取指定 key 值
sh redis-tools.sh -g "party::123"

5. 删除指定 key，不支持正则表达式，原因：redis 的 del 命令不支持正则表达式
sh redis-tools.sh -d "party::123"

6. 批量删除 key，支持正则表达式
sh redis-tools.sh -b "party::123"
sh redis-tools.sh -b "party*"

7. 删除所有 key
sh redis-tools.sh -f
```
