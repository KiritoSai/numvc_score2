# !/bin/bash
all_results_dir=$1
graph_list="./dimacs_hard_list"
list_file=$(cat $graph_list)

n=0
index=0
for str in ${list_file}
do
    if [ ${n} -eq 0 ];then
	arr_g[$index]=$str
	n=1
    else
	arr_o[$index]=$str
	index=${index}+1
	n=0
    fi
done

suc=0
avr_time=0
sum_time=0
rm solution.xls
echo -e "graph\t\tsuc\ttime" >> solution.xls

echo "****stat****"
for i in "${!arr_g[@]}"
do
    instance="${arr_g[$i]}"
    echo -n "$instance" >> solution.xls
    res_dir="$all_results_dir"/"$instance"
    if [ ! -d "$res_dir" ]
    then
	echo "no $res_dir"
	exit 0
    fi
    res_dir_cnt=$(ls -l $res_dir|grep "^-"|wc -l)
    ls $res_dir > res_dir_list
    while read line
    do
	res_file="$res_dir"/"$line"
	if [ ! -f "$res_file" ]
	then
	    echo "no $res_file"
	    exit 0
	fi
	vertex_size=$(awk 'NR==8 {print $NF}' $res_file)
	if [ ${vertex_size} -eq ${arr_o[$i]} ];then
	    let suc++
	fi
	time=$(awk 'NR==10 {printf "%.2f", $NF}' $res_file)
	sum_time=$(gawk -v x=$time -v y=$sum_time 'BEGIN{printf "%.2f\n",x+y}')
    done < res_dir_list
    
    rm res_dir_list
    avr_time=$(gawk -v x=$sum_time -v y=$res_dir_cnt 'BEGIN{printf "%.2f\n",x/y}')
    echo -n -e "\t"$suc >> solution.xls
    echo -n -e "\t"${avr_time}"\n" >> solution.xls
    let sum_time=0
    let avr_time=0
    let suc=0
done

exit 0
