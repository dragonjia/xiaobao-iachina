#!/bin/sh
# 　　#define NONE "\033[m"
# 　　#define RED "\033[0;32;31m"
# 　　#define LIGHT_RED "\033[1;31m"
# 　　#define GREEN "\033[0;32;32m"
# 　　#define LIGHT_GREEN "\033[1;32m"
# 　　#define BLUE "\033[0;32;34m"
# 　　#define LIGHT_BLUE "\033[1;34m"
# 　　#define DARY_GRAY "\033[1;30m"
# 　　#define CYAN "\033[0;36m"
# 　　#define LIGHT_CYAN "\033[1;36m"
# 　　#define PURPLE "\033[0;35m"
# 　　#define LIGHT_PURPLE "\033[1;35m"
# 　　#define BROWN "\033[0;33m"
# 　　#define YELLOW "\033[1;33m"
# 　　#define LIGHT_GRAY "\033[0;37m"
# 　　#define WHITE "\033[1;37m"
	
# 　　\033[0m 关闭所有属性
# 　　\033[1m 设置高亮度
# 　　\033[4m 下划线
# 　　\033[5m 闪烁
# 　　\033[7m 反显
# 　　\033[8m 消隐
# more info refer:  http://blog.csdn.net/holyvslin/article/details/9278995


# LOG_LEVEL= 0 ; # 0-"online" ; 1-"debug"

SYSLOGFILE="logs_syslog.debug"
function syslog(){
	__datestr=`date`
	___str=$1
	printf "🍺  \033[1;30m%s@%s\r\n\t\033[0;32;32m>>>>%s\r\n\033[0m"  "$0"  "$__datestr" "$___str" >>$SYSLOGFILE
}

function syserr(){
	__datestr=`date`
	___str=$1
	printf "🍺  \033[0;33m%s@%s\r\n\t\033[0;35m>>>>%s\r\n\033[0m"  "$0"  "$__datestr" "$___str" >>$SYSLOGFILE
}
