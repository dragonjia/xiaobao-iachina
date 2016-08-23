## 从中介页面(viewTerraceProduct.do or viewTerraceProductHis.do)抽取zj信息保存到以TerraceNo前缀的文件中
function extractor_zj_info(){
	local _url=$1;
	local _TerNo=$2;
	local _save_file=$3;
	#wget "$_url" -O ${_save_file}.tmp 

	wgetFromUrlToFile "$_url" "${_save_file}.tmp"
	iconvert ${_save_file}.tmp
	$(syslog "extractor_zj_info():url=$_url: TerNO=$_TerNo; savefile==>${_save_file}")
	##--delete....动态适配，信息条目数，假定开始于《xxxx平台全称》；终止于《xxx止日期》
	_lines=6;
	cat ${_save_file}.tmp |grep -A${_lines}  "平台全称" |sed 's/<[^>]*>//g' > ${_save_file}

	rm  ${_save_file}.tmp
}



## 从输入的plain txt 格式，（定制化强） 转化为结构化的sql语句
## 输出：单独的一条语句_局部语句 
function etl_zj_info(){
	local in_fn=$1;
	local out_fn=$2;

	if [[ -z $2 || ! -f $1 ]]; then
		$(syserr "Usage: etl_zj_info in_file out_file\r\n para1=$1 \r\npara2=$2")
		exit -1;
	fi
	cat $in_fn|awk -F'：' 'BEGIN{
		sql="";
	}{
		gsub(/\t/,"");
		sql0=sql;
		if(index($1,"全称")>0) sql=sql0"fullname=\""$2"\"";
		if(index($1,"简称")>0) sql=sql0",shortname=\""$2"\"";
		if(index($1,"网站地址")>0) sql=sql0",siteurl=\""$2"\"";
		if(index($1,"备案信息")>0) sql=sql0",icp_info=\""$2"\"";
		if(index($1,"范围")>0) sql=sql0",biz_op_range=\""$2"\"";
	}END{
		print sql;
	}' > $out_fn
}

## 从输入的plain txt 格式，（定制化强） 转化为结构化的sql语句,用于生成 “保险公司《--》中介”合作数据
## 输出：单独的一条语句_局部语句 
function etl_zj_coo_info(){
	local in_fn=$1;
	local out_fn=$2;

	if [[ -z $2 || ! -f $1 ]]; then
		$(syserr "Usage: etl_zj_info in_file out_file\r\n para1=$1 \r\npara2=$2")
		exit -1;
	fi
	cat $in_fn|awk -F'：' 'BEGIN{
		sql="";
	}{
		gsub(/\t/,"");
		sql0=sql;
		if(index($1,"业务合作起始日期")>0) sql=sql0"coo_begin=\""$2"\"";
		if(index($1,"业务合作终止日期")>0) sql=sql0",coo_end=\""$2"\"";
	}END{
		print sql;
	}' > $out_fn
}

## 从中介产品列表抽取产品信息(viewAllPro.do)保存到以TerraceNo前缀的文件中
function extractor_zj_pro(){
	local _url=$1;
	local _TerNo=$2;
	local _save_file=$3;


 	$(syslog "extractor_zj_info:debug: save to file:$_save_file....from url=$_url") 
    wgetFromUrlToFile "$_url" "${_save_file}.tmp"
    iconvert ${_save_file}.tmp
    cat ${_save_file}.tmp |sed '/^\s*$/d'|sed 's/<\/td>\n/<\/td>/g'|sed 's/<[^>]*>//g'> ${_save_file}

	##sed 's/^\s*$//g'|sed 'N;N;s/\n/ /g' ##合并多个空白行

	local _nn=`cat ${_save_file}|grep -n "返回上一级"|cut -d':' -f1`
	head -n $_nn ${_save_file} > ${_save_file}.tmp
    ##抽取成为结构化数据：
 	# saleName="交通保"       regName="国寿绿舟意外伤害保险(2013版)、国寿通泰交通意外伤害保险(A款)(2013版)"
	# saleName="旅游保"       regName="国寿e家吉祥送福综合意外伤害保险(2013版)"

    cat ${_save_file}.tmp| awk -F'\t' '{ if(NF==6){print $6}}'|awk '{n1=$0;if(NR%2==1) printf("saleName=\"%s\"\t,\t",$0);else printf("regName=\"%s\"\n",$0);}'|tr -d '\r' > ${_save_file}
    rm -rf ${_save_file}.tmp

}

