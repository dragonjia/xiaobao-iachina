gawk -F'\t' '
	 func loadMapPH(key,value,       _m1,_m2){
 	 	map_ph[key]=value;
 	 	split(key,_m1,"保险");
 	 	key=_m1[1];
 	 	map_ph2[key]=value;
	 }
	 func loadMapEN(key,value,      _m1){
 	 	map_en[key]=value;
 	 	split(key,_m1,"保险");
 	 	key=_m1[1];
 	 	map_en2[key]=value;

	 }	 
 	 func getPH(name){
 	 	if(name in map_ph){
 	 		return map_ph[name];
 	 	}else{
 	 		if(name in map_ph2)
 	 			return map_ph2[name];
 	 		else 
 	 			return "";#NA";	
 	 	} 
 	 }
 	 func getEname(name){
 	 	if(name in map_en){
 	 		return map_en[name];
 	 	}else{
 	 		if(name in map_en2)
 	 			return map_en2[name];
 	 		else
 	 			return "";#-1;
 	 	}
 	 }


FNR==NR{
	loadMapPH($1,$2);
	loadMapEN($1,$3);
 }FNR<NR{
 	name=$1;
	ph=getPH(name);
	ename=getEname(name);
	#print name"\t"ph"\t"ename;
	print ph;
 }END{


 }' ~/xiaobao/ins_company/iachina.toplist  ~/xiaobao/ins_company/ins_company_circ.toplist 