#!/bin/bash

#+----shell script to parse the input parameters and grep the list of headers in individual files
#+----invoke python script to take intersection of the headers and write a file with common headers
#+----use this list of common headers to parse out reads from the 4 input files parallelly

properties=`readlink -f input.parameters`
echo "Parsing properties File..."
echo "..."

IFS=$'\n';
for i in `cat $properties`;do
key=`echo $i | awk -F'=' '{print $1}'`
value=`echo $i | awk -F'=' '{print $2}'`
[[ $key == "solid.project.name" ]] && project=$value;
[[ $key == "solid.f3.csfasta.name" ]] && f1=$value;
[[ $key == "solid.f3.qual.name" ]] && f2=$value;
[[ $key == "solid.f5.csfasta.name" ]] && f3=$value;
[[ $key == "solid.f5.qual.name" ]] && f4=$value;
[[ $key == "solid.output.folder" ]] && output=$value;
[[ $key == "solid.get.common.headers" ]] && getheaders=$value;
[[ $key == "solid.run.demultiplexing" ]] && demultiplex=$value;
[[ $key == "solid.script.common.headers" ]] && pyscript=$value;
done

#remove all the trailing whitespace from the parsed parameters :-
output="${output%"${output##*[![:space:]]}"}" 
project="${project%"${project##*[![:space:]]}"}"
f1="${f1%"${f1##*[![:space:]]}"}"
f2="${f2%"${f2##*[![:space:]]}"}"
f3="${f3%"${f3##*[![:space:]]}"}"
f4="${f4%"${f4##*[![:space:]]}"}"
demultiplex="${demultiplex%"${demultiplex##*[![:space:]]}"}"
pyscript="${pyscript%"${pyscript##*[![:space:]]}"}"

#check if the output folder exists or not, else create
tmpfldr=$output/tmp
chunkflder=$tmpfldr/chunks
common=$output/common
[ ! -d $output ] && `mkdir $output`;
[ ! -d $tmpfldr ] && `mkdir $tmpfldr`;
[ ! -d $common ] && `mkdir $common`;
[ ! -d $chunkflder ] && `mkdir $chunkflder`;

rm -rf $chunkflder/*

#check all the input files are available :-
[[ ! -e $f1 ]] && echo "$f1 file not found. Script aborting..." && exit 1;
[[ ! -e $f2 ]] && echo "$f2 file not found. Script aborting..." && exit 1;
[[ ! -e $f3 ]] && echo "$f3 file not found. Script aborting..." && exit 1;
[[ ! -e $f4 ]] && echo "$f4 file not found. Script aborting..." && exit 1;

#+---copy files into shared folder :-
cp $properties $common
cp $pyscript $common

#get basenames

f1path=${f1%/*}
f1name=$(basename $f1)
[ ! -d $chunkflder/$f1name ] && `mkdir $chunkflder/$f1name`;
rm -rf $chunkflder/$f1name/*


f2path=${f2%/*}
f2name=$(basename $f2)
[ ! -d $chunkflder/$f2name ] && `mkdir $chunkflder/$f2name`;
rm -rf $chunkflder/$f2name/*


f3path=${f3%/*}
f3name=$(basename $f3)
[ ! -d $chunkflder/$f3name ] && `mkdir $chunkflder/$f3name`;
rm -rf $chunkflder/$f3name/*


f4path=${f4%/*}
f4name=$(basename $f4)
[ ! -d $chunkflder/$f4name ] && `mkdir $chunkflder/$f4name`;
rm -rf $chunkflder/$f4name/*

[ ! -d $tmpfldr/grep_outputs ] && `mkdir $tmpfldr/grep_outputs`;
rm -rf $tmpfldr/grep_outputs/*

[ ! -d $tmpfldr/grep_cmds ] && `mkdir $tmpfldr/grep_cmds`;
rm -rf $tmpfldr/grep_cmds/*

#Create grep command files

echo "Spawning scripts to farm out grep on cluster..."

cd $chunkflder/$f1name
split -l 6 $f1 f1_ &
PID1=$!
echo $PID1 is running ...
echo "#!/bin/bash" > $chunkflder/f1_GREP.cmd
echo "cd $chunkflder/$f1name" >> $chunkflder/f1_GREP.cmd
echo "for i in \`ls -1\`;do" >> $chunkflder/f1_GREP.cmd
echo "echo \"#!/bin/bash\" > $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f1_GREP.cmd
echo "echo \"grep \\\">\\\" $chunkflder/$f1name/\$i > $tmpfldr/grep_outputs/\${i}_headers\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f1_GREP.cmd
echo "echo \"touch $tmpfldr/grep_cmds/\$i.grep.complete\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f1_GREP.cmd
echo "done" >> $chunkflder/f1_GREP.cmd

cd $chunkflder/$f2name
split -l 6 $f2 f2_ &
PID2=$!
echo $PID2 is running ...
echo "#!/bin/bash" > $chunkflder/f2_GREP.cmd
echo "cd $chunkflder/$f2name" >> $chunkflder/f2_GREP.cmd
echo "for i in \`ls -1\`;do" >> $chunkflder/f2_GREP.cmd
echo "echo \"#!/bin/bash\" > $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f2_GREP.cmd
echo "echo \"grep \\\">\\\" $chunkflder/$f2name/\$i > $tmpfldr/grep_outputs/\${i}_headers\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f2_GREP.cmd
echo "echo \"touch $tmpfldr/grep_cmds/\$i.grep.complete\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f2_GREP.cmd
echo "done" >> $chunkflder/f2_GREP.cmd

cd $chunkflder/$f3name
split -l 6 $f3 f3_ &
PID3=$!
echo $PID3 is running ...
echo "#!/bin/bash" > $chunkflder/f3_GREP.cmd
echo "cd $chunkflder/$f3name" >> $chunkflder/f3_GREP.cmd
echo "for i in \`ls -1\`;do" >> $chunkflder/f3_GREP.cmd
echo "echo \"#!/bin/bash\" > $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f3_GREP.cmd
echo "echo \"grep \\\">\\\" $chunkflder/$f3name/\$i > $tmpfldr/grep_outputs/\${i}_headers\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f3_GREP.cmd
echo "echo \"touch $tmpfldr/grep_cmds/\$i.grep.complete\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f3_GREP.cmd
echo "done" >> $chunkflder/f3_GREP.cmd


cd $chunkflder/$f4name
split -l 6 $f4 f4_ &
PID4=$!
echo $PID4 is running ...
echo "#!/bin/bash" > $chunkflder/f4_GREP.cmd
echo "cd $chunkflder/$f4name" >> $chunkflder/f4_GREP.cmd
echo "for i in \`ls -1\`;do" >> $chunkflder/f4_GREP.cmd
echo "echo \"#!/bin/bash\" > $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f4_GREP.cmd
echo "echo \"grep \\\">\\\" $chunkflder/$f4name/\$i > $tmpfldr/grep_outputs/\${i}_headers\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f4_GREP.cmd
echo "echo \"touch $tmpfldr/grep_cmds/\$i.grep.complete\" >> $tmpfldr/grep_cmds/\${i}_grep.cmd" >> $chunkflder/f4_GREP.cmd
echo "done" >> $chunkflder/f4_GREP.cmd

# exec intermediary scripts : -

echo "#!/bin/bash" > $chunkflder/create_master.cmd
echo "cd $chunkflder" >> $chunkflder/create_master.cmd
echo "for i in \`ls -1 *_GREP.cmd\`;do" >> $chunkflder/create_master.cmd
echo "bash \$i" >> $chunkflder/create_master.cmd
echo "done" >> $chunkflder/create_master.cmd


#create the master grep file : -

echo "#!/bin/bash" > $tmpfldr/grep_cmds/MASTER_GREP.cmd
echo "cd $tmpfldr/grep_cmds" >> $tmpfldr/grep_cmds/MASTER_GREP.cmd
echo "for i in \`ls -1 *grep.cmd\`;do" >> $tmpfldr/grep_cmds/MASTER_GREP.cmd
#+----Uncomment qsub line for SGE ----
#echo "qsub -x \$i" >> $tmpfldr/grep_cmds/MASTER_GREP.cmd
#+----Uncomment qsub line for LSF ----
echo "bsub bash \$i" >> $tmpfldr/grep_cmds/MASTER_GREP.cmd
echo "done" >> $tmpfldr/grep_cmds/MASTER_GREP.cmd


wait $PID1
echo "Finishing generating scripts for $f1name ..."

wait $PID2
echo "Finishing generating scripts for $f2name ..."

wait $PID3
echo "Finishing generating scripts for $f3name ..."

wait $PID4
echo "Finishing generating scripts for $f4name ..."

sleep 2s

bash $chunkflder/create_master.cmd &
PID=$!
wait $PID

echo "..."
sleep 1s

cd $tmpfldr
echo "Launching grep on farm ..."
nohup bash $tmpfldr/grep_cmds/MASTER_GREP.cmd &

echo "..."
sleep 3s
awk '{print $2}' nohup.out > jobs.list

echo "#!/bin/bash" > $tmpfldr/wait.for.grep
echo "cd $tmpfldr/grep_cmds" >> $tmpfldr/wait.for.grep
echo "totalchunks=\`ls -1 *_grep.cmd | wc -l\`;" >> $tmpfldr/wait.for.grep
echo "grepcnt=\`ls -1 *grep.complete | wc -l\`;" >> $tmpfldr/wait.for.grep
echo "while [[ \$grepcnt -lt \$totalchunks ]]; do sleep 2s; grepcnt=\`ls -1 *grep.complete | wc -l\`; done" >> $tmpfldr/wait.for.grep
echo "echo -e \"$project update : grep completed on farm\n\" | mail dpurushotham136@gmail.com -s \"$project:grep completed\"" >> $tmpfldr/wait.for.grep
echo "bash $tmpfldr/grep_cmds/grep.concat.cmd &" >> $tmpfldr/wait.for.grep

#---------post grep steps : ----

echo "#!/bin/bash" > $tmpfldr/grep_cmds/grep.concat.cmd
echo "cd $tmpfldr/grep_outputs" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "cat f1* > $tmpfldr/f1.headers" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "touch $tmpfldr/f1.headers.ready" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "cat f2* > $tmpfldr/f2.headers" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "touch $tmpfldr/f2.headers.ready" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "cat f3* > $tmpfldr/f3.headers" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "touch $tmpfldr/f3.headers.ready" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "cat f4* > $tmpfldr/f4.headers" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "touch $tmpfldr/f4.headers.ready" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "cd $common" >> $tmpfldr/grep_cmds/grep.concat.cmd
echo "python get_common_headers.py" >> $tmpfldr/grep_cmds/grep.concat.cmd

bash $tmpfldr/wait.for.grep &>$tmpfldr/wait.log
