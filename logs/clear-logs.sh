#!/bin/bash
#================================================================
# HEADER
#================================================================
#    Filename         clear-logs.sh
#    Revision         0.0.1
#    Date             2020/06/05
#    Author           jiangliheng
#    Email            jiang_liheng@163.com
#    Website          https://jiangliheng.github.io/
#    Description      删除 N 天前的日志文件
#    Copyright        Copyright (c) jiangliheng
#    License          GNU General Public License
#
#================================================================
#
#  Version 0.0.1 2020/06/05
#     删除 N 天前的日志文件，仅删除匹配  "*.log*"  的日志文件
#
#================================================================
#%名称(NAME)
#%       ${SCRIPT_NAME} - 删除 N 天前的日志文件
#%
#%概要(SYNOPSIS)
#%       sh ${SCRIPT_NAME} [options] <value> ...
#%
#%描述(DESCRIPTION)
#%       删除 N 天前的日志文件，仅删除匹配  "*.log*"  的日志文件
#%
#%选项(OPTIONS)
#%       -p <value>                 删除日志的路径，必输参数
#%       -d <value>                 删除 N 天前的日志文件，即保留 N 天日志，默认：7
#%       --help                     帮助信息
#%       -v, --version              版本信息
#%
#%示例(EXAMPLES)
#%
#%       1. 清理 7 天前的日志文件
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs -d 7
#%
#%       2. 清理 30 天前的日志文件
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs -d 30
#%
#================================================================
# END_OF_HEADER
#================================================================

# header 总行数
SCRIPT_HEADSIZE=$(head -200 "${0}" |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
# 脚本名称
SCRIPT_NAME="$(basename "${0}")"
# 版本
VERSION="0.0.1"

# 默认保留 7 天
DAYS=7
# 脚本执行日志目录
CLEAR_LOGS_LOG_PATH=/tmp/$(whoami)-clear-logs
# 日志文件
LOGFILE=${CLEAR_LOGS_LOG_PATH}/${SCRIPT_NAME}-$(date +%Y%m).log

# usage
function usage() {
  head -"${SCRIPT_HEADSIZE:-99}" "${0}" \
  | grep -e "^#%" \
  | sed -e "s/^#%//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" -e "s/\${VERSION}/${VERSION}/g"
}

# 初始化创建脚本日志目录
function init() {
  # 目录不存在，则创建
  if [ ! -d "${CLEAR_LOGS_LOG_PATH}" ]
  then
    mkdir -p "${CLEAR_LOGS_LOG_PATH}"
  fi

  # 日志文件不存在，则创建
  if [ ! -f "${LOGFILE}" ]
  then
    touch "${LOGFILE}"
  fi
}

# 记录 INFO log
function infoLog() {
  echo "$(date "+%Y-%m-%d %H:%M:%S") [ INFO] ${1}" >> "${LOGFILE}"
}

# 记录 ERROR log
function errorLog() {
  echo -e "$(date "+%Y-%m-%d %H:%M:%S") \033[31m[ERROR]\033[0m ${1}" >> "${LOGFILE}"
}

# 清理 log
function clearLogs() {
  infoLog "====>> Start cleaning up log files: [${LOGS_PATH}]"
  cd "${LOGS_PATH}" || exit

  # 查询要清理的文件（*.log*）
  clear_log_files=$(find "${LOGS_PATH}" -type f -mtime +${DAYS} -name "*.log*")

  # 没有找到匹配文件，记录日志退出
  if [ -z "${clear_log_files}" ]
  then
    errorLog "In the [${LOGS_PATH}] directory, the log [${DAYS}] days ago was not found!"
    infoLog "====>> End cleaning up log files: [${LOGS_PATH}]"
    exit 1
  fi

  # 临时记录要清理的文件（*.log*）
  echo "${clear_log_files}" > log_files.tmp

  # 循环清理日志文件
  while IFS= read -r item
  do
    rm -f ${item}
    infoLog "-- Clean up log file: [${item}]"
  done < log_files.tmp

  # 删除临时文件
  rm log_files.tmp

  infoLog "====>> End cleaning up log files: [${LOGS_PATH}]"
}

# 主方法
function main() {
  init

  # 参数必输校验
  if [ -z "${LOGS_PATH}" ]
  then
    printf "Parameter [-p] is required!\n"
    exit 1
  fi

  # 目录合法性校验
  if [ ! -d "${LOGS_PATH}" ]
  then
   printf "[%s] is not a directory!\n" "${LOGS_PATH}"
   exit 1
  fi

  # 数字合法性校验，且必须大于 0，即至少保留1天
  if ! [ "${DAYS}" -gt 0 ] 2>/dev/null
  then
    printf "Parameter [-d] must be a number greater than 0!\n"
    exit 1
  fi

  clearLogs
}

# 判断参数个数
if [ $# -eq 0 ];
then
  usage
  exit 1
fi

# getopt 命令行参数
if ! ARGS=$(getopt -o vd:p: --long help,version -n "${SCRIPT_NAME}" -- "$@")
then
  # 无效选项，则退出
  exit 1
fi

# 命令行参数格式化
eval set -- "${ARGS}"

while [ -n "$1" ]
do
  case "$1" in
    -p)
      LOGS_PATH=$2
      shift 2
      ;;

    -d)
      DAYS=$2
      shift 2
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

main
