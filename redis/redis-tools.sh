#!/bin/bash
#================================================================
# HEADER
#================================================================
#    Filename         redis-tools.sh
#    Revision         0.0.2
#    Date             2020/04/26
#    Author           jiangliheng
#    Email            jiang_liheng@163.com
#    Website          https://jiangliheng.github.io/
#    Description      Redis 日常运维脚本
#    Copyright        Copyright (c) jiangliheng
#    License          GNU General Public License
#
#================================================================
#  Version 0.0.2 2020/05/16
#     修正 inputYN 多次回车，导致参数丢失问题
#     修正 部分描述信息，调整格式等
#     增加 “批量删除 key，支持正则表达式” 方法
#
#  Version 0.0.1 2020/04/26
#     创建 Redis 集群情况查询、key 查询、key 删除等功能脚本
#
#================================================================
#%名称(NAME)
#%       ${SCRIPT_NAME} - Redis 日常运维脚本
#%
#%概要(SYNOPSIS)
#%       sh ${SCRIPT_NAME} [options] <value> ...
#%
#%描述(DESCRIPTION)
#%       Redis 日常运维脚本
#%
#%选项(OPTIONS)
#%       -h<value>, --host=<value>            Redis IP，可设置默认值参数：HOST
#%       -p<value>, --port=<value>            Redis 端口，可设置默认值参数：PORT
#%       -a<value>, --password=<value>        Redis 密码，可设置默认值参数：PASSWORD
#%       -c<value>, --cluster=<value>         集群相关命令，如：nodes, info
#%       -k<pattern>, --keys=<pattern>        查询 key，支持正则表达式
#%       -g<value>, --get=<value>             获取指定 key 的值
#%       -d<value>, --del=<value>             删除指定 key，不支持正则表达式，原因：redis 的 del 命令不支持正则表达式
#%       -b<pattern>, --bdel=<pattern>        批量删除 key，支持正则表达式
#%       -f, --flushall                       删除所有 key
#%       --help                               帮助信息
#%       -v, --version                        版本信息
#%
#%示例(EXAMPLES)
#%       redis key示例数据格式：
#%              "party::123"
#%              "party::456"
#%
#%       1. 查询集群信息，使用默认参数
#%       sh ${SCRIPT_NAME} -c info
#%
#%       2. 查询集群节点
#%       sh ${SCRIPT_NAME} -h 127.0.0.1 -p 8001 -a password -c nodes
#%
#%       3. 查询 key，支持正则表达式
#%       sh ${SCRIPT_NAME} -k "party::123"
#%       sh ${SCRIPT_NAME} -k "party*"
#%
#%       4. 获取指定 key 值
#%       sh ${SCRIPT_NAME} -g "party::123"
#%
#%       5. 删除指定 key，不支持正则表达式，原因：redis 的 del 命令不支持正则表达式
#%       sh ${SCRIPT_NAME} -d "party::123"
#%
#%       6. 批量删除 key，支持正则表达式
#%       sh ${SCRIPT_NAME} -b "party::123"
#%       sh ${SCRIPT_NAME} -b "party*"
#%
#%       7. 删除所有 key
#%       sh ${SCRIPT_NAME} -f
#%
#================================================================
# END_OF_HEADER
#================================================================

