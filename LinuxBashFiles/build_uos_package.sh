#!/bin/bash

basedir=""        #当前脚本所在文件夹路径，绝对路径，在precheck中被赋值
foldname=""       #当前所在文件夹名去掉后面的版本号信息，在precheck中被赋值
appname=""        #如果foldname中含有.分隔符，则取最后一个字段的值，否则与foldname一致，在precheck中被赋值
version=""  	  #在precheck中被赋值
arch="unknown"	  #在precheck中被赋值
autostart_path="" #指向foldname文件夹中自启动程序，在file_move函数中被赋值
desktop_path=""   #指向foldname文件夹中桌面启动程序，在file_move函数中被赋值
icon_path=""       #指向foldname文件夹中图标文件，在file_move函数中被赋值

quiet="n"	  
if [ "$1" = "-q" ]; then
	quiet="y"
fi

function show_help()
{
	echo "说明："
	echo "该脚本为统信打包辅助脚本,请将该脚本应放置于符合'包名-版本号'格式的目录下执行"
	echo "执行脚本前，应先将待打包的文件放到当前脚本目录下的files文件夹中，最终这些文件会安装在\"/opt/apps/包名/files\"目录下"
	echo "如果程序需要开机自启动，请在当前脚本目录下创建名为autostart的链接文件，并指向files目录下相应程序"
	echo "如果程序需要创建桌面快捷方式，请在当前脚本目录下创建名为desktop的链接文件，并指向files目录下相应程序"
	echo "如果程序创建的桌面快捷方式需要指定图标，请在当前脚本目录下创建名为icon的链接文件，并指向files目录下相应png格式文件"
	echo "本脚本支持钩子文件，如果需要，将postinst、prerm脚本文件直接放在当前脚本目录下即可，脚本文件会自动检索并处理"
	echo "本脚本支持将文件安装在系统目录，方法为："
	echo "在files目录下创建rootdir文件夹，然后把要放置在系统目录下的文件，放在rootdir下即可"
	echo "安装包将在安装时，检索rootdir下的各文件，并拷贝到系统的相应目录，这些拷贝的文件将安装包卸载时自动删除"
	echo "安装包在拷贝这些文件时，会自动创建相应的父级目录，如果系统相应目录下已经存在同名文件，则将会备份这些就文件，并在安装包卸载时恢复"
	echo "例如存在files/rootdir/etc/profile.d/abc.sh，则安装时将会把abc.sh拷贝到/etc/profile.d目录下"
}

function _find_autostart()
{
	if [ -h autostart ]; then
	   autostart_path=`ls -ld autostart | awk '{print $NF}'`
	fi
	if [[ $autostart_path =~ ^/ ]]; then
		pwd_path=`pwd`
		if [[ $autostart_path =~ ^$pwd_path ]]; then
			autostart_path=${autostart_path:${#pwd_path}}
		fi
	fi
	autostart_path=${autostart_path/files/${foldname}/files}
	echo "-- autostart_path=$autostart_path"
	[ -f $autostart_path ] && return 0 || return 1
}

function _find_desktop()
{
	if [ -h desktop ]; then
	   desktop_path=`ls -ld desktop | awk '{print $NF}'`
	fi
	if [[ $desktop_path =~ ^/ ]]; then
		pwd_path=`pwd`/
		if [[ $desktop_path =~ ^$pwd_path ]]; then
			desktop_path=${desktop_path:${#pwd_path}}
		fi
	fi
	desktop_path=${desktop_path/files/${foldname}/files}
	echo "-- destktop_path=$desktop_path"
	[ -f $desktop_path ] && return 0 || return 1
}

function _find_icon()
{
	if [ -h icon ]; then
	   icon_path=`ls -ld icon | awk '{print $NF}'`
	fi
	if [[ $icon_path =~ ^/ ]]; then
		pwd_path=`pwd`/
		if [[ $icon_path =~ ^$pwd_path ]]; then
			icon_path=${icon_path:${#pwd_path}}
		fi
	fi
	
	echo "==icon_path=$icon_path"
	if [ -n "$icon_path" ] && [ -f $icon_path ]; then
		png=`file -b $icon_path | cut -f1 -d\ `
		if [ $png = PNG ]; then
			sz=`file -b $icon_path | cut -f4 -d\ `
			res=""
			case $sz in
			16)
				res=16x16	
				;;
			24)
				res=24x24
				;;
			32)
				res=32x32
				;;
			48)
				res=48x48
				;;
			128)
				res=128x128
				;;
			256)
				res=256x256
				;;
			512)
				res=512x512
				;;
			*)
				echo "图像分辨率(=$sz)不能识别或不符合标准"
				;;
			esac
			if [ -n "$res" ]; then
				echo "识别到图标文件的分辨率为$res"
				cp -f $icon_path $foldname/entries/icons/hicolor/$res/apps/${appname}_icon.png
				icon_path=$foldname/entries/icons/hicolor/$res/apps/${appname}_icon.png
			fi
		else
			echo "$icon_path不是真正的png格式图片"
		fi
	fi
}

