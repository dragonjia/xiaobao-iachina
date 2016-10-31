#!/bin/bash
###
#	$#	传递到脚本的参数个数
#	$*	以一个单字符串显示所有向脚本传递的参数
#	$$	脚本运行的当前进程ID号
#	$!	后台运行的最后一个进程的ID号
#	$@	与$*相同，但是使用时加引号，并在引号中返回每个参数。
#	$-	显示Shell使用的当前选项，与set命令功能相同。
#	$?	显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。
###
source func/logs.sh

## 
if [[ $commonMark -ne 1 ]];then 
	source func/common-draft.sh 
fi
source ExtractorFunc.sh
source conf/DB.conf


function printParam(){
	#printParam param_no param_columnid param_zj flag param_terraceno param_type param_oldterr param_comType 
	echo "$0:printParam():"$*;
}

## 生成中介产品详情url ;(zj 详情+部分授权合作产品）
function makeUrl_TerraceProduct(){
	local url="http://icid.iachina.cn/front/viewTerraceProduct.do?"
	echo $url$1 
}

## 生成(旧版)中介产品详情url ;(zj 详情+部分授权合作产品）
function makeUrl_oldTerraceProduct(){
	local url="http://icid.iachina.cn/front/viewTerraceProductHis.do?"
	echo $url$1 
}
## 生成中介平台全部合作产品页
function makeUrl_viewAllPro(){
	local url="http://icid.iachina.cn/front/viewAllPro.do?"
	echo $url$1 
}

## 将，保险公司 合作中介页面 的中介信息提取并保存到 mysql 表：zj_info ；同时保存合作关系到表：ins_zj_cooperation 
## 注意，是保存到两张表
# function in2mysql_zj_info(){
# 	local zj_code=$1;
# 	local fn_info_plain=$2;
# 	#local sql_file=${zj_prolist_file}.sql
	
# 	while read line ; do
# 		## format:  insert into zj_products set ins_code="",no="",saleName="",regName="";
# 		local str="insert into zj_products set ins_code=\"$ins_code\",code=\"$zj_code\",$line;"
# 		echo $str;
# 	done<$zj_prolist_file 
# }	


### 执行导入数据库操作； 不关心业务逻辑
## 输入：文件

function Mysql_run(){
	local sql=`echo $1|sed 's/"/\\"/g'`
	$mysql_go "-e $sql" || syserr "Mysql_run:::sql=($sql) ;Error Exit!",exit -1;

}

function Mysql_import(){
	local sql_file=$1;
	if [[ -e $sql_file ]]; then
		syserr "function import2mysql:: parameter is not file! ,exit"
		exit -1;
	fi

	$(syslog "正在建设中……");

}
### insert zj_info 信息到mysql
### 参数：$1 -- 文件名 ；部分sql语句 ：fullname="中国民航信息网络股份有限公司",shortname="www.jhwvip.com",siteurl="www.jhwvip.com",icp_info="京ICP备06014661号",biz_op_range="意外伤害保险,普通型"
function insertZJ3rdInfo2Mysql(){
	if [[ -z $4 || ! -f $1 ]];then
		syserr "Usage: insertZJInfo2Mysql(): ZJINFO_FILE ZJCODE INS_TYPE COO_TYPE"
		exit -1;
	fi

	local sql_part=`head -1 $1`
	local zj_code=$2;
	local ins_type=$3;
	local coo_type=$4;


	sql="insert into ${coo_type}_info set ins_type=$ins_type ,code=\"$zj_code\" ,"$sql_part";"
	syslog "$0 begin to run sql=$sql"
	Mysql_run "$sql" || syserr "insertZJInfo2Mysql:::error with sql=$sql"

}

function insertInsCooZJ3rdInfo2Mysql(){
	if [[ -z $3 || ! -f $1 ]];then
		syserr "Usage: insertInsCooZJInfo2Mysql(): ZJINFO_FILE InsCode ZJCode INS_TYPE COO_TYPE"
		exit -1;
	fi

	local sql_part=`head -1 $1`
	local ins_code=$2;
	local zj_code=$3;
	local ins_type=$4;
	local coo_type=$5;

	sql="insert into ins_${coo_type}_cooperation set ins_type=$ins_type,ins_code=\"$ins_code\",${coo_type}_code=\"$zj_code\","$sql_part";"
	$(syslog "$0 begin to run sql=$sql")
	Mysql_run "$sql" || syserr "insertInsCooZJInfo2Mysql:::error with sql=$sql"

}

