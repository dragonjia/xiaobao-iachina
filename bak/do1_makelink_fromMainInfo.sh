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

function makeInsInfoUrl()
{
	echo " ";
	exit 1;
}
# 已设立二级分公司详情 url
function makebranchUrl(){

	echo "";
}
#互联网保险产品信息详情 url
function makeInsWebProsUrl(){

	echo "";
}
#合作保险中介机构网络平台列表 url
function makeInsZJUrl(){

	echo "";
}
#合作第三方网络平台列表 url
function makeIns3rdUrl(){

	echo "";
}
#########END function定义区域#########
#########头部定义区域#########
infile=$1;
colid=$2;
if [[ -z $infile || -z $colid ]]; then
	echo " Usage: 			$0	INFILE COLID "
	exit 1;
fi
#########END 头部定义区域#########
#########Main区域#########
echo "infile=$infile; colid=$colid"
echo "begin working..."
### fetch each line , make URL
while read line; 
do
	echo $line 
done < ${infile}