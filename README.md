# ops-scripts
![GitHub](https://img.shields.io/github/license/jiangliheng/ops-scripts)

# 说明

以下脚本仅在 ```Centos 7``` 测试通过，其他 ```Linux``` 版本未经过测试。

# 脚本

## [redis](redis/README.md)

* ```redis-profile.sh```：Redis 环境变量脚本。
* ```redis-tools.sh```：Redis 单机/集群版日常运维脚本。
  * 支持集群命令简单查询，如：nodes, info
  * 支持正则表达式模糊查询 key（keys 命令查询，生产环境慎用，建议使用：scan 命令）
  * 支持获取指定 key 的值
  * 支持精确删除指定 key
  * 支持正则表达式批量删除 key
  * 支持删除所有 key（生产环境慎用）

## [dingtalk](dingtalk/README.md)

* ```send-ding.sh```：发送钉钉消息。
  * 支持 text、markdown 两种消息类型
  * 支持 @指定人 和 @所有人

## [logs](logs/README.md)

* ```clear-logs.sh```：删除 N 天前的日志。
  * 支持配置多目录清理
  * 支持正则表达式匹配日志文件
  * 支持调试模式
