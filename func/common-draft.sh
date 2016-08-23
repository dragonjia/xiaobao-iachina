
commonMark=1;
	

function makeDirExist(){

	local dir=$1;
	if [[ ! -d $dir ]]
	then
		echo ">>>>>>>>>>"
		echo "DIR not Exist,Make it! ($dir)"
		echo "<<<<<<<<<<"
		mkdir "$dir"
	fi
}

function iconvert(){
	local _file=$1;
	if [[ ! -e $_file ]]
	then
		echo "iconvert:::FILE NOT FOUND (file=\"$_file\")!"
		exit 1;
	fi
	_tmpfile="/tmp/asdkjfalskdfa.tmp"
	mv $_file $_tmpfile
	iconv -f GBK -t UTF8 $_tmpfile|tr -d '\r' > $_file
}

function getParameter( )
{
	local url=$1;
	local param=$2;
#	echo "begin pick up param========> url=$url,param=$2"
#	echo "debug:>>>>>>>>>>>>>>>>"
	echo "$url"|awk -v param="$param" 'BEGIN{
			
	}{
		url=$0;
		for ( a in _ret ) {delete _ret[a];}
		#print url;
		split(url,_m,"?|&|=");
		for(i=2;i<=1024;i+=2){
			_key=_m[i];
			if(_key=="") break;
			_ret[_key]=_m[i+1];
			#print "DEBUG:_m[i]="_key;
		}
		if( param in _ret){
				print _ret[param];
			exit;
		}

	}END{
	}'
#	echo "debug:<<<<<<<<<<<<<"
}


## 计数器： 实际效果： 外部函数每次调用会导致计数器初始化，没到到效果。
___wgetFromUrlToFile_count=0;
___wgetFromUrlToFile_err=0;

function wgetFromUrlToFile(){
	local url=$1;
	local file=$2;
	msg="function wgetFromUrlToFile()::: file=$file ::: url=$url"
	$(syslog "$msg") || echo $msg;
	# echo $msg
	###done检验输入参数正确性
	let ___wgetFromUrlToFile_count++

	## 调试断点 ： todu delete。。。。
	# if [[ ___wgetFromUrlToFile_count -ge 5 || ___wgetFromUrlToFile_err -ge 5 ]]; then
	# 	return;
	# fi
	wget  "$url" -O "$file" || let ___wgetFromUrlToFile_err++


	msg="wgetFromUrlToFile:::COUNT:::$___wgetFromUrlToFile_count :::ERR::: $___wgetFromUrlToFile_err ";
	$(syslog "$msg")|| echo $msg 

}


