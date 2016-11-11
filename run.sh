# !/bin/bash

SEND_THREAD_NUM=2
tmp_fifofile="/tmp/$$.fifo" # 脚本运行的当前进程ID号作为文件名 
mkfifo "$tmp_fifofile" # 新建一个随机fifo管道文件 
exec 6<>"$tmp_fifofile" # 定义文件描述符6指向这个fifo管道文件 
rm $tmp_fifofile 
for ((i=0;i<$SEND_THREAD_NUM;i++));do 
	echo # for循环 往 fifo管道文件中写入 $SEND_THREAD_NUM 个空行 
done >&6 

chmod a+x numvc
CUTOFF_TIME=1000

instance_dirs="bio col fb inf int rec ret sci soc tec web"
#"bio col fb inf int rec ret sci soc tec web"

all_results_dir=$1
#"results_dir_rm"
graph_dir="/home/pkutcs/graphs"
if [ -d "$all_results_dir" ]
then
	rm -r "$all_results_dir"
fi
mkdir "$all_results_dir"

for seed in `seq 1 1`
do
	echo "*************    $seed    *****************"
	for dir in $instance_dirs
	do
		echo "$dir"
		res_dir="$all_results_dir"/"$dir"
		if [ ! -d "$res_dir" ]
		then
			mkdir "$res_dir"
		fi
		ls "$graph_dir/$dir" | while read instance 
		do
			read -u6
			{
				res_dir="$res_dir"/"$instance"
				if [ ! -d "$res_dir" ]
				then
					mkdir "$res_dir"
				fi
				res_file="$res_dir"/"$instance"_$seed
				./numvc "$graph_dir/$dir/$instance" 0 $seed $CUTOFF_TIME > "$res_file"
				echo >&6
			} &
		done
	done
done

exit 0