# header 总行数
SCRIPT_HEADSIZE=$(head -200 "${0}" |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
# 脚本名称
SCRIPT_NAME="$(basename "${0}")"
# 版本
VERSION="0.0.2"

# 默认 host
HOST=127.0.0.1
# 默认 port
PORT=8001
# 默认 password
PASSWORD=password

# usage
usage() {
  head -"${SCRIPT_HEADSIZE:-99}" "${0}" \
  | grep -e "^#%" \
  | sed -e "s/^#%//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" -e "s/\${VERSION}/${VERSION}/g"
}

# redis-cli 方法
cli() {
  printf "\033[36mredis-cli -c -h %s -p %s -a %s %s \"%s\" \033[0m\n\n" "${HOST}" "${PORT}" "${PASSWORD}" "$1" "$2"
  eval redis-cli -c -h "${HOST}" -p "${PORT}" -a "${PASSWORD}" "$1" \""$2"\"
}

# clusterCli 方法
clusterCli() {
  printf "\033[36mredis-cli -c -h %s -p %s -a %s cluster %s \033[0m\n\n" "${HOST}" "${PORT}" "${PASSWORD}" "$1"
  eval redis-cli -c -h "${HOST}" -p "${PORT}" -a "${PASSWORD}" cluster "$1"
}

# 查询 master 节点
masterNodes() {
  masterNodes=$(clusterCli nodes | awk '{if($3=="master" || $3=="myself,master") print $2}' | awk -F@ '{print $1}')
  printf "\033[36mRedis master nodes: \n%s\n\033[0m" "${masterNodes}"
}

# 清理所有 key
flushallCli() {
  masterNodes

  # 循环清理
  for master in ${masterNodes}
  do
    thost=${master%:*}
    tport=${master#*:}
    printf "\033[36m\nredis-cli -c -h %s -p %s -a %s flushall \033[0m\n" "${thost}" "${tport}" "${PASSWORD}"
    eval redis-cli -c -h "${thost}" -p "${tport}" -a "${PASSWORD}" flushall
  done
}

# 查询 key
keysCli() {
  masterNodes

  # 循环查询 key
  for master in ${masterNodes}
  do
    thost=${master%:*}
    tport=${master#*:}
    printf "\033[36m\nredis-cli -c -h %s -p %s -a %s keys \"%s\" \033[0m\n" "${thost}" "${tport}" "${PASSWORD}" "$1"
    eval redis-cli -c -h "${thost}" -p "${tport}" -a "${PASSWORD}" keys \""$1"\"
  done
}

# 批量删除相同前缀的 key，支持正则表达式
bdelCli() {
  masterNodes

  # 循环查询 key
  for master in ${masterNodes}
  do
    thost=${master%:*}
    tport=${master#*:}
    printf "\033[36m\nredis-cli -h %s -p %s -a %s --scan --pattern \"%s\" | xargs -L 1 redis-cli -h %s -p %s -a %s del\033[0m\n" "${thost}" "${tport}" "${PASSWORD}" "$1" "${thost}" "${tport}" "${PASSWORD}"
    eval redis-cli -h "${thost}" -p "${tport}" -a "${PASSWORD}" --scan --pattern \""$1"\" | xargs -L 1 redis-cli -h "${thost}" -p "${tport}" -a "${PASSWORD}" del
  done
}

# 操作确认
inputYN() {
  read -r -p "是否继续 \"$1\" 操作(y/n)：" choose
  case "${choose}" in
    [yY])
      return 0
      ;;

    [nN])
      exit 1
      ;;

    *)
      inputYN "$1"
      ;;
  esac
}

# 判断参数个数
if [ $# -eq 0 ];
then
  usage
  exit 1
fi

# getopt 命令行参数
if ! ARGS=$(getopt -o vfh:p:a:g:d:c:k:b: --long flushall,help,version,host:,port:,password:,get:,del:,bdel:,password:,cluster:,keys: -n "${SCRIPT_NAME}" -- "$@")
then
  # 无效选项，则退出
  exit 1
fi

# 命令行参数格式化
eval set -- "${ARGS}"

while [ -n "$1" ]
do
  case "$1" in
    -a|--password)
      PASSWORD=$2
      shift 2
      ;;

    -h|--host)
      HOST=$2
      shift 2
      ;;

    -p|--port)
      PORT="$2"
      shift 2
      ;;

    -c|--cluster)
      clusterCli "$2"
      exit 1
      ;;

    -g|--get)
      cli get "$2"
      exit 1
      ;;

    -d|--del)
      # 先显示内容
      cli get "$2"
      # 确认是否删除
      inputYN "del"
      # 删除
      cli del "$2"
      exit 1
      ;;

    -k|--keys)
      keysCli "$2"
      exit 1
      ;;

    -b|--bdel)
      # 先显示匹配项
      keysCli "$2"
      # 确认是否删除
      inputYN "batch del"
      # 删除
      bdelCli "$2"
      exit 1
      ;;

    -f|--flushall)
      # 确认是否删除
      inputYN "flushall"
      # 删除所有 key
      flushallCli
      exit 1
      ;;

    -v|--version)
      printf "%s version %s\n" "${SCRIPT_NAME}" "${VERSION}"
      exit 1
      ;;

    --help)
      usage
      exit 1
      ;;

    --)
      shift
      break
      ;;

    *)
      printf "%s is not an option!" "$1"
      exit 1
      ;;

  esac
done
