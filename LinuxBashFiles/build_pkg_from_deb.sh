#!/bin/bash

package_name=""

function get_package_name()
{
	nums=`ls *.deb | wc -l`
	if [ "$nums" = "0" ]; then
		echo "当前目录下未找到deb包"
	elif [ "$nums" = "1" ]; then
		package_name=`ls *.deb`
	else
		echo "在当前目录下发现多个deb包，请确保只有一个安装包"
	fi
	
}

function root_check()
{
	if [ `whoami` = root ]; then
		return 1
	else
		return 0
	fi
}

function unpack()
{
	get_package_name
	if [ -z ${package_name} ]; then
		return 0
	fi
 	echo "找到原始安装包的名字为：${package_name}"		

	if [ -d extract ]; then
		echo "当前目录下存在 extract 文件夹"
		echo "解包操作会 !删除并重建! 该文件夹"
		echo "输入 y 确认，输入其他键结束该操作"
	fi
	
	rm -rdf ./extract
	mkdir -p extract/DEBIAN
	
	read -n 1 sel
	if [ "$sel" = "y" ]; then
		dpkg -X ${package_name} ./extract
		dpkg -e ${package_name} ./extract/DEBIAN
		echo "安装包已解药到 extract 文件夹中"
	fi
	return 0	
}

function update_time()
{
	#ver=`date "+4.0.%y.%m%d"`
	ver=""
	if [ -f extract/DEBIAN/control ]; then
		printf "原始的版本号为："
		echo `sed -n '/Version/p' ./extract/DEBIAN/control | cut -d':' -f 2`
		printf "请输入新的版本号:"
		read ver
		if [ -z $ver ]; then
			read ver
		fi
		sed -i "s/Version.*$/Version: $ver/" ./extract/DEBIAN/control
		echo "------------------------------------------------------------"
		echo "完成对 ./extract/DEBIAN/control 文件的修改,修改后的内容为："
		cat ./extract/DEBIAN/control
	else
		echo "未找到待打包的数据文件"
		return 0
	fi

	info_file=`find ./ -name "info"`
	if [ -n $info_file -a -f $info_file ]; then 
		info_line=`sed -n "/"version"/p" $info_file`
		if [ -n $info_line ]; then
			sed -i "s/\"version\".*$/\"version\":\"$ver\",/" $info_file
			echo "------------------------------------------------------------"
			echo "完成对 $info_file 文件的修改,修改后的文件内容为："
			cat $info_file
		fi
	fi
}

function pack()
{
	if [ ! -d extract/DEBIAN ]; then
		echo "未找到待打包的数据文件"
		return 0
	fi

	if [ ! -d build ]; then
		mkdir build
	fi

	dpkg -b ./extract ./build
	if [ $? = 0 ]; then
		echo "打包完成，新的安装包生成在 build 文件夹中"
	fi
}

function main()
{
	echo "请将本脚本及原始deb包文件放在一个单独的文件夹中"
	echo "按任意键继续"
	read -n 1 sel

	#root_check
	#if [ $? = 0 ]; then
	#	echo "请切换到root执行"
	#	return 0
	#fi
	

	echo ""
	echo "请选择要执行的操作:"
	echo "1. 解包"
	echo "2. 自动修改解包后文件中的日期信息"
	echo "3. 打包"
	read -n 1 sel
	echo ""
	if [ "$sel" = "1" ]; then
		unpack
	elif [ "$sel" = "2" ]; then
		update_time
	elif [ "$sel" = "3" ]; then
		pack
	else
		echo "输入错误"
		return 0
	fi
}

main