##生成SQL，并import导入到mysql 
## todu: 导入到mysql 的语句
function import2mysql_zj3rd_products(){
	local ins_code=$1;
	local zj_code=$2;
	local zj_prolist_file=$3;
	local ins_type=$4;
	local coo_type=$5;
	#local sql_file=${zj_prolist_file}.sql
	
	while read line ; do
		## format:  insert into zj_products set ins_code="",no="",saleName="",regName="";
		local sql="insert into ${coo_type}_products set ins_type=$ins_type ,ins_code=\"$ins_code\",code=\"$zj_code\",$line;"
		#debug :dde tudo
		Mysql_run "$sql" || $(syserr "import2mysql_zj_products:::error with sql=$sql")

	done<$zj_prolist_file 
}	


##生成SQL，并import导入到mysql 

function insert_ins_reg_products2mysql(){
	local ins_type=$1;
	local ins_code=$2;
	local sql_part=$3;

	local sql="insert into ins_register_products set ins_type=$ins_type ,ins_code=\"$ins_code\",${sql_part};"
	syslog "SQl=[$sql]"
	Mysql_run "$sql" || syserr "insert_ins_reg_products2mysql:::error with sql=$sql"
}	

### 针对 人寿、财险 下的 “中介”、“第三方平台“ 所牵扯的相关信息 抽取 ，并保存到： 3 * 2（份）= 12张张表中。 
# 		3*2张数据库表分别为： {zj_info,zj_products,ins_zj_cooperation} , {3rd_info,3rd_products,ins_3rd_cooperation}
# 人寿、财险 通过 表中的ins_type 区分；   
# 	ins_type=0 # 人寿
#	ins_type=1 # 财险
# 参数： 1. ins_type="0|1"   
#		2. coo_type="zj | 3rd"
#		3. dir="/data/"
#		4. url=....

