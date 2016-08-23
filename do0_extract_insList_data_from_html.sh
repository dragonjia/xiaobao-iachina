#!/bin/sh

## 将 ， 保险公司首页html 转换为 保险公司信息list ，csv 文件
##
## 参数： ins_list_page.html
## 实际url样例： http://icid.iachina.cn/front//front/leafColComType.do?columnid=2015111318250002

if [[ -z $1 ]]; then
	syserr "$0 USAGE:  1."
	exit -1;
fi
htmlfile=$1;
cat $htmlfile|grep "onclick=\"company0("|awk -F"'" 'BEGIN{}{split($0,m,">|<");title=m[4];print title,$2,$4,$6}END{}'