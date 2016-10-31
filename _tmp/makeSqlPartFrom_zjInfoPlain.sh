#!/bin/sh

## 输入文本文件，输出 SQL语句
in_fn=$1;
out_fn=$2;
cat $fn|awk -F'：' 'BEGIN{
		sql="";
	}{
		gsub(/\t/,"");
		sql0=sql;
		if(index($1,"全称")>0) sql=sql0"fullname=\""$2"\"";
		if(index($1,"简称")>0) sql=sql0",shortname=\""$2"\"";
		if(index($1,"网站地址")>0) sql=sql0",siteurl=\""$2"\"";
		if(index($1,"备案信息")>0) sql=sql0",icp_info=\""$2"\"";
		if(index($1,"范围")>0) sql=sql0",biz_op_range=\""$2"\"";

		# if(index($1,"全称")>0) sql=sql0"fullname="111"";
		# if(index($1,"简称")>0) sql=sql0",shortname="222"";
		# if(index($1,"网站地址")>0) sql=sql0",siteurl="333"";
		# if(index($1,"备案信息")>0) sql=sql0",icp_info="444"";
		# if(index($1,"范围")>0) sql=sql0",biz_op_range="555"";

	}END{
		print sql;
	}'