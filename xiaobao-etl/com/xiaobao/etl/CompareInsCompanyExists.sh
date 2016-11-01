gawk -F'\t' '

	 ##装载保险公司Map、保险公司简称Map
	 ##csv字段seq：
	 ##公司排名,Ename,公司,公司英文,别名,排名,参考数据1,参考数据2
	 func insertMap(key,nicknames,value,       _sname,_m1,_len,i,j,k){
		if(key in map){
			printf("自检:发现FullName 重复:%s\r\n",key) >> __self_test_report_file
		}else{
			totalInsCnt++;
	 	 	map[key]=value;
	 	 	_len=split(nicknames,_m1,";");
	 	 	for(i=1;i<=_len;i++){
		 	 	_sname=_m1[i];
	 	 		insertMap_shortName(_sname,value);
	 	 	}
 	 	}
	 }
	 ##装载保险公司简称Map	 
	 func insertMap_shortName(key,value,      _m1){
	 	if(key in map_short){
			printf("自检:发现ShortName重复:%s\r\n",key) >> __self_test_report_file
		}else{
 	 		map_short[key]=value;
 	 	}
	 }
	 ##对《保险公司DB》进行检测，输出报告
	 ##tudo: 无法输出……why？
	 func Self_Test_Report(   _line){
	 	#while( "cat /tmp/__self_test_report_file-compareInsComp"|getline d ) print d;
	 	while((getline _line<__self_test_report_file)>0) print _line;
	 }
	 ##根据  name 或 shortname 获取 map 的 value --$0 非结构化全部行信息
	 func getInfoByInsName(name,      shortname){
 	 	if(name in map) return map[name];
 	 	shortname=getShortName(name);
 	 	if(shortname in map_short) return map_short[shortname];
 	 	totalMissing_equal_ERROR++;
 	 	return __NULL;

	 }	 
	 ##获得name(保险名称字符串)的短名称---通过截取 [保险/公司] 关键字之前的字串
	 func getShortName(name,      len,_m1){
	 	len=split(name,_m1,"保险");
	 	if(len>=2) 
	 		return _m1[1];
	 	len=split(name,_m1,"公司");
	 	# if(len>=2) 
	 		return _m1[1];
	 	# else return name;
	 }

 	 func isExist(name,		_sname){
 	 	if(name in map){
 	 		totalHits_fullname++;
 	 		return __TRUE;
 	 	}
 	 	_sname=getShortName(name);
 	 	if(_sname in map_short){
 	 		totalHits_shortname++;
 	 		return __TRUE
 	 	}
 	 	else return __FALSE;
 	 }
 	 ## 当没有找到DB中的Fullname or shortname时，遍历DB查找是否是以下情况：
 	 ## 1. 具有二义性
 	 ## 2. （待补充）
 	 func diagnose(name, 	_name,_sname,_result,i,j){
 	 	##fullmaps ==> map
 	 	##shortmap ==> map_short
 	 	_sname=getShortName(name);
 	 	_result="\r\n---歧义:\r\n";
 	 	for(_name in map){
 	 		j=index(_name,_sname);
 	 		if(j>0) _result=_result"["_sname","_name"]\r\n";
 	 	}
 	 	for(_name in map_short){
 	 		j=index(_name,_sname);
 	 		if(j>0) _result=_result"["_sname","_name"]\r\n";
 	 	}
 	 	return _result;
 	 }

BEGIN{
	 __TRUE=1;
	 __FALSE=-1;
	 __NULL="<空值>";
	 __self_test_report_file="/tmp/__self_test_report_file-compareInsComp";
	 print("InsDB自检报告：") > __self_test_report_file
	 totalInsCnt=0;
	 totalHits_fullname=0;
	 totalHits_shortname=0;
	 totalMissing_equal_ERROR=0;
}
FNR==NR{
	name=$3;
	nicknames=$5;
	insertMap(name,nicknames,$0);
 }FNR<NR{
 	name=$1;
 	if(isExist(name)==__TRUE){
 		# printf("INS已存在:%s ==>%s\r\n",name,getInfoByInsName(name));
 	}else{
 		diagStr=diagnose(name);
 		printf("发现新名称：\t%s\t%s\r\n",name,diagStr);
 	}
 }END{
 	print("======================================");
 	Self_Test_Report();
 	printf("======================================\r\nsummary:\r\n加载数据：\t%d家保险公司\r\n命中次数(全名)：%d\r\n命中次数(短名)：%d\r\n查询时出错(程序逻辑上)：%d\r\n",totalInsCnt,totalHits_fullname,totalHits_shortname,totalMissing_equal_ERROR);

 }' ~/xiaobao/data/ins_companyDB.csv  ~/xiaobao/data/ins_sample.txt

	# "insDB自检报告："
 echo "========================="
 cat /tmp/__self_test_report_file-compareInsComp 
 cnt=`wc -l /tmp/__self_test_report_file-compareInsComp|awk '{print $1}'`
 cnt=`expr $cnt - 1`
 echo "#发现重复项："$cnt
 echo "========================="
 ##内容格式1：
 ##~/xiaobao/data/ins_companyDB.csv 
 ## 公司排名,Ename,公司,公司英文,别名,排名,参考数据1,参考数据2

##内容格式2：
 ## ~/xiaobao/data/ins_sample.txt
 ## 公司排名,Ename,公司,公司英文,别名,排名,参考数据1,参考数据2