function _precheck()
{
	#检查用户角色
#	if [ `whoami` = root ]; then
#		echo "请切换到普通用户下执行"
#		echo ""
#		return 1
#	fi

	if [ "`which dh_make`" = "" ]; then
		echo "请先安装dh_make工具"
		return 1
	fi
	if [ "`which dpkg-source`" = "" ]; then
		echo "请先安装dpkg-source工具"
		return 1
	fi
	if [ "`which dpkg-buildpackage`" = "" ]; then
		echo "请先安装dpkg-buildpackage工具"
		return 1
	fi
	if [ ! -d "/usr/share/build-essential" ]; then
		echo "请先安装build-essential工具"
		return 1
	fi

	#配置环境变量
	DEBFULLNAME="tongzhiweiye"
	DEBEMAIL="Service@tongzhi.com.cn"
	echo "环境变量"
	echo "DEBFULLNAME = $DEBFULLNAME"
	echo "DEBEMAIL    = $DEBEMAIL"
	
	#获取版本号
	path=`pwd`
	version=${path##*-}
	echo "版本号为:$version"
	
	#文件夹名字检查
	name=`pwd`
	basedir=$name
	name=${name##*/}
	name=${name%-*}
	foldname=$name
	[ -d $foldname ] && {
		echo "存在旧的$foldname文件夹，删除该文件夹"
		rm -rdf $foldname
		if [ ! $? = 0 ]; then
			echo "删除失败，请检查是否是权限问题"
			echo ""
			return 1
		fi
	}
	mkdir $foldname && echo "在当前目录下创建文件夹$foldname"
	appname=${name##*.}
	echo "应用名称为: $appname "
	
	#cpu架构
	_get_arch	
	echo "CPU架构为: $arch "
#	_do_sel
#	if [ $? = 2 ]; then
#		echo -n "指定CPU架构为: "
#		read arch
#	fi	
	echo ""
	return 0
}

function _make_entries()
{
	echo "make entries folder"
	cd $basedir/$foldname
	[ ! $? = 0 ] && echo "进入$basedir/$foldname目录失败" && return 1

	#创建entries目录树
	mkdir entries
	if [ ! $? = 0 ]; then
		echo "创建目录是否，请检查是否是权限问题"
		echo ""
		return 0
	fi
	cd entries
	mkdir applications
	mkdir autostart
	mkdir icons
	cd icons
	mkdir hicolor
	cd hicolor
	mkdir -p 16x16/apps
	mkdir -p 24x24/apps
	mkdir -p 32x32/apps
	mkdir -p 48x48/apps
	mkdir -p 128x128/apps
	mkdir -p 256x256/apps
	mkdir -p 512x512/apps
	mkdir -p scalable/apps
	cd ../../..
	if [ ! -d files ]; then
		mkdir files
	fi
	if [ ! -e info ]; then
		touch info
	fi
	echo "make entries filder ok"
	echo ""
	return 0
}

function _get_arch()
{
   case `uname -m` in
        i[3456789]86|x86|i86pc)
            arch='x86'
            ;;
        x86_64|amd64|AMD64)
            arch='amd64'
            ;;
        aarch64)
           arch='arm64'
           ;;
	mips64)
	   arch='mips64el'
	   ;;
        *)
           arch=`uname -m`
           ;;
    esac
    return 0
}

