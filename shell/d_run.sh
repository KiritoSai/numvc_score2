# !/bin/bash
all_results_dir=$1
graph_dir="/mnt/data/dimacs"
graph_list="./dimacs_hard_list"
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
exit 0
