#!/bin/sh
###or use #!/bin/bash

if [ $# -lt 3 ]; then
	echo "Usage: `basename $0` type input_name output_name!"
	echo "       type include: -c or -x"
	exit 1
fi

TYPE=$1
INPUT=$2
OUTPUT=$3


if [ $TYPE = "-c" ]
then 
	echo ""
	echo "compressed files: $INPUT* => $OUTPUT"
	echo ""
	
	INPUT_FILES=`ls $INPUT*`
	OUTPUT=$OUTPUT.tar.gz
	
	SEEK_NUM=0 #输出文件偏移块个数
	SKIP_NUM=0 #输入文件跳过块个数 默认0
	PER_LEN=`expr 99 \* 1024 \* 1024`  # 每个文件99M大小
	
	for FILE in $INPUT_FILES
	do 
		echo "for: $FILE to $OUTPUT"
		dd if=$FILE of=$OUTPUT bs=$PER_LEN count=1 skip=$SKIP_NUM seek=$SEEK_NUM
		SEEK_NUM=`expr $SEEK_NUM + 1`
		echo ""
	done
	
	tar -xzvf $OUTPUT
	rm -rf $OUTPUT

elif [ $TYPE = "-x" ]
then	
	echo ""
	echo "explode files: $INPUT => $OUTPUT*"
	echo ""
	
	tar -czvf $INPUT.tar.gz $INPUT
	INPUT=$INPUT.tar.gz
	
	INPUT_LEN=`ls -l $INPUT | awk '{ print $5 }'`
	PER_LEN=`expr 99 \* 1024 \* 1024`  # 每个文件99M大小
	NUM=`expr $INPUT_LEN / $PER_LEN` #整数个
	REM=`expr $INPUT_LEN % $PER_LEN` #余数字节
		
	if [ $NUM -gt 0 ]
	then
		SEEK_NUM=0 #输出文件偏移块个数 默认0
		SKIP_NUM=0 #输入文件跳过块个数
		for i in $(seq 1 $NUM)  
		do  
			echo "for: $i in $NUM"
			OUTPUT_I=$OUTPUT$i
			dd if=$INPUT of=$OUTPUT_I bs=$PER_LEN count=1 skip=$SKIP_NUM seek=$SEEK_NUM
			SKIP_NUM=`expr $SKIP_NUM + 1`
			echo ""
		done	
	fi
	
	if [ $REM -gt 0 ]
	then
		SEEK_NUM=0 #输出文件偏移块个数 默认0
		SKIP_NUM=$NUM #输入文件跳过块个数
		ALL_NUM=`expr $NUM + 1`
		echo "remainder: $REM in $ALL_NUM"
		OUTPUT_I=$OUTPUT$ALL_NUM
		dd if=$INPUT of=$OUTPUT_I bs=$PER_LEN count=1 skip=$SKIP_NUM seek=$SEEK_NUM
		echo ""
	fi
	
	rm -rf $INPUT
	
else
	echo ""
	echo "error input params!"
	echo ""
fi


