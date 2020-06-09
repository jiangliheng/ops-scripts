# dingtalk

* [send-ding.sh](#send-ding.sh)
  * [简介](#简介)
  * [概要](#概要)
  * [选项](#选项)
  * [示例](#示例)

## send-ding.sh

### 简介
```
Filename         send-ding.sh
Revision         0.0.1
Date             2020/06/08
Author           jiangliheng
Email            jiang_liheng@163.com
Website          https://jiangliheng.github.io/
Description      发送钉钉消息
Copyright        Copyright (c) jiangliheng
License          GNU General Public License
```

### 变更记录

* Version 0.0.1 2020/06/08
  * 发送钉钉消息，支持 text，markdown 两种类型消息


### 概要

```
sh send-ding.sh [options] <value> ...
```

### 选项
```
* -a <value>                 钉钉机器人 Webhook 地址的 access_token
* -t <value>                 消息类型：text，markdown
& -T <value>                 title，首屏会话透出的展示内容；消息类型（-t）为：markdown 时
* -c <value>                 消息内容，content或者text
& -m <value>                 被@人的手机号（在 content 里添加@人的手机号），多个参数用逗号隔开；如：138xxxx6666，182xxxx8888；与是否@所有人（-A）互斥，仅能选择一种方式
& -A                         是否@所有人，即 isAtAll 参数设置为 ture；与被@人手机号（-m）互斥，仅能选择一种方式
  -v, --version              版本信息
  --help                     帮助信息

* 表示必输，& 表示条件必输，其余为可选
```

### 示例
```
1. 发送 text 消息类型，并@指定人
sh send-ding.sh -a xxx -t text -c "我就是我, 是不一样的烟火" -m "138xxxx6666,182xxxx8888"

2. 发送 markdown 消息类型，并@所有人
sh send-ding.sh -a xxx -t markdown -T "markdown 测试标题" -c "# 我就是我, 是不一样的烟火" -A
```
