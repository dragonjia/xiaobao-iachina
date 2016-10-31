#!/bin/sh


## 功能目的
## 1. 抓取ins products page list 
## 2. extract 关键信息 到 csv文件
## 3. 组装 sql 片段
## 4. 拼合mysql inser语句



grep -A3 "\t\t\t<tr>" insPros.utf8 |sed 's/<[^>]*>//g'|awk 'BEGIN{
}{
  gsub("\t","");
  str=$0;
  if(NR%4==1){
	##do nothing
  }else if(NR%4==2){
	printf("saleName=\"%s\",",str);
  }else if(NR%4==3){
	printf("saleName=\"%s\",",str);
  }else if(NR%4==0){
	printf("saleName=\"%s\"\r\n",str);
  }
}END{
}'
|more