#!/bin/bash

pkg_name=""
randstr=`cat /proc/sys/kernel/random/uuid  | cksum | cut -f 1 -d' '`

if [ "$1" = "-?" ]; then
	echo ""
	echo "说明："
	echo "该脚本会把前目录下rpmbuild文件夹下的东西原样安装到系统目录下"
	echo ""
	echo "如果需要执行安装后脚本，请把脚本内容写在 rpmbuild/opt/tmp/postinst.sh 中"
	echo "如果需要执行卸载前脚本，请把脚本内容写在 rpmbuild/opt/tmp/preuninst.sh 中"
	echo "为防止因脚本执行错误而导致安装或卸载失败，建议脚本以 exit 0 作为结束行"
	echo ""
	echo "注意1：要打包的文件名及文件夹名不要包含空格，否则会导致打包失败"
	echo "注意2：如果您之前安装过待打包程序的旧安装包，请先卸载旧的安装包后再进行打包"
	echo ""
	exit
fi

echo "1. 打包条件检查"
if [ `whoami` = root ]; then
	echo "请切换到普通用户执行该脚本"
	exit
fi

echo "2. 检查当前目录下是否有rpmbuild文件夹"
if [ ! -d rpmbuild ]; then
	echo "当前目录下不存在rpmbuild文件夹，请使用-?获取脚本帮助信息"
	exit
fi

echo "3. 检查~/rpmbuild是否已存在"
if [ -e ~/rpmbuild ]; then
	echo "   已经存在~/rpmbuild,按y键删除，其它键退出"
	k=y
	read -n 1 k
	echo ""
	if [ "$k" = "y" ]; then
		rm -rdf ~/rpmbuild
		if [ ! $? = 0 ]; then
			echo "删除失败，请手动删除"
			exit
		fi
	else
		exit
	fi
fi

function prepare_rpmbuild
{
	mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,SPECS,RPMS} 2>/dev/null
}

function read_dir()
{
    files=`ls $1`
    
    #文件夹为空时，也记录在列表中
    if [ "$files" = "" ]; then
        echo "%dir /$1" >> /tmp/filelist.txt
    fi

    for file in `ls $1`
    do
        cur=$1/$file
        if [ -d $cur ]; then
	    if [ "${cur:0:4}" = "opt/" ]; then
		[ ! "$cur" = "opt/tmp" ] && echo "%dir /$cur" >> /tmp/filelist.txt
	    else
	    	[ ! -d "/$cur" ] && echo "%dir /$cur" >> /tmp/filelist.txt
	    fi
            read_dir $cur
        else
            echo "/$cur" >> /tmp/filelist.txt
        fi
    done
}

function list_dir()
{
    if [ ! -d $1 ]; then
        exit
    fi

    tmpdir=`pwd`
    cd $1
   
    [ -f /tmp/filelist.txt ] && rm -f /tmp/filelist.txt

    for file in `ls`
    do
    	if [ -d $file ]; then
            #echo "%dir /$file" >> /tmp/filelist.txt
            read_dir $file
    	else
            echo "/$file" >> /tmp/filelist.txt
    	fi
    done

    [ -f /tmp/filelist.txt ] && mv /tmp/filelist.txt ~/rpmbuild/BUILD/

    cd $tmpdir
}

function prepare_spec_file()
{
    read -p "   请指定安装包名[demo]：" pkg_name
    [ -z "$pkg_name" ] && pkg_name="demo"
    read -p "   请指定版本[1.0.0]： " ver
    [ -z "$ver" ] && ver="1.0.0"
    read -p "   请简单描述该安装包的功能[可省略]：" disc1
    [ -z "$disc1" ] && disc1=$pkg_name

    cat >~/rpmbuild/SPECS/${pkg_name}.spec <<EOF 
Name:    $pkg_name		
Version: $ver	
Release: 1%{?dist}
Summary: $disc1

Group:  tzwy		
License: GPLv3+	
URL:	www.tongzhi.com.cn

AutoReqProv:no

%description

%prep
for f in \`ls /opt/tmp/postinst_*.sh\`
do
	pkg_name0=\`sed -n "/#package name/p" \$f | cut -d':' -f 2\`
	if [[ \$pkg_name0 =~ $pkg_name ]]; then
		echo "错误:\$pkg_name0 已安装，请先卸载后，再执行本操作"
		exit 1
	fi
done

#%build

%install
cp -rp %{_builddir}/* %{buildroot}/
[ -f %{buildroot}/filelist.txt ] && rm %{buildroot}/filelist.txt

%pre
for f in \`ls /opt/tmp/postinst_*.sh\`
do
	pkg_name0=\`sed -n "/#package name/p" \$f | cut -d':' -f 2\`
	if [[ \$pkg_name0 =~ $pkg_name ]]; then
		echo "错误:\$pkg_name0 已安装，请先卸载后，再执行本操作"
		exit 1
	fi
done

%post
if [ -f /opt/tmp/postinst_$randstr.sh ]; then
	echo "#package name : %{name}-%{version}-%{release}.%{_arch}" >> /opt/tmp/postinst_$randstr.sh
	echo "#install time : `date +%F/%H:%M:%S`" >> /opt/tmp/postinst_$randstr.sh
	/bin/bash /opt/tmp/postinst_$randstr.sh
fi

%preun
[ -f /opt/tmp/preuninst_$randstr.sh ] && /bin/bash /opt/tmp/preuninst_$randstr.sh

%files
%files -f filelist.txt
EOF
}

function clean()
{
	rm -rdf ~/rpmbuild
}

function move_rpm()
{
	src=`find ~/rpmbuild/RPMS -name "*.rpm"`
	echo "src=$src"
	echo "dst=`pwd`"
	[ -f $src ] &&	cp $src `pwd`/
}

function make_rpm()
{
	tmp=`pwd`
	cd ~/rpmbuild/SPECS
	QA_RPATHS=$[ 0x0001|0x0002|0x0004|0x0008|0x0010|0x0020 ] rpmbuild -bb ${pkg_name}.spec
	cd $tmp
}

function copy_files()
{
	cp -r rpmbuild/* ~/rpmbuild/BUILD/

	[ -f ~/rpmbuild/BUILD/opt/tmp/postinst.sh ] &&  mv ~/rpmbuild/BUILD/opt/tmp/postinst.sh ~/rpmbuild/BUILD/opt/tmp/postinst_$randstr.sh
	[ -f ~/rpmbuild/BUILD/opt/tmp/preuninst.sh ] &&  mv ~/rpmbuild/BUILD/opt/tmp/preuninst.sh ~/rpmbuild/BUILD/opt/tmp/preuninst_$randstr.sh

	if [ ! -d ~/rpmbuild/BUILD/opt/tmp ]; then
            mkdir -p ~/rpmbuild/BUILD/opt/tmp
	fi

	if [ ! -f ~/rpmbuild/BUILD/opt/tmp/postinst_$randstr.sh ]; then
	    echo "#!/bin/bash" > ~/rpmbuild/BUILD/opt/tmp/postinst_$randstr.sh
	fi
}

echo "4. 准备~/rpmbuild"
prepare_rpmbuild

echo "5. 将rpmbuild下的文件拷贝到~/rpmbuild/BUILD/"
copy_files

echo "6. 准备filelist.txt文件"
list_dir ~/rpmbuild/BUILD

echo "7. 准备spec文件"
prepare_spec_file

echo "8. 执行rpmbuild打包命令"
make_rpm

if [ $? = 0 ]; then
	echo "9. 拷贝安装包到当前目录"
	move_rpm
	
	echo "10. 打包后清理工作"
	#clean
fi