function _make_info()
{
	echo "make info file"
	cd $basedir/$foldname
cat << EOF > info 
{
  "appid": "$foldname",
  "name": "$appname",
  "version": "$version",
  "arch": ["$arch"],
  "permissions": {
    "autostart": false,
    "notification": false,
    "trayicon": false,
    "clipboard": true,
    "account": false,
    "bluetooth": false,
    "camera": false,
    "audio_record": false,
    "installed_apps": false
}
EOF
	if [ -n $autostart_path ] && [ -f $basedir/$autostart_path ]; then
		echo "modify info file for supporting autostart"
		sed -i 's/"autostart":.*$/"autostart": true,/' info
		sed -i 's/"trayicon":.*$/"trayicon": true,/' info
		sed -i 's/"notification":.*$/"notification": true,/' info
	elif [ -n $desktop_path ] && [ -f $basedir/$desktop_path ]; then
		echo "modify info file for supporting desktop file"
		sed -i 's/"trayicon":.*$/"trayicon": true,/' info
		sed -i 's/"notification":.*$/"notification": true,/' info
	fi
	echo "info 文件内容为:"
	cat info
	echo ""
	return 0
}

function _file_move()
{
	#文件
	cd $basedir
	echo "移动文件"
	if [ ! -d $foldname/files ]; then
		mkdir -p $foldname/files
	fi
	rm -rdf $foldname/files/*
	if [ -d files ]; then
	    echo "将当前files文件夹中的所有文件拷贝到$foldname/files目录下"
	    cp -rf files/* $foldname/files/
	fi

	_find_autostart
	[ $? = 0 ] && echo "开机自启动程序为：$autostart_path" || echo "当前目录下没有有效的 autostart 超链接，不创建开启自启动程序"
	_find_desktop
	[ $? = 0 ] && echo "桌面启动程序为：$desktop_path" || echo "当前目录下没有有效的 desktop 超链接，不创建桌面快捷方式"
	_find_icon
	[ -n "$icon_path" ] && [ -f $icon_path ] && echo "桌面程序图标路径：$icon_path" || echo "没有程序图标（必要时使用系统默认图标）"
	echo ""
	return 0
}

function _make_desktop()
{
	echo "make desktop file"
	cd $basedir/$foldname	
	desktop_file=""

	echo -n "请指定桌面图标的中文名(可以为空) : "
	read ch_name
cat >entries/applications/$appname.desktop <<EOF
[Desktop Entry]
Comment="$appname"
Exec="/opt/apps/$desktop_path"
Icon=/opt/apps/$icon_path
Name=$appname
Name[zh_CN]=$ch_name
Type=Application
X-Deepin-Vendor=user-custom
EOF
	if [ -z "$icon_path" ]; then
		sed -i "/^Icon/d" entries/applications/$appname.desktop
	fi
	if [ -z "$ch_name" ]; then
		sed -i "/^Name\[/d" entries/applications/$appname.desktop
	fi
	echo ""
	return 0
}

function _make_autostart()
{
	echo "make autostart file"
	cd $basedir/$foldname	
	desktop_file=""
cat >entries/autostart/$appname.desktop <<EOF
[Desktop Entry]
Comment="$appname"
Exec="/opt/apps/$autostart_path"
Name=$appname
Type=Application
X-Deepin-Vendor=user-custom
EOF
	echo ""
	return 0
}

function _fix_control()
{
	if [ ! -d debian ]; then
		echo "debian目录不存在"
		echo ""
		return 1
	fi
	cd debian
	if [ ! -e control ]; then
		echo "control文件不存在"
		echo ""
		return 1
	fi
	sed -i "s/^Section.*$/Section\: utils/" control
	sed -i "s/^Architecture.*$/Architecture\: $arch/" control
	sed -i "s/^Homepage.*$/Homepage\: $DEBEMAIL/" control
	#sed -i "s/^Section.*$/Section\:utils/" control
	cd ..
}

function _dealwith_script_files()
{
	cd ${basedir}
	if [ -f postinst ]; then
		cp postinst debian/postinst
	else
		echo "#!/bin/bash" > debian/postinst
	fi
	chmod a+x debian/postinst
	if [ -n $desktop_path ] && [ -f $desktop_path ]; then
		cat <<EOF >>debian/postinst
chmod a+x /opt/apps/$foldname/entries/applications/$appname.desktop
[ -d /usr/share/applications ] && cp /opt/apps/$foldname/entries/applications/$appname.desktop /usr/share/applications/
[ -d /home/\$USER/Desktop ] && cp /opt/apps/$foldname/entries/applications/$appname.desktop /home/\$USER/Desktop/
[ -d /home/\$USER/桌面 ] &&  cp /opt/apps/$foldname/entries/applications/$appname.desktop /home/\$USER/桌面/
for src in \`find /opt/apps/$foldname/files/rootdir/ -name "*"\`; do
	if [ -f \$src ]; then
		dst=/\`echo \$src | cut -d'/' -f7-\`
		if [ -f \$dst ]; then
			cp \$dst /opt/apps/$foldname/files/rootdir\${dst}.oldbak
		fi
                [ ! -d \$(dirname \$dst) ] && mkdir -p \$(dirname \$dst)
		cp -rf \$src \$dst
	fi
done
EOF
	fi
	if [ -n $autostart_path ] && [ -f $autostart_path ]; then
		echo "chmod a+x /opt/apps/$foldname/entries/autostart/$appname.desktop" >> debian/postinst
		echo "cp /opt/apps/$foldname/entries/autostart/$appname.desktop /etc/xdg/autostart/" >> debian/postinst
	fi

	if [ -f prerm ]; then
		cp prerm debian/prerm
	else
		echo "#!/bin/bash" > debian/prerm	
	fi
	chmod a+x debian/prerm
	cat <<EOF >>debian/prerm
tmp="/home/\$USER/Desktop/$appname.desktop"
if [ -e \$tmp ]; then
        rm \$tmp
fi
tmp="/usr/\$USER/桌面/$appname.desktop"
if [ -e \$tmp ]; then
        rm \$tmp
fi
tmp="/usr/share/applications/$appname.desktop"
if [ -e \$tmp ]; then
        rm \$tmp
fi
tmp="/etc/xdg/autostart/$appname.desktop"
if [ -e \$tmp ]; then
        rm \$tmp
fi
for src in \`find /opt/apps/$foldname/files/rootdir/ -name "*"\`; do
	if [ -f \$src ]; then
		dst=/\`echo \$src | cut -d'/' -f7-\`
		[ -f \$dst ] && rm -f \$dst
	fi
done
for src in \`find /opt/apps/$foldname/files/rootdir/ -name "*"\`; do
	if [ -f \$src ]; then
		if [[ \$src =~ .oldbak$ ]]; then
			dst=/\`echo \$src | cut -d'/' -f7-\`
			mv \$src \${dst%.*}
		fi
	fi
done
EOF
}

function _clear()
{
	echo "执行打包后清理工作"
	rm ../${foldname}_$version*.buildinfo >/dev/null 2>/dev/null
	rm ../${foldname}_$version*.changes >/dev/null 2>/dev/null
	rm ../${foldname}_$version*.dsc > /dev/null 2>/dev/null
	rm ../${foldname}_$version*.xz > /dev/null 2>/dev/null

	echo "是否清理打包产生的中间目录及文件(N/y)"
	read -n 1 key
	if [ "$key" = "y" ]; then
		rm -rdf ${foldname}
		rm -rdf debian
	fi
}

function make_package_0()
{
	_precheck
	[ ! $? = 0 ] && return 1
	_make_entries
	[ ! $? = 0 ] && return 1
	_file_move
	[ ! $? = 0 ] && return 1
	cd $basedir && [ -n "$desktop_path" ] && [ -f $desktop_path ] && echo "call make desktop " && _make_desktop && [ ! $? = 0 ] && return 1
	cd $basedir && [ -n "$autostart_path" ] && [ -f $autostart_path ] && echo "call make autostart" && _make_autostart && [ ! $? = 0 ] && return 1
	_make_info
	[ ! $? = 0 ] && return 1
	return 0
}

function make_package_1()
{

	#生成debian目录

	echo "make package 1, 生成打包关键文件(debian目录)"
	cd $basedir

	#echo ""
	#echo "删除历史文件"
	rm ../${foldname}_$version* >/dev/null 2>/dev/null

	echo ""
	echo "创建debian目录"
	if [ -e debian ]; then
		echo "存在旧的debian文件夹，删除该文件夹"
		rm -rdf debian
		if [ ! $? = 0 ]; then
			echo "删除失败，请检查是否是权限问题"
			echo ""
			return 1
		fi
	fi

	echo ""
	echo "打包初始化"
	dh_make --createorig -s
	[ ! $? = 0 ] && return 1
	rm debian/*.ex
	rm debian/*.EX
	
	echo "修复control文件"
	_fix_control

	echo ""
	echo "创建install文件"
	echo "$foldname/ /opt/apps" > debian/install

	echo ""
	echo "修改rules文件"
	sed -i "/\tdh\ /a override_dh_auto_build:\noverride_dh_shlibdeps:\noverride_dh_strip:\n" debian/rules

	echo ""
	echo "处理钩子文件"
	_dealwith_script_files
	echo ""
	return 0
}

function make_package_2()
{
	cd $basedir
	chk=`ls ../${foldname}_$version* | grep -v .deb$`
	if [ -z "$chk" ]; then
		echo "执行dh_make失败，缺少打包所需的相关文件"
		echo ""
		return 0
	fi

	echo "make package 2, 执行打包"
	dpkg-source -b .
	dpkg-buildpackage -us -uc -nc
	echo ""

	_clear
	echo ""

	deb_count=`ls ../${foldname}_$version*.deb | wc -l`
	if [ $deb_count = 1 ]; then
		deb=`ls ../${foldname}_$version*.deb`
		mv $deb ./
		echo "make package ok 打包完成,安装包生成在当前目录下"
	else
		echo "make package ok 打包完成,安装包生成在本文件夹上级目录下"
	fi
	echo ""
}

if [ "$1" = "-h" ] || [ "$1" = "-?" ] || [ "$1" = "--help" ]; then
	show_help
	exit
fi

if [ -z "$1" ]; then
show_help
echo "按回车键继续。。。"
read key
echo "----------------------------------------------------"
echo ""
fi

make_package_0
[ ! $? = 0 ] && exit
make_package_1
[ ! $? = 0 ] && exit
make_package_2

#调用结构：
#make_package_0()
#        _precheck()
#                _get_arch()
#        _make_entries()
#        _file_move()
#                _find_autostart()
#                _find_desktop()
#                _find_icon()
#        _make_desktop()
#        _make_autostart()
#        _make_info()
#make_package_1()
#        _fix_control()
#make_package_2()
#	_clear
