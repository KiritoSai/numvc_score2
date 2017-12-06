# !/bin/bash
all_results_dir="../result/"$1
solution="../solution/"$1
graph_dir="/mnt/data/dimacs"
graph_list="../list/dimacs_hard_list"
list_file=$(cat $graph_list)

SEND_THREAD_NUM=25
tmp_fifofile="/tmp/$$.fifo" # 脚本运行的当前进程ID号作为文件名 
mkfifo "$tmp_fifofile" # 新建一个随机fifo管道文件 
exec 6<>"$tmp_fifofile" # 定义文件描述符6指向这个fifo管道文件 
rm $tmp_fifofile 
for ((i=0;i<$SEND_THREAD_NUM;i++));do 
	echo # for循环 往 fifo管道文件中写入 $SEND_THREAD_NUM 个空行 
done >&6 

chmod a+x numvc
CUTOFF_TIME=2000

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


if [ -d "$all_results_dir" ]
then
	rm -r "$all_results_dir"
fi
mkdir "$all_results_dir"

for seed in `seq 1 10`
do
	echo "*************    $seed    *****************"
	for i in "${!arr_g[@]}"
	do
	    instance="${arr_g[$i]}"
	    echo "$instance"
	    res_dir="$all_results_dir"/"$instance"
		if [ ! -d "$res_dir" ]
		then
			mkdir "$res_dir"
		fi
		read -u6
		{
		    res_file="$res_dir"/"$instance"_$seed
		    ./numvc "$graph_dir/$instance" ${arr_o[$i]} $seed $CUTOFF_TIME > "$res_file"
		    echo >&6
		} &

	done

done

sleep CUTOFF_TIME
suc=0
avr_time=0
sum_time=0
rm ${solution}
echo -e "graph\t\tsuc\ttime" >> $solution

echo "****stat****"
for j in "${!arr_g[@]}"
do
    instance="${arr_g[$j]}"
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
	if [ ${vertex_size} -eq ${arr_o[$j]} ];then
	    let suc++
	fi
	time=$(awk 'NR==10 {printf "%.2f", $NF}' $res_file)
	sum_time=$(gawk -v x=$time -v y=$sum_time 'BEGIN{printf "%.2f\n",x+y}')
    done < res_dir_list
    
    rm res_dir_list
    avr_time=$(gawk -v x=$sum_time -v y=$res_dir_cnt 'BEGIN{printf "%.2f\n",x/y}')
    echo -n -e "\t"$suc >> $solution
    echo -n -e "\t"${avr_time}"\n" >> $solution
    let sum_time=0
    let avr_time=0
    let suc=0
done

exit 0