function batchETL(){
	if [[ -z $5 ]]; then
		syserr "batchETL() USAGE: 参数：1. ins_type=0|1   2. coo_type=zj | 3rd  3.dir   4. ins_code 5.url"
		exit -1;
	fi
	local ins_type=$1;
	local coo_type=$2;
	local dir=$3;
	local ins_code=$4;
	local url=$5;

	## zj file name define
	makeDirExist "$dir"
	cootype_dir="$dir/"$coo_type"/"
	makeDirExist "$cootype_dir"  ##确认目录是存在的。


	## todu: 按照上面zj的格式整理
	local fn_prex="$cootype_dir/it_${ins_type}_${ins_code}_${coo_type}_"

	fn_coo_list=${fn_prex}plain.csv
	fn_coo_list_with_link=${fn_prex}with_link.csv

	###########Part 3 zj infos##############
	$(syslog "batchETL:: ins_type=$ins_type; coo_type=$coo_type; dir=$dir; url=($url)")

	# if [[ -z $url ]]
	# then
	# 	echo ">>>>>>>>>>"
	# 	echo "Can not find Code=$code...."
	# 	echo "<<<<<<<<<<"
	# 	exit 0;
	# fi

	## 抓取当前insCode的ZJ 列表页面，并解析出结构化中介信息+links（detailUrl、coo_productsURL) 信息
	# wget "$url" -O ${fn_coo_list}.html
	wgetFromUrlToFile "$url" "${fn_coo_list}.html"



	iconvert ${fn_coo_list}.html

	## get zj main parameters to FILE

	cat ${fn_coo_list}.html |grep "\"zjDetail"|cut -d' ' -f6|awk -F'\x27' '{print $2,$4,$6,$8}' > ${fn_coo_list}

	# if [[ -e ${fn_coo_list}.html ]];then
	# 	rm -rf ${fn_coo_list}.html
	# fi

	$(syslog "see file :: ${fn_coo_list}")

	##global parameter initial....
	local param_no=$(getParameter $url informationno)
	local param_columnid=$(getParameter $url columnid)
	local param_zj=$(getParameter $url zj)

	echo "read lines && make zj|3rd Url from zj|3rd (${fn_coo_list}) list...."

	> ${fn_coo_list_with_link}
	while read line ;do
		$(syslog  "read line::::$line")

		##fetch zj list info .....
		local flag=`echo $line|cut -d' ' -f3`
		$(syslog "$param_no")

		local param_terraceno=`echo $line|cut -d' ' -f1`
		local param_type=`echo $line|cut -d' ' -f4`
		local param_oldterr=`echo $line|cut -d' ' -f2`
		local param_comType="01"

		local zjid=$param_terraceno
		local zjurl="";
		local zjurl_allpro="";

		local para_str="columnid=$param_columnid&informationno=$param_no&terraceNo=$param_terraceno&zj=$param_zj&oldTerraceNo=$param_oldterr&internetInformationNo=$param_no&type=$param_type&comType=$param_comType";

		if [[ $flag -eq 0 ]]
		then
			zjurl=$(makeUrl_oldTerraceProduct "$para_str");
			$(syslog "flag==0,make old zj_detail_URL...")
		else
			zjurl=$(makeUrl_TerraceProduct "$para_str");
			$(syslog "flag==1,make zj_detail_URL...")

		fi

		zjurl_allpro=$(makeUrl_viewAllPro "$para_str")
		$(syslog  "zj_detail_url=$zjurl")
		$(syslog  "zj_detail_url_allpro=$zjurl_allpro")
		printf "%s\t%s\t%s\r\n" "$line" "$zjurl" "$zjurl_allpro"  >> ${fn_coo_list_with_link} 
		$(syslog "append urls to <<${fn_coo_list_with_link}>> ,zjid=${param_terraceno}:::see file pls.")
		
		fn_zj_xxxx_coo_list=${fn_prex}${zjid}_coo_list.csv
		fn_zj_xxxx_info=${fn_prex}${zjid}_info.csv

		#从zj页面抽取中介信息，保持到以TerraceNo前缀的文件中
		# 参数： link ,中介id，抓取结果保存文件名
		extractor_zj_info $zjurl $param_terraceno $fn_zj_xxxx_info

		## 下面：用于产生 zj_info 的关键sql 片段
		## 从非结构化plain文本 转化为 sql语句，*并执行；
		## 参数： input_plain_text_file   outputSqlFile
		$(etl_zj_info "$fn_zj_xxxx_info" "${fn_zj_xxxx_info}.sql")

		## 下面：用于产生 zj_coo_info 的关键sql 片段
		etl_zj_coo_info "$fn_zj_xxxx_info" "${fn_zj_xxxx_info}_coo.sql"

		##虽然只有一句 中介信息，仍然走的是文件 呵呵
		insertZJ3rdInfo2Mysql "${fn_zj_xxxx_info}.sql" "$zjid" "$ins_type" "$coo_type"  

		insertInsCooZJ3rdInfo2Mysql "${fn_zj_xxxx_info}_coo.sql" "$code" "$zjid" "$ins_type" "$coo_type" 

		#从zj_all_product页面抽取中介信息，保持到以TerraceNo前缀的文件中
		# 参数：Param1 -- zj产品链接（列表）
		# 参数：Param2 -- zjid
		# 参数：Param3 -- 结果输出（SQL片段）
		extractor_zj_pro "$zjurl_allpro" "$param_terraceno" "$fn_zj_xxxx_coo_list"

	    ## make to sql 
	   import2mysql_zj3rd_products "$code" "$zjid" "$fn_zj_xxxx_coo_list" "$ins_type" "$coo_type" 


	done < "${fn_coo_list}"


}

