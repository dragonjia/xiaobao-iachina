echo "家庭财产类(燃气）"
fn_jiacai_prod="jiacai_prod";
mysql -h 101.201.115.106 -uxiaobao -p123456 iachina_db -e"select saleName,regName,ins_code from ins_register_products where  ins_type=1 and (saleName like '%家%' and regName like '%财%') or (saleName like '%燃气%')"|wc -l






