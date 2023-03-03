#!/bin/bash
b_r="$EQ_COMPONENTS/projects/base/develop/cpp/cpp.publib/1.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release"
b_d="$EQ_COMPONENTS/projects/base/develop/cpp/cpp.publib/1.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Debug"
l_r="$EQ_COMPONENTS/projects/base/develop/cpp/cpp.publib/1.0.0.1/sdk/runtime/$PLATFORMCODE/lib/Release"
l_d="$EQ_COMPONENTS/projects/base/develop/cpp/cpp.publib/1.0.0.1/sdk/runtime/$PLATFORMCODE/lib/Debug"

mkdir -p $b_r
mkdir -p $b_d
mkdir -p $l_r
mkdir -p $l_d

base_dir=`pwd`
logname="`pwd`/publib_publish.log"
echo "file move log:" > $logname

for d in `ls`
do
	cd $base_dir
	if [ -d $d/build_linux/bin/$PLATFORMCODE ]; then
		cd $d/build_linux/bin/$PLATFORMCODE 
		if [ -d lib ]; then
			cd lib
			echo "get in `pwd`" >> $logname
			for f in `ls`
			do
				if [ -f $f ]; then
					if [ -x $f ]; then
						cp $f $b_r
						cp $f $b_d
						echo "cp $f $b_r" >> $logname
						echo "cp $f $b_d" >> $logname
					else
						cp $f $l_r
						cp $f $l_d
						echo "cp $f $l_r" >> $logname
						echo "cp $f $l_d" >> $logname
					fi
				fi
			done
		elif [ -d release/lib ]; then
			cd release/lib
			echo "get in `pwd`" >> $logname
			for f in `ls`
			do
				if [ -f $f ]; then	
					if [ -x $f ]; then
						cp $f $b_r
						echo "cp $f $b_r" >> $logname
					else
						cp $f $l_r
						echo "cp $f $l_r" >> $logname
					fi
				fi
			done
		elif [ -d Release/lib ]; then
			cd Release/lib
			echo "get in `pwd`" >> $logname
			for f in `ls`
			do
				if [ -f $f ]; then	
					if [ -x $f ]; then
						cp $f $b_r
						echo "cp $f $b_r" >> $logname
					else
						cp $f $l_r
						echo "cp $f $l_r" >> $logname
					fi
				fi
			done
		elif [ -d debug/lib ]; then
			cd debug/lib
			echo "get in `pwd`" >> $logname
			for f in `ls`
			do
				if [ -f $f ]; then	
					if [ -x $f ]; then
						cp $f $b_d
						echo "cp $f $b_d" >> $logname
					else
						cp $f $l_d
						echo "cp $f $l_d" >> $logname
					fi
				fi
			done
		elif [ -d Debug/lib ]; then
			cd Debug/lib
			for f in `ls` 
			do
				if [ -f $f ]; then	
					if [ -x $f ]; then
						cp $f $b_d
						echo "cp $f $b_d" >> $logname
					else
						cp $f $l_d
						echo "cp $f $l_d" >> $logname
					fi
				fi
			done
		fi
	fi
done
