#!/bin/sh
#
# 用途： 将结构化纯数据 转化为  带抓取的原材料数据 （拼合URL）
#
# 输入：
#		
#
# 输出：
#		
# 
#########function定义区域#########
source func/logs.sh



function makeInsInfoUrl()
{
	_param=$1;
	_uri="/front/getCompanyInfos.do"
	echo "${domain}${_uri}?${_param}";
}
# 已设立二级分公司详情 url
function makebranchUrl(){
	_param=$1;
	_uri="/front/viewAllBranch.do"
	echo "${domain}${_uri}?${_param}";

}
#互联网保险产品信息详情 url
function makeInsWebProsUrl(){
	_param=$1;
	_uri="/front/viewAllPros.do"
	echo "${domain}${_uri}?${_param}";
}
#合作保险中介机构网络平台列表 url
function makeInsZJUrl(){
	_param=$1;
	_uri="/front/viewAllZJ.do"
	echo "${domain}${_uri}?${_param}";
}
#合作第三方网络平台列表 url
function makeIns3rdUrl(){
	_param=$1;
	_uri="/front/viewAllSecond.do"
	echo "${domain}${_uri}?${_param}";
}
#########END function定义区域#########
#########头部定义区域#########
domain="http://icid.iachina.cn";
infile=$1;
colid=$2;
attr=$3;

if [[ -z $infile || -z $colid || -z $attr ]]; then
	syserr " Usage: 			$0	INFILE COLID ATTR ($1;$2;$3)"

	exit 1;
fi
#########END 头部定义区域#########
#########Main区域#########
$(syslog "infile=$infile; colid=$colid , attr=$attr")
$(syslog "begin working...")
### fetch each line , make URL
while read line; do
	#todo: infile 字段分隔符应该是TAB，以免field乱套
	ins_chname=`echo "$line"|awk '{print $1}'`
	ins_code=`echo "$line"| awk '{print $2}'`
	ins_infono=`echo "$line"| awk '{print $3}'`
	ins_zj=`echo "$line"| awk '{print $4}'`
	#组装下一级的 url 参数
	str_param="columnid=$colid&comCode=PAYLX&attr=$attr&informationno=$ins_infono&zj=$ins_zj&internetInformationNo=$ins_infono"

	url_InsInfo=$(makeInsInfoUrl $str_param)
	url_InsBranchlist=$(makebranchUrl $str_param)
	url_InsRegProductlist=$(makeInsWebProsUrl $str_param)
	url_InsZJlist=$(makeInsZJUrl $str_param)
	url_Ins3rdlist=$(makeIns3rdUrl $str_param)

	# echo $line 
	#printf '%s\r\n' $line
	#echo "$ins_code	$url_InsInfo	$url_InsBranchlist	$url_InsRegProductlist	$url_InsZJlist	$url_Ins3rdlist"
	printf "ins_code:=%s\tins_info:=%s\tins_branchs:=%s\tins_regpros:=%s\tins_zjs:=%s\tins_3rds:=%s\r\n" "$ins_code" "$url_InsInfo" "$url_InsBranchlist" "$url_InsRegProductlist" "$url_InsZJlist" "$url_Ins3rdlist"

done <${infile}