function batchETL_InsRegpro(){
	if [[ -z $4 ]]; then
		syserr "batchETL() USAGE: 参数：1. ins_type=0|1  2.dir   3. ins_code 4.url"
		exit -1;
	fi
	local ins_type=$1;
	local dir=$2;
	local ins_code=$3;
	local url=$4;

	## zj file name define
	makeDirExist "$dir"
	regpro_dir="$dir/reg_products/"
	makeDirExist "$regpro_dir"  ##确认目录是存在的。


	## 本次存储的文件名前缀
	local fn_prex="$regpro_dir/INS_${ins_type}_${ins_code}_"
	local fn_html="${fn_prex}"html
	
	local fn_reg_sql_parts_list=${fn_prex}_sql_parts.sql
	# fn_reg_sql=${fn_prex}sql.import

	###########Part 3 zj infos##############
	$(syslog "(INS注册的产品清单处理)batchETL_InsRegpro:: ins_type=$ins_type; ins_code=$ins_code; dir=$dir; url=($url)")

	## 抓页面、转码、剔除^M
	wgetFromUrlToFile "$url" "${fn_html}"
	iconvert "${fn_html}"

	## 抽取页面内容 ，形成 sql——片段 ：  
	## 输出的行，
	# 样例：saleName="新华出行关爱去哪儿网A款",regName="出行关爱交通工具意外伤害保险",regCode="新保发[2013]429号"
	cat "${fn_html}"|grep -A3 "\t\t\t<tr>"|sed 's/<[^>]*>//g'|awk 'BEGIN{
	}{
	  gsub("\t","");
	  str=$0;
	  if(NR%5<=1){
	    ##do nothing
	  }else if(NR%5==2){
	    printf("saleName=\"%s\",",str);
	  }else if(NR%5==3){
	    printf("regName=\"%s\",",str);
	  }else if(NR%5==4){
	    printf("regCode=\"%s\"\r\n",str);
	  }
	}END{
	}' > $fn_reg_sql_parts_list

	while read line;
	do
		syslog "func batchETL_InsRegpro::: ready to import to mysql ...... ins-type=$ins_type ins-code=$ins_code sqlpart=$line"
		insert_ins_reg_products2mysql "$ins_type" "$ins_code" "$line"
	done< $fn_reg_sql_parts_list
}





##todu: 第二个参数，INS_STR的解析应该交给单独的《对象类》脚本处理！
if [[ -z $3 ]]
then
	syserr "Usage:	%0  INS_CODE INS_CSV_STR INS_TYPE"
	syserr "	%0  INS_CODE=$1 INS_CSV_STR=$2 INS_TYPE=$3"
	exit;
fi

code=$1;
INS_STR=$2;
ins_type=$3;
dir="data/$code"

Seq_3rd=6;
Seq_zj=5;
Seq_regpro=4;
Seq_branch=3;
Seq_ins_info=2;

$(syslog "code=$code")
##检查输入参数正确性

__ret=`echo "$INS_STR"|awk -v "max=$Seq_3rd" '{if(NF>=max) print 1;}'`
if [[ $__ret -eq 1 ]];	then
	$(syslog "输入参数检查通过！")
	$(syslog "$INS_STR")
else
	$(syslog "参数不合规：ins_str=$INS_STR")

fi

thirdlisturl=`echo "$INS_STR" |awk -v"seq=$Seq_3rd" '{split($seq,__m,":=");print __m[2]}'`
zjlisturl=`echo "$INS_STR" 		|awk -v"seq=$Seq_zj" 	 '{split($seq,__m,":=");print __m[2]}'`
regprolisturl=`echo "$INS_STR"  |awk -v"seq=$Seq_regpro" '{split($seq,__m,":=");print __m[2]}'`
branchlisturl=`echo "$INS_STR" |awk -v"seq=$Seq_branch" '{split($seq,__m,":=");print __m[2]}'`
insInfourl=`echo "$INS_STR" |awk -v"seq=$Seq_ins_info" '{split($seq,__m,":=");print __m[2]}'`


##tudo:这些定义还有用吗？
fn_3rd_prex="$dir/3rd_index__${code}"
fn_regpro_prex="$dir/regpro_index__${code}"
fn_branch_prex="$dir/branch_index__${code}"
fn_ins_info_prex="$dir/ins_index__${code}"



##batchETL() USAGE: 参数：1. ins_type=0|1   2. coo_type=zj | 3rd  3.dir   4. ins_code 5.url

# batchETL $ins_type "zj" "$dir" "$code" "$zjlisturl"
# batchETL $ins_type "3rd" "$dir" "$code" "$thirdlisturl"

batchETL_InsRegpro "$ins_type" "$dir" "$code" "$regprolisturl"

