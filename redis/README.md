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
Revision         0.0.1
Date             2020/04/26
Author           jiangliheng
Email            jiang_liheng@163.com
Website          https://jiangliheng.github.io/
Description      Redis 日常运维脚本
Copyright        Copyright (c) jiangliheng
License          GNU General Public License
```

### 概要
redis-tools.sh [option] <value> ...

### 选项
```
-h<value>, --host=<value>            Redis IP，可设置默认值参数：HOST
-p<value>, --port=<value>            Redis 端口，可设置默认值参数：PORT
-a<value>, --password=<value>        Redis 密码，可设置默认值参数：PASSWORD
-c<value>, --cluster=<value>         集群相关命令，如：nodes, info
-g<value>, --get=<value>             获取指定 key 的值
-d<value>, --del=<value>             删除指定 key
-k<value>, --keys=<value>            查询 key
-f, --flushall                       删除所有 key
--help                               帮助信息
-v, --version                        版本信息
```

### 示例
```
1. 查询集群信息，使用默认参数
sh redis-tools.sh -c info

2. 查询集群节点
sh redis-tools.sh -h 127.0。0.1 -p 8001 -a password -c nodes

3. 获取指定 key 值
sh redis-tools.sh -g key

4. 删除指定 key
sh redis-tools.sh -d key

5. 查询 key
sh redis-tools.sh -k key

6. 删除所有 key
sh redis-tools.sh -f
```
