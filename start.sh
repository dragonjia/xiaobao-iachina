#!/bin/sh

source func/logs.sh

source func/common-draft.sh

###
## 根据入口URL，将 某一类（人身险 或 财险）申报相关信息 抓取并解析、入库 。
###
## 参数： 1. url  2. typename=renshen 或 cai 3. typeid (0=renshen 1=cai)
function CrawlerETL(){
	local url=$1;
	local typename=$2;
	local instype=$3;

	InsDomain="ins_${typename}";

	COLID=$(getParameter "$url" "columnid");
	ATTR=3;
	fn_prefix="data/${InsDomain}";
	fn_with_links="${fn_prefix}_with_link"

	## 抓取人寿公司list页
	wgetFromUrlToFile "$url" "${fn_prefix}.html"
	## 转码
	syslog "convert coding to file:: "
	iconvert ${fn_prefix}.html

	## 生成Company 列表 索引页 
	##  格式如下： 
	#		ins中文名称		insCode		columnid 	attr
	#		中国人民健康保险股份有限公司 RBJK 2015110314024584 03

	sh  do0_extract_insList_data_from_html.sh  ${fn_prefix}.html > ${fn_prefix}.csv
	## 根据Company列表数据 ，拼合响应的抓取页

	echo "############do1_makelink from CSV file running...."
	#cat do1_makelink_fromMainCSV.sh
	syslog "ready do1......"
	sh do1_makelink_fromMainCSV.sh  "${fn_prefix}.csv" "$COLID" "$ATTR" |tr -d '\r' > ${fn_with_links}.csv

	echo "############done do1_makelink ,see file ${fn_with_links}.csv...."

	## 逐个保险公司，抓取4个主要页面，并将半结构化数据保存于insCode目录下（/data/$Code)
	cnt=1;
	while read line
	do
		code=`echo $line|awk '{split($1,m,"=");print m[2]}'`
		echo ">>>>>>>>>>"$code
		## 参数：
		## 1. ins_code   2. 保险公司抽取的纯文本line  3. 保险公司类型
		sh -debug do2_fetchSubDatafileByInsCode.sh "$code" "$line" "$instype"
		# if [[ $cnt -gt 1 ]]; then
		# 	break;
		# fi
		# let cnt++;
	done < ${fn_with_links}.csv

}

	shenshen_url="http://icid.iachina.cn/front/leafColComType.do?columnid=2015111318230001"
	cai_url="http://icid.iachina.cn/front/leafColComType.do?columnid=2015111318250002"

CrawlerETL "$shenshen_url" "renshen" 0
CrawlerETL "$cai_url" "cai" 1
