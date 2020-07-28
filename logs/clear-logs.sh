#!/bin/bash
#================================================================
# HEADER
#================================================================
#    Filename         clear-logs.sh
#    Revision         0.0.3
#    Date             2020/06/05
#    Author           jiangliheng
#    Email            jiang_liheng@163.com
#    Website          https://jiangliheng.github.io/
#    Description      删除 N 天前的日志
#    Copyright        Copyright (c) jiangliheng
#    License          GNU General Public License
#
#================================================================
#
#  Version 0.0.3 2020/07/28
#     增加 支持仅匹配目录类型，默认是查询每个文件并删除
#
#  Version 0.0.2 2020/07/21
#     优化 支持正则表达式匹配日志文件
#     增加 支持配置多目录清理
#     增加 支持调试模式
#
#  Version 0.0.1 2020/06/05
#     删除 N 天前的日志文件，仅删除匹配  "*.log*"  的日志文件
#
#================================================================
#%名称(NAME)
#%       ${SCRIPT_NAME} - 删除 N 天前的日志
#%
#%概要(SYNOPSIS)
#%       sh ${SCRIPT_NAME} [options] <value> ...
#%
#%描述(DESCRIPTION)
#%       删除 N 天前的日志文件
#%
#%选项(OPTIONS)
#%       * -p <value>                 删除日志的路径，多个目录用 "," 隔开，如："/logs1,/logs2"
#%         -d <value>                 删除 N 天前的日志文件，即保留 N 天日志，默认：7
#%         -e <value>                 正则表达式匹配日志文件，如："*.log*"
#%         -D                         仅匹配目录类型，默认是查询每个文件并删除，即 find 命令增加 “-type d” 参数
#%         -t                         调试模式，控制台打印日志，不删除日志文件
#%         --help                     帮助信息
#%         -v, --version              版本信息
#%
#%       * 表示必输，& 表示条件必输，其余为可选
#%
#%示例(EXAMPLES)
#%
#%       1. 清理多个目录中 7 天前的日志文件
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs,/home/nacos/nacos/logs
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs,/home/nacos/nacos/logs -d 7
#%
#%       2. 清理 30 天前的日志文件
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs -d 30
#%
#%       3. 清理 30 天前的匹配正则表达式的日志文件，调试模式
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs -d 30 -e "*.log*" -t
#%
#%       4. 清理 30 天前的日志目录，调试模式
#%       sh ${SCRIPT_NAME} -p /home/nacos/logs -d 30 -D -t
#%
#================================================================
# END_OF_HEADER
#================================================================

# header 总行数
SCRIPT_HEADSIZE=$(head -200 "${0}" |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
# 脚本名称
SCRIPT_NAME="$(basename "${0}")"
# 版本
VERSION="0.0.3"

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
  # 判断调试模式，调试模式时，打印到控制台
  if [ -n "${TEST_MODE}" ]
  then
    echo "$(date "+%Y-%m-%d %H:%M:%S") [ INFO] ${1}"
  else
    echo "$(date "+%Y-%m-%d %H:%M:%S") [ INFO] ${1}" >> "${LOGFILE}"
  fi
}

# 记录 ERROR log
function errorLog() {
  # 判断调试模式，调试模式时，打印到控制台
  if [ -n "${TEST_MODE}" ]
  then
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") \033[31m[ERROR]\033[0m ${1}"
  else
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") \033[31m[ERROR]\033[0m ${1}" >> "${LOGFILE}"
  fi
}

# 清理 log
function clearLog() {
  # 清理目录
  clear_log_path=${1}

  infoLog "====>> Start cleaning up log files: [${clear_log_path}]"
  cd "${clear_log_path}" || exit

  # 查询要清理的文件
  if [ -n "${REGULAR_EXPRESSION}" ]
  then
    if [ -n "${TYPE}" ]
    then
      clear_log_files=$(find "${clear_log_path}" -mtime +${DAYS} -name "${REGULAR_EXPRESSION}" -type d)
    else
      clear_log_files=$(find "${clear_log_path}" -mtime +${DAYS} -name "${REGULAR_EXPRESSION}")
    fi
  else
    if [ -n "${TYPE}" ]
    then
      clear_log_files=$(find "${clear_log_path}" -mtime +${DAYS} -type d)
    else
      clear_log_files=$(find "${clear_log_path}" -mtime +${DAYS})
    fi
  fi

  # 没有找到匹配文件，记录日志
  if [ -z "${clear_log_files}" ]
  then
    errorLog "In the [${clear_log_path}] directory, the log [${DAYS}] days ago was not found!"
  # 否则开始清理
  else
    # 临时记录要清理的文件
    echo "${clear_log_files}" > log_files.tmp

    # 循环清理日志文件
    while IFS= read -r item
    do
      # 判断调试模式，调试模式时，不删除文件
      if [ -z "${TEST_MODE}" ]
      then
        rm -rf "${item}"
      fi

      infoLog "-- Clean up log file: [${item}]"
    done < log_files.tmp

    # 删除临时文件
    rm log_files.tmp
  fi

  infoLog "====>> End cleaning up log files: [${clear_log_path}]"
}

# 主方法
function main() {
  # 初始化
  init

  # 参数必输校验
  if [ -z "${LOGS_PATH}" ]
  then
    printf "Parameter [-p] is required!\n"
    exit 1
  fi

  # 数字合法性校验，且必须大于 0，即至少保留1天
  if ! [ "${DAYS}" -gt 0 ] 2>/dev/null
  then
    printf "Parameter [-d] must be a number greater than 0!\n"
    exit 1
  fi

  # 多目录判断
  result=$(echo "${LOGS_PATH}" | grep ",")
  # 多个目录
  if [[ "X${result}" != "X" ]]; then
    # 转换为数组
    logs_path_array=${LOGS_PATH//,/ }

    # 循环清理
    for path in ${logs_path_array}
    do
      # 目录合法性校验
      if [ ! -d "${path}" ]
      then
       printf "[%s] is not a directory!\n" "${path}"
       exit 1
      fi

      clearLog "${path}"
    done
  # 一个目录
  else
    # 目录合法性校验
    if [ ! -d "${LOGS_PATH}" ]
    then
     printf "[%s] is not a directory!\n" "${LOGS_PATH}"
     exit 1
    fi

    clearLog "${LOGS_PATH}"
  fi
}

# 判断参数个数
if [ $# -eq 0 ];
then
  usage
  exit 1
fi

# getopt 命令行参数
if ! ARGS=$(getopt -o vtDd:e:p: --long help,version -n "${SCRIPT_NAME}" -- "$@")
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

    -e)
      REGULAR_EXPRESSION=$2
      shift 2
      ;;

    -t)
      TEST_MODE=true
      shift;;

    -D)
      TYPE=true
      shift;;

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
