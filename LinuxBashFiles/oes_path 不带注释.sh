#!/bin/bash
#! /bin/bash
userdir=$1
max_cd_history=99		                    # 记录最大历史路径条数，需先删除/temporary_dir/$userdir/cd_history.log
export svn_path=/data/svn
#GCCVER=`gcc --version | head -n 1 | rev | cut -d' ' -f1 | rev | cut -d'.' -f1`
#* 显示帮助
alias hlp='func_help'				    # 列出自定义的命令,大多数命令都支持 -? 参数以获取命令帮助
#*
#* 命令简写
alias c="source /temporary_dir/$userdir/_visual_change_dir.sh"        # 使用类似于cd，但提供比cd更直观的显示效果，使用-?获取帮助
alias l='ls -lha --time-style="+%Y/%m/%d %H:%M"'    # 类似于ls -l,默认按名字排序，-t按时间排序，-S按大小排序，-r反向排序
alias var='export'				    # 同 export
alias hi='history'				    # 同 history
alias fs='du -hd 1'				    # 同 du -hd 1,列出当前目录下各个文件夹的名字及大小
alias js='jobs'					    # 同 jobs
#*
#* 目录管理
alias m='mem_data_func'                             # 目录跳转命令，输入 m -? 获得详细帮助
alias mc='mem_data_cd_func'                         # 跳转到变量目录，使用-?获取帮助
alias mm='mem_data_func2'                           # 快速存储当前目录，使用-?获取帮助
alias ml='mem_data_list_func'                       # 显示指定变量所记录的目录，使用-?获取帮助
alias mx='mem_variant_export'                       # 将 m 记录的变量导出为全局变量，使用-?获取帮助
alias remdir='export lastdir=`pwd`'                 # 将当前路径记录为变量 lastdir，不支持-?获取帮助
alias remd='export lastdir=`pwd`'                   # 同 remdir，不支持-?获取命令帮助
alias up='func_updir'                               # 后跟数字，表示上跳n级目录，使用-?获取帮助
alias upto='func_uptodir'                           # 后跟字符串，表上跳的字符串匹配的目录，使用-?获取帮助
alias up2='func_uptodir'                            # 同 upto，使用-?获取帮助
#*
#* 文件管理
alias sfp='func_push_files' 			    # stack file push，使用-?获取使用帮助
alias sfg='func_pop_file'   			    # stack file get，使用-?获取使用帮助
alias sfl='func_show_file'  			    # stack file list，使用-?获取使用帮助
alias sfd='func_clear_file' 			    # stack file delete，使用-?获取使用帮助
alias clonefile='func_copy_file'                    # 实现文件的多份拷贝，使用-?获取使用帮助
alias clf='func_copy_file'                          # 同 clonefile,使用-?获取使用帮助
alias cat2='func_cat2'                              # cat命令的功能增强版，使用-?获取帮助
alias del='func_del'				    # 文件删除到回收站，使用-?获取帮助
#*
#* 编程辅助
alias testload='func_call_test_load_so'             # 测试加载动态库，输入-?获取更多帮助
alias lookder='func_look_cert DER'                  # 查看证书，输入-?获取更多帮助
alias asn1view='func_asn1view'			    # 查看asn1文件结构，后跟asn1文件作为参数，不支持-?获取帮助
alias lf='func_list_func'		            # 列出文件中的函数位置，输入-?获取更多帮助
alias ff='func_find_file_func'                      # 查找函数定义(参数)所在的文件，输入-?获取更多帮助
#*
#* 屏幕输出
alias cls='printf "\033c"'                          # 清屏，不支持-?获取帮助
alias pl='printLine2'                               # 输出分割线，输入-?获取更多帮助
#*
#* 其它
alias telopen='func_telopen'                        # 同 export DISPLAY=参数1:0
alias quit='func_quit'				    # 退出，不支持-?获取帮助
alias notes='func_notes'                            # 记事本(同np)，使用-?获取帮助
alias np='func_notes'                               # 记事本(同notes)，使用-?获取帮助
alias notes2='func_notes2'                          # 记事本2(同npp)，使用-?获取帮助
alias npp='func_notes2'                             # 记事本2(同notes2)，使用-?获取帮助
alias xbc='func_export_bcpath'			    # 将svn/basecomponents路径下的一些常用路径导出为变量，不支持-?获取帮助
alias ti='func_set_title'       	            # 设置终端窗口标题,使用-?获取帮助
func_asn1view()
{
	asn1view_path=`which asn1view`
	if [ -z $asn1view_path ]; then
		if [ -f "$1" ]; then
			openssl asn1parse -inform DER -i -in $1
		else
			echo "参数错误"
		fi
	else
		$asn1view_path $1
	fi
}

func_find_file_func()
{
  if [ $# = 1 ]
  then
    if [ "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "功能：列出或打开定义了参数指定函数名的文件"
      echo "参数：要查找的函数名（区分大小写）"
      echo "      函数名支持模糊匹配符，模糊匹配符用+或...表示，如: +func、func...等"
      echo "      模糊匹配符可以写在函数名之前或之后，但不能出现在函数名之间"
      echo "      如果变量名前后不含模糊匹配符，则表示进行完全匹配搜"
      echo "附注：没有使用常见的*作为模糊匹配符，是因为*作为参数通常有特殊意义"
      return
    else
      param=$1
    fi
  else
    echo "输入参数错误，请使用-?参数获取命令帮助"
    return
  fi
  if [ "${param:0:1}" = "+" ]
  then
    param=${param:1}
  elif [ "${param:0:3}" = "..." ]
  then
    param=${param:3}
  else
    param="\<"$param
  fi
  if [ "${param:(-1)}" = "+" ]
  then
    param=${param:0:(-1)}
  elif [ "${param:(-3)}" = "..." ]
  then
    param=${param:0:(-3)}
  else
    param=$param"\>"
  fi
  echo "找到的函数有："
  grep -rne "$param"  --exclude=*.h | sed "s/::/：/" | awk -F : -v num=0 -v flag=1 '{ 
        s1=$1
        s2=$2
        $1=""
        $2=""
	if(match($0,/^\s*([a-zA-Z0-9_*<>]+\s+)+[a-zA-Z0-9_* :：<>]+\s*\([a-zA-Z0-9_, *<>]*/)>0)
	{
            if(match($0,/^\s*(if|elif|do|for|while)\s*\(/)==0)
	    {
	       if(match($0,/^\s*(else|return)\s+.*/)==0)
	       {
			num=num+1
			if(flag==1) {print ""}
                        printf("%-3d%s\n",num,$0);
	                print "     vim "s1" +"s2
			flag=1
		}
	    }
	}
    }' | grep -E "$param|^ "
}
func_export_bcpath()
{
    if [ -z "$1" ]; then
	echo "请指定svn路径作为参数，如 /data/svn"
    fi	
    if [ ! -d "$1" ]; then
	echo "svn路径不存在，请指定一个有效路径"
    else
	echo "svn_path = $1"
    fi
    _svn=$1
    _bc=$_svn/basecomponents
    _br=$_svn/baseroot
    _proj=$_bc/projects
    _core=$_proj/corelib
    _base=$_proj/base
    _ess=$_proj/ess
    export corelib_bin_path_d=$_core/develop/cpp/cpp.corelib.crypt/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Debug
    export corelib_bin_path_r=$_core/develop/cpp/cpp.corelib.crypt/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release
    export crypt_bin_path_d=$_core/develop/cpp/cpp.corelib.crypt/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Debug
    export crypt_bin_path_r=$_core/develop/cpp/cpp.corelib.crypt/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release
    export fx_path=/opt/FoxitSoftware/FoxitOfficeSuite
    export framework_bin_path_d=$_base/develop/cpp/cpp.eq.framework/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Debug
    export framework_bin_path_r=$_base/develop/cpp/cpp.eq.framework/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release
    export oes_bin_bath_d=$_ess/develop/cpp/cpp.ess.oes/1.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Debug
    export oes_bin_bath_r=$_ess/develop/cpp/cpp.ess.oes/1.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release
    export oes_deb_path=$_ess/setup/oes/1.0/scripts/output
    export oes_dpkg_path=$_ess/setup/oes/1.0/scripts/output
    export oes_plugin_path=/opt/DZQZ/tongz/oesplugin/plugins/cpp.ess.oes
    export oes_src_path=$_br/ess/trunk/source/cpp/src/cpp.ess.oes/ess.oes
    export ofd_plugin_path=/opt/tongz/readerplugin/plugins/cpp.ess.reader
    export ofd_src_path=$_br/ess/trunk/source/cpp/src/ofd
    export oesex_src_path=$_br/ess/trunk/source/cpp/src/cpp.ess.oes/ess.oes.ex
    export path_basecomponents=$_bc
    export path_baseroot=$_br
    export path_corelib_bin=$_core/develop/cpp/cpp.corelib.crypt/2.0.0.1
    export path_corelib_src=$_svn/baseroot/corelib/trunk/source/cpp/src/cpp.corelib.crypt/
    export path_framework_bin=$_base/develop/cpp/cpp.eq.framework/2.0.0.1
    export path_framework_src=$_br/framework/trunk/source/cpp/src/cpp.eq.framework
    export qtview_src_path=$_br/corelib/trunk/source/cpp/src/cpp.corelib.crypt/corelib.crypt.qtview
}
func_make_vim_cscopes()
{
if [ ! -d ~/.vim/plugin ]; then
  mkdir -p ~/.vim/plugin
fi
if [ ! -f ~/.vim/plugin/cscope_maps.vim ]; then
  echo "make vim cscopes_maps"
  touch ~/.vim/plugin/cscope_maps.vim
  cat >> ~/.vim/plugin/cscope_maps.vim <<EOF
if has("cscope")
    "s: 查找C语言符号，即查找函数名、宏、枚举值等出现的地方
    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    "g: 查找函数、宏、枚举等定义的位置，类似ctags所提供的功能	
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    "c: 查找调用本函数的函数	
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    "t: 查找指定的字符串	
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    "e: 查找egrep模式，相当于egrep功能，但查找速度快多了	
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>	
    "f: 查找并打开文件，类似vim的find功能
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    "i: 查找包含本文件的文	
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    "d: 查找本函数调用的函数
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>	
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
endif
EOF
fi
}
func_notes()
{
    if [ "$1" = "-?" -o "$1" = "--help" ]
    then
    	echo "记事本工具，用法：notes [-e/-v/-c/-n] [要记录的内容]"
	echo "如果参数是-e/-v，则用vim编辑器打开记录数据的记事本"
	echo "如果参数是-n或不带参数，则显示记事本内容（带-n时不显示行号）"
	echo "如果参数是-c，则清空记事本"
	echo "如果不是以上控制参数，则将notes之后的内容存放到记事本中"
	return
    elif [ "$1" = "-e" -o "$1" = "-v" ]; then
	vim "/temporary_dir/$userdir/notes.txt"
    elif [ "$1" = "-c" ]; then
	rm -f "/temporary_dir/$userdir/notes.txt"
	echo "日志已清空"
    elif [ "$1" = "-n" ]; then
	echo "日志内容:"
	cat /temporary_dir/$userdir/notes.txt
    elif [[ $# > 0 ]]; then
	echo "$*" >> "/temporary_dir/$userdir/notes.txt"
	if [ `whoami` = root ]; then
		chmod 666 "/temporary_dir/$userdir/notes.txt"
	fi
    else
	if [ -e /temporary_dir/$userdir/notes.txt ]; then	
		echo "日志内容:"
		cat -n /temporary_dir/$userdir/notes.txt
	else
		echo "记录为空"
	fi
    fi
}
func_notes2()
{
    if [[ $# < 1 ]] 
    then
	echo "参数个数错误，请使用-?或--help参数获取帮助"
	return
    fi
    if [ "$1" = "-?" -o "$1" = "--help" ]
    then
        echo "记事本工具2"
		echo "用法一：notes2 文件名"
		echo "        显示指定文件的内容（内容前带行号）"
		echo "用法二：notes2 文件名 -n/-d/-e/-v"
        echo "        -n：显示记事本内容（不显示行号）"
        echo "        -d：清空并删除指定名字的记事本"
        echo "        -e/-v：用vim编辑器打开指定名字的记事本"
		echo "用法三：notes2 文件名 要记录的内容"
		echo "        将要记录的内容存在指定名字的记事本中"
		echo "用法四：notes2 -l/--showa/--showall"
        echo "        -l：列出所有记事本的名字"
	    echo "        --showa：显示所有记录本的内容（不带行号）"
     	echo "        --showall：显示所有记事本的内容（带行号）"
	    echo "如果文件名为字符@时，将自动替换文件名为当天日期"
        return
    elif [ "$1" = "-l" ]
    then
	echo "/temporary_dir/$userdir/notes 目录下存在的日志文件有："
	ls "/temporary_dir/$userdir/notes"
	return
    elif [ "$1" == "--showall" ]
    then
	for f1 in /temporary_dir/$userdir/notes/*
	do
	    ff=$(basename $f1)
            echo "日志 ${ff} 的内容:"
            cat -n /temporary_dir/$userdir/notes/$ff
	    echo ""
	done
	return
    elif [ "$1" == "--showa" ]
    then
	for f2 in /temporary_dir/$userdir/notes/*
	do
	    ff=$(basename $f2)
            echo "日志 ${ff} 的内容:"
            cat /temporary_dir/$userdir/notes/$ff
	    echo ""
	done
	return
    fi
    name=$1
    if [ "$name" = "@" ]
    then
	name=`date "+%Y%m%d"`
    fi
    shift 1
    if [ "$1" = "-e" -o "$1" = "-v" ]; then
        vim "/temporary_dir/$userdir/notes/$name"
    elif [ "$1" = "-d" ]; then
        rm -f "/temporary_dir/$userdir/notes/$name"
        echo "日志已清空并删除"
    elif [ "$1" = "-n" ]; then
        echo "日志内容:"
        cat /temporary_dir/$userdir/notes/$name
    elif [[ $# > 0 ]]; then
        echo "$*" >> "/temporary_dir/$userdir/notes/$name"
        if [ `whoami` = root ]; then
                chmod 666 "/temporary_dir/$userdir/notes/$name"
        fi
    else
        if [ -e /temporary_dir/$userdir/notes/$name ]; then
                echo "日志内容:"
                cat -n /temporary_dir/$userdir/notes/$name
        else
                echo "记录为空"
        fi
    fi
}
func_del()
{
    if [ "$1" = "" -o "$1" = "-?" -o "$1" = "--help" ]
    then
	echo "提供文件回收站功能"
	echo "当参数是--clear时，清空回收站"
	echo "当参数是-l/--log时，显示文件删除日志"
	echo "当参数是-c/--cd时，跳转到回收站目录"
	echo "如果是文件或文件夹时，会将其移动到回收站中的日期/时间子目录下"
	echo '可以在要删除的文件或文件夹时，使用 -m "xxxx" 选项，以添加删除日志'
	echo '如：del -m "oldfiles" file1 file2 或 del file1 file2 -m "oldfiles"'
	echo "在回收站中存放所删除文件的日期/时间目录下，有restore.sh可执行文件"
	echo "执行该文件，会尝试将删除的文件还原到原来的位置"
	echo "该命令可同时删除多个文件，支持*作为参数，表删除该目录下所有文件"
	echo "删除多个文件时，请自行保证文件的存在性，否则可能会导致命令执行出错"
	echo "附注：目前只支持删除当前路径下的文件或文件夹"
	return
    elif [ "$1" = "--clear" ]; then
	echo "清空回收站"
	rm -rdf /temporary_dir/$userdir/dustbin/* 
	echo "文件删除日志:">/temporary_dir/$userdir/dustbin/del_log
	return
    elif [ "$1" = "--log" -o "$1" = "-l" ]; then
	cat /temporary_dir/$userdir/dustbin/del_log
	return
    elif [ "$1" = "--cd" -o "$1" = "-c" ]; then
	cd /temporary_dir/$userdir/dustbin
	echo "回收站目录："
        ls -lha --time-style="+%Y/%m/%d %H:%M"    # 类似于ls -l,默认按名字排序，-t按时间排序，-S按大小排序，-r反向排序
	return
    fi
    log=""
    files=$@
    if [ "$1" == "-m" ]
    then
	log=$2
	shift 2
	files=$@
    elif [ "${@: -2:1}" == "-m" ]
    then
	log=${@: -1}
	tmpstr=$@
	files=${tmpstr%-*}
    fi
    #echo "files = $files"
    if [ ! -e $1 ]; then
	echo "请检查输入参数是否正确"
	return
    fi
	day=`date "+%Y%m%d"`
	tim=`date "+%H%M%S"`
	td=`pwd`
	if [[ $1 =~ / ]]; then
	    echo "只支持删除当前目录下的文件或文件夹"
	    return
	fi
	[ ! -e /temporary_dir/$userdir/dustbin/$day ] && mkdir /temporary_dir/$userdir/dustbin/$day && chmod 777 /temporary_dir/$userdir/dustbin/$day
	[ ! -e /temporary_dir/$userdir/dustbin/$day/$tim ] && mkdir /temporary_dir/$userdir/dustbin/$day/$tim && chmod 777 /temporary_dir/$userdir/dustbin/$day/$tim
	mv -f $files /temporary_dir/$userdir/dustbin/$day/$tim
	cat>/temporary_dir/$userdir/dustbin/$day/$tim/restore.sh<<EOF
#day=\`date "+%Y%m%d"\`
#tim=\`date "+%H%M%S"\`
[ ! -e $td ] && mkdir -p $td
[ ! -e $td ] && echo "创建文件夹$td失败，无法恢复" && return 1
#echo "\${day}_\$tim :" >> /temporary_dir/$userdir/dustbin/del_log
#echo "  将\`pwd\`目录下的所有文件" >> /temporary_dir/$userdir/dustbin/del_log
#echo "  恢复到$td文件夹中" >> /temporary_dir/$userdir/dustbin/del_log
name1=\$(basename \$PWD)
name2=\$(dirname \$PWD)
name3=\$(basename \$name2)_\$name1
sed  -i "/^\${name3}/,+2d" /temporary_dir/$userdir/dustbin/del_log
flag=\`shopt|grep extglob\`
[ "\${flag:0-2}" = "ff" ] && shopt -s extglob
mv -i !(restore.sh) $td
[ "\${flag:0-2}" = "ff" ] && shopt -u extglob
dir=\`pwd\`
cd ${dir%/*}
rm -rdf \$dir
EOF
	cat>/temporary_dir/$userdir/dustbin/$day/$tim/delete.sh<<EOF
name1=\$(basename \$PWD)
name2=\$(dirname \$PWD)
name3=\$(basename \$name2)_\$name1
sed  -i "/^\${name3}/,+2d" /temporary_dir/$userdir/dustbin/del_log
dir=\`pwd\`
cd ${dir%/*}
rm -rdf \$dir
EOF
	chmod 777 /temporary_dir/$userdir/dustbin/$day/$tim/restore.sh
	chmod 777 /temporary_dir/$userdir/dustbin/$day/$tim/delete.sh
	echo "${day}_$tim : $log" >> /temporary_dir/$userdir/dustbin/del_log
	echo "  删除'$td'目录下的 $files" >> /temporary_dir/$userdir/dustbin/del_log
	echo "  存在'/temporary_dir/$userdir/dustbin/$day/$tim'文件夹中" >> /temporary_dir/$userdir/dustbin/del_log
	echo "已删除"
}
printLine()
{
    outword=$1
    divl=$3
    shellwidth=`stty size|awk '{print $2}'`
    shellwidth2=$[$shellwidth / $divl]
    printf $2= >> /temporary_dir/$userdir/_visual_change_dir.sh
    yes $outword | sed $shellwidth2'q' | tr -d '\n' >> /temporary_dir/$userdir/_visual_change_dir.sh
    echo '' >> /temporary_dir/$userdir/_visual_change_dir.sh
}
printLine2()
{
    if [ "$1" = "-?" -o "$1" = "--help" ]
    then
	echo "功能：绘制分割线，用法：pl [行数] [分割符号]"
        echo "分割符号可以是单个符号，也可以是字符串"
        echo "有些符号有特殊意义，如@、$、&等，可以在这样的符号两边加上引号"
        echo "没法指定*作为分隔符，因为*代表当前路径下的所有文件"
	return
    fi
    if [ -z "$1" ]; then
        repeat_time=1
    else
        repeat_time=$1
    fi
    if [ -z "$2" ]; then
        outword='——'
    else
        outword="$2"
    fi
    divl=${#outword}
    shellwidth=`stty size|awk '{print $2}'`
    shellwidth2=$[$shellwidth  * $repeat_time / $divl]
    yes $outword | sed $shellwidth2'q' | tr -d '\n'
    echo ''
}
func_telopen()
{
  if [ -z "$1" -o "$1" = '-?' -o "$1" = '--help' ]
  then	 
    echo '等价于 export DISPLAY=$1:0'	
    return
  elif [ $1 ]; then
    export DISPLAY=$1:0
  fi
}
func_copy_file()
{
  if [ $2 ]
  then
    copies=$2
  else
    copies=1
  fi
  if [ $copies -lt 1 ]
  then
     echo "拷贝份数最少为1份"
     return
  fi
  if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
  then
     echo "命令用法: clonefile/clf 文件名 [文件拷贝份数，默认为1]"
     return
  elif [[ "$1" =~ "/" ]]
  then
     echo "只支持对当前文件夹中文件的多份克隆"
	 echo "请直接指定文件名，不要带/"
	 return
  else
     filepath=`pwd`/$1
     filename=${filepath%.*}
	 if [[ "$1" =~ "." ]]; then
     extname=${filepath##*.}
	 extname=".$extname"
	 else
     extname=""
	 fi
     if test -e $filepath
     then
        count=1
	while(( $count<=$copies ))
	do
     	  if test -e "${filename}_${count}${extname}"
	  then 
		echo "${filename}_${count}.${extname}已存在，跳过"
          else
	    cp $filepath  "${filename}_${count}${extname}"
	    chmod 777 "${filename}_${count}${extname}"
	  fi
	  let "count++"
	done	
     else
	echo "$filepath 文件不存在"
     fi
  fi
}
mem_data_list_func()
{
  if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
  then
    echo "后跟一个路径变量名，路径变量通过m命令产生，功能类似于 ls -l 变量对应路径"
    return 1
  fi	  
  if [ ! -e /temporary_dir/$userdir/memdata_dir/$1 ]; then
      echo "变量不存在，请检查变量名是否正确"
      return 1
  fi
  printLine2 1 "——"
  printf "l "
  m $1
  echo ""
  mem_data_list_func2 `m $1`
}
mem_data_list_func2()
{
  if [ ! -e $1 ]; then
      echo "变量不存在，请检查变量名是否正确"
      return 1
  fi
  ls -lha --time-style="+%Y/%m/%d %H:%M" $1  
  printLine2 1 "-"
  echo "当前目录: ${PWD}"
  printLine2 1 "="
}
mem_data_cd_func()
{
  if [ "$1" = "-?" -o "$1" = "--help" ]
  then
    echo "后跟一个路径变量名，路径变量通过m命令产生，功能 : 跳转到该变量对应路径"
    echo "当没有带参数时，默认跳转到default_path"
    echo "注：关于default_path的产生，请参看mm命令的帮助信息"
    return 1
  fi	  
  tmp=$1
  if [ -z "$1" ]; then
    echo "没有指定跳转目标，跳转到默认目录default_path"
    tmp="default_path"
  fi
  if [ ! -e /temporary_dir/$userdir/memdata_dir/$tmp ]; then
    echo "变量不存在，请检查变量名是否正确"
    return 1
  fi
  source /temporary_dir/$userdir/_visual_change_dir.sh `m $tmp`
}
mem_variant_export()
{
  if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
  then
    echo "后跟一个路径变量名(路径变量通过m命令产生)，功能是将路径变量导出为全局变量"
    echo "后面跟 -a 或 --all 参数，表示将所有路径变量导出为全局变量"
    echo "后面跟 -c 或 --clear 参数，表示清除之前导出为全局变量的所有路径变量"
    return 1
  elif [ "$1" = "-a" -o "$1" = "--all" ]
  then
    func_export_memdatas
    return
  elif [ "$1" = "-c" -o "$1" = "--clear" ]
  then
    func_unset_memdatas
    return
  fi	  
  export $1=`m $1`
}
mem_data_func2()
{
  if [ "$1" = "-?" -o "$1" = "--help" ]
  then
    echo "后跟一个路径变量名，变量名自定，变量存放的值为当前路径，此命令为m命令的简化用法"
    echo "如果mm命令后面不带参数，则等同于 “mm default_path”"
    return 1
  fi	  
  tmp=$1
  if [ -z "$1" ]
  then
    tmp="default_path"
  fi
  mem_data_func $tmp `pwd`
}
mem_data_func()
{
  if [ -n "$3" ]
  then
    if [ "$1" = "-r" ]
    then
      if [ -e "/temporary_dir/$userdir/memdata_dir/$2" ]
      then
	unset $2
        mv -f "/temporary_dir/$userdir/memdata_dir/$2" "/temporary_dir/$userdir/memdata_dir/$3"
        echo "重命名变量 $2 为 $3"
	func_export_memdata $3	
      else
        echo "变量$2不存在"
      fi
    else
      echo "输入有误，可通过 --help,-?获取帮助"
    fi
  elif [ -n "$2" ]
  then
    if [ "$1" = "-d" ]
    then
      if [ "$2" = "-" ]
      then
        echo "清除记录的所有变量"
	func_unset_memdatas yy
        rm -f /temporary_dir/$userdir/memdata_dir/*
      else
        echo "清除变量$2"
        rm -f /temporary_dir/$userdir/memdata_dir/$2
	unset $2
      fi
    else
      if [[ "$1" == *"-"* ]]; then
	echo "变量名中不要包含字符-，否则会影响该变量名导出(export)为全局变量"
	echo "请换一个变量名"
        return -1
      fi
      echo $2>/temporary_dir/$userdir/memdata_dir/$1  
      func_export_memdata $1
      echo "$1 = $2"
    fi
  elif [ -n "$1" ]
  then
    if [ "$1" = "-d" ]
    then
      echo "请指定要删除的变量名或使用-删除所有变量"
	#显示帮助
    elif [ "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "---------------------------------------------"
      echo "* 命令字 ：列出记录的变量"
      echo "* 命令字 变量名 ：显示变量"
      echo "* 命令字 -?/--help ：显示帮助"
      echo "* 命令字 -d 变量名 ：清除变量"
      echo "* 命令字 -d - ：清除所有记录的变量"
      echo "* 命令字 变量名 字符串 ：存储变量"
      echo "* mc 变量名 : 跳转到存储的变量路径"
      echo "* mm 变量名 ：将当前路径存储到变量"
      echo "* ml 变量名 : 列出变量所代表目录的内容"
      echo "* 命令字 -r 旧变量名 新变量名 : 重命名"
      echo "---------------------------------------------"
    else
      if [ -e "/temporary_dir/$userdir/memdata_dir/$1" ]
      then
        cat /temporary_dir/$userdir/memdata_dir/$1
      else
        echo "该变量不存在"
      fi
    fi
  else
      if  [ "`ls -A /temporary_dir/$userdir/memdata_dir`" = "" ]
      then
        echo "变量记录为空"
      else
        echo "记录的变量有:"
	for file in /temporary_dir/$userdir/memdata_dir/*
	do
	  [ -d $file ] && continue
	  filename=`basename $file`
	  ll=$[15-${#filename}]
	  printf "$filename  "
	  seq -s '-' $ll | sed 's/[0-9]//g' | tr -d "\n"
	  printf "  "
	  cat $file
	done
      fi
  fi
}
func_export_memdatas()
{
      if [ -n "$1" ]; then
        if [ "$1" != "yy" ]; then
          echo "功能：导出(export)mem变量为全部变量"
          return 1
        fi
      fi
      func_unset_memdatas yy
      if [ ! -d "/temporary_dir/$userdir/memdata_dir" ]
      then
	return
      fi
      if  [ -n "`ls -A /temporary_dir/$userdir/memdata_dir`" ]
      then
	echo "#!/bin/bash" > /tmp/memdata_export.sh
	for file in /temporary_dir/$userdir/memdata_dir/*
	do
	  [ -d $file ] && continue
	  filename=`basename $file`
	  filecontent=`cat $file`
	  echo "export $filename=$filecontent 2>/dev/null" >> /tmp/memdata_export.sh
          if [ -f "/temporary_dir/$userdir/unexports.sh" ]; then
            if [ "$(grep $filename /temporary_dir/$userdir/unexports.sh)" = "" ]; then
              echo "unset $filename >/dev/null 2>&1" >> /temporary_dir/$userdir/unexports.sh
            fi
          fi
	done
	source /tmp/memdata_export.sh
	rm -f /tmp/memdata_export.sh
      fi
      if [ -z "$1" ]; then
      	  echo "已将所有mem变量导出(export)为全部变量"
      fi
}
func_export_memdata()
{
      if [ -f "/temporary_dir/$userdir/memdata_dir/$1" ]
      then
	  filecontent=`cat /temporary_dir/$userdir/memdata_dir/$1`
	  echo "export $1=$filecontent 2>/dev/null" >> /tmp/memdata_export.sh
      echo "unset $1 >/dev/null 2>&1" >> /temporary_dir/$userdir/unexports.sh
	  source /tmp/memdata_export.sh
	  rm -f /tmp/memdata_export.sh
      fi
}
func_unset_memdatas()
{
      if [ -n "$1" ]; then
        if [ "$1" != "yy" ]; then
          echo "功能：删除所有导出(export)的mem变量"
	  echo "该命令不需要参数"
	  echo "您可通过exm命令，或再次执行该脚本，将所有mem变量重新导出为全局变量"
          return 1
        fi
      else
        read -p "该命令会删除所有导出(export)的mem变量，确定吗？(y/n) " user_sel
        if [ "$user_sel" != "y" ]; then
            return 1
        fi
      fi	  
      source /temporary_dir/$userdir/unexports.sh
      echo "#! /bin/bash" > /temporary_dir/$userdir/unexports.sh
      if [ ! -d "/temporary_dir/$userdir/memdata_dir" ]
      then
	return
      fi
      if  [ -n "`ls -A /temporary_dir/$userdir/memdata_dir`" ]
      then
	for file in /temporary_dir/$userdir/memdata_dir/*
	do
	  filename=`basename $file`
	  unset $filename >/dev/null 2>&1	
	done
      fi
      if [ -z "$1" ]; then
	echo "已经删除所有导出(export)的mem变量"
      fi
}
func_look_cert()
{
  if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
  then
    echo "后跟证书文件名，使用openssl x509命令，展示证书内容"
    return 1
  fi	  
  openssl x509 -in $2 -inform $1 -noout -text
}
func_pool_framework()
{
    \cp -fu $svn_path/basecomponents/projects/base/develop/cpp/cpp.eq.framework/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release/lib* /opt/tongz/oesplugin/plugins/cpp.eq.framework/
    \cp -fu $svn_path/basecomponents/projects/base/develop/cpp/cpp.eq.framework/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release/eqsvc.bin /opt/tongz/oesplugin/plugins/cpp.eq.framework/
    chmod -R 777 /opt/tongz/oesplugin/plugins/cpp.eq.framework
}
func_pool_crypt()
{
    \cp -rfu $svn_path/basecomponents/projects/corelib/develop/cpp/cpp.corelib.crypt/2.0.0.1/sdk/runtime/$PLATFORMCODE/bin/Release/* /opt/tongz/oesplugin/plugins/cpp.ess.oes/../cpp.corelib.crypt/
    chmod -R 777 /opt/tongz/oesplugin/plugins/cpp.ess.oes/../cpp.corelib.crypt
}
func_pool_oes_depends()
{
    func_pool_framework
    func_pool_crypt
}
func_push_files()
{
    if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "stack file push，文件压栈命令"
      echo "后跟一个或多个文件/文件夹路径，支持*通配符"
      echo "文件可以使用绝对路径，也可以使用相对路径，这些文件[的位置]将被缓存"
      echo "相关命令：sfg 获取栈文件，sfl 展示栈文件，sfd 删除栈文件"
      return 1
    fi	  
    for f in "$@"; do
	printf "%s" $f
	func_push_file $f
    done
}
func_push_file() #sfp
{
    if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "stack file push，文件压栈命令"
      echo "后跟一个文件/文件夹路径，文件可以使用绝对路径，"
      echo "也可以使用相对路径，将该文件拷贝到缓存区"
      echo "相关命令：sfg 获取栈文件，sfl 展示栈文件，sfd 删除栈文件"
      return 1
    fi	  
    if [ ! -e $1 ]
    then
	echo "文件或目录不存在，请检查路径是否正确"
	return 1
    fi
    if [ `pwd` = "/" ] ;then 
	tmpdir=""
    else
	tmpdir=`pwd`
    fi
    if [ ${1:0:1} = / ]
    then
	if [ -d $1 ]
	then
	    echo cp -r $1 \$1 >> /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	else
	    echo cp $1 \$1 >> /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	fi
    elif [ ${1:0:2} = ./ ]
    then	    
	if  [ -d $1 ]
	then
	    echo cp -r $tmpdir/${1:2} \$1 >> /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	else
	    echo cp $tmpdir/${1:2} \$1 >> /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	fi
    else	    
	if  [ -d $1 ]
	then
	    echo cp -r $tmpdir/$1 \$1 >> /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	else
	    echo cp $tmpdir/$1 \$1 >> /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	fi
    fi 
    echo "文件/文件夹压栈完成"
}
func_show_file()
{
    if [ "$1" = "-?" -o "$1" = "--help" ]; then
	echo "stack file list : 展示栈中的文件"
	echo "相关命令：sfp 文件压栈，sfg 获取栈文件，sfd 删除栈文件"
	return 1
    elif [ -n "$1" ]; then
	echo "无效的参数，该命令只支持-?/--help参数"
	return 1
    fi
    echo "堆栈中的文件:"
    awk -v count=1 '$1=="cp"{
	if($2 == "-r")
		print NR ". [d] " $3 
	else
		print NR ". [f] " $2
	count=count+1}' /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
}
func_pop_file()
{
    if [ -z $1 -o $1 = "-?" -o $1 = "--help" ]; then
        echo "stack file get ：获取堆栈中的一个或多个文件"
        echo "参数为-时，获取所有文件"
        echo "参数为数字时，获取指定行文件，数字可以为负数，表从尾部开始算起"
        echo "参数为数字时，可以用'数字1,数字2'表示一段范围，获取多个文件"
        echo "参数为数字，且只获取一个文件或文件夹时，支持重命名，新名字通过第二个参数指定"
        echo "相关命令：sfp 文件压栈，sfl 展示栈文件，sfd 删除栈文件"
	return 1
   else 
        rename=""
	if [ ! -z $2 ]; then
	    if [ $1 -gt 0 -o $1 -lt 0 ] 2>/dev/null ; then
	       rename=$2
	    else
	       echo "只在获取单个文件或文件夹时，才可重命名"
	       return 1
	    fi
	fi
        if [ "$1" = "-" ]; then
    	    source /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh `pwd`/$rename
            echo "获取成功"
	else
	    nums=`sed -n '$=' /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh`
	    rng=$1
	    l1=${rng/,*/}
	    l2=${rng/*,/} 
	    if [ $l1 -lt 0 ]; then
	        (( l1 = $nums + $l1 + 1 ))
	    fi
            if [ ! "$l2" = "$l1" ]; then
	        if [ $l2 -lt 0 ]; then
		    (( l2 = $nums + $l2 + 1 ))
	        fi
		if [ $l1 -lt $l2 ]; then
		    rng="$l1,$l2"
		else
		    rng="$l2,$l1"
		fi
	    else
		rng=$l1
	    fi
    	    sed -n "${rng}p" /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh > /tmp/tmp_stack_files_info.sh 2>/dev/null
	    if [ $? = "0" ]; then
    	        source /tmp/tmp_stack_files_info.sh `pwd`/$rename
                echo "获取成功"
            else
                echo "语法错误，请检查参数是否正确"
	        echo "参数为-时，获取所有文件"
	        echo "参数为数字时，获取指定行文件"
        	echo "参数为数字时，可以用'数字1,数字2'表示一段范围，获取多个文件"
            fi
    	    rm -f /tmp/tmp_stack_files_info.sh
        fi
    fi
}
func_clear_file()
{
    if [ -z $1 -o $1 = "-?" -o $1 = "--help" ]; then
        echo "stack file delete ：删除堆栈中的一个或多个文件"
        echo "参数为-时，删除所有文件"
        echo "参数为数字时，删除指定行文件"
        echo "参数为数字时，可以用'数字1,数字2'表示一段范围，删除多个文件"
        echo "相关命令：sfp 文件压栈，sfl 展示栈文件，sfg 获取栈文件"
	return 1
    else
	if [ "$1" = "-" ]; then
	    : > /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
            echo "堆栈已清空"
	else
	    sed -i "$1d" /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh 2>/dev/null
	    if [ $? = "0" ]; then
                echo "删除成功"
            else
                echo "语法错误，请检查参数是否正确"
	        echo "参数为-时，删除所有文件"
	        echo "参数为数字时，删除指定行文件"
        	echo "参数为数字时，可以用'数字1,数字2'表示一段范围，删除多个文件"
		return 1
            fi
        fi
    fi
    echo "--------------------------------------"
    func_show_file
}
func_make_visual_change_dir()
{
	echo '#' > /temporary_dir/$userdir/_visual_change_dir.sh
	printLine "-" "line2" "1"
	printLine "——" "line1" "2"
	printLine "=" "line3" "1"
	cat >>/temporary_dir/$userdir/_visual_change_dir.sh <<EOF
func_cd()
{
	  if [ -z "\$1" ]; then
		echo "帮助："
		echo "支持 -h/-l ，列出跳转历史路径（记录$max_cd_history条历史路径）"
                echo "注意：每次切换目录后，因为新路径的加入，之间历史路径前面的序号会增1"
		echo "支持 -N ，N为1到$max_cd_history之间的数字，表回跳到倒数第N条历史路径"
		echo "如 c -1 回跳到倒数第1条历史路径，c -2 回跳到倒数第2条历史路径"
		echo "当参数为 - 时，等同于 c -1，回跳到倒数第1条历史路径，即上次路径"
		echo ""
		echo "历史路径："
		if [ -f /temporary_dir/$userdir/cd_history.log ]; then
			awk '{print "-"$max_cd_history+1-NR"\t"\$1}' /temporary_dir/$userdir/cd_history.log 
		fi	
                return
          fi
	  dst_dir=\$1
	  if [ \${1:0:1} = "-" ]; then
		case \$1 in
        	 -[1-9])
				if [ -f /temporary_dir/$userdir/cd_history.log ]; then
					idx=\${1:1}
	    				nums=\`sed -n '$=' /temporary_dir/$userdir/cd_history.log\`
					if [ \$idx -gt \$nums ]; then
						echo 输入的数值超过历史路径条数
						return
					fi
				        (( idx = \$nums - \$idx + 1 )) 
					dst_dir=\`sed -n "\${idx}p" /temporary_dir/$userdir/cd_history.log\`
				fi	
				;;
			-[1-9][0-9])
				if [ -f /temporary_dir/$userdir/cd_history.log ]; then
					idx=\${1:1}
	    				nums=\`sed -n '$=' /temporary_dir/$userdir/cd_history.log\`
					if [ \$idx -gt \$nums ]; then
						echo 输入的数值超过历史路径条数
						return
					fi
				        (( idx = \$nums - \$idx + 1 )) 
					dst_dir=\`sed -n "\${idx}p" /temporary_dir/$userdir/cd_history.log\`
				fi	
				;;
			"-h")
				if [ -f /temporary_dir/$userdir/cd_history.log ]; then
					awk '{print "-"$max_cd_history+1-NR"\t"\$1}' /temporary_dir/$userdir/cd_history.log 
				fi	
				return	
				;;
			"-l")
				show_lines=20
				if [ -n "\$2" ]; then
					if [ \$2 -gt 0 -a \$2 -lt 100 ]; then
						show_lines=\$2
					fi
				fi
				if [[ \$show_lines > $max_cd_history ]]; then
					show_lines=$max_cd_history
				fi
				if [ -f /temporary_dir/$userdir/cd_history.log ]; then
					tail -n \$show_lines /temporary_dir/$userdir/cd_history.log |  awk -v showlines=\$show_lines '{print NR-showlines-1"\t"\$1}' 
				fi	
				return	
				;;
			"-")
				if [ -f /temporary_dir/$userdir/cd_history.log ]; then
					dst_dir=\`sed -n '\$p' /temporary_dir/$userdir/cd_history.log\`
				fi	
				;;
			"-?")
				echo "支持 -h/-l ，列出跳转历史路径"
				echo "支持 -N ，N为1到$max_cd_history之间的数字，表回跳到倒数第N条历史路径"
				echo "如 c -1 回跳到倒数第1条历史路径，c -2 回跳到倒数第2条历史路径"
				echo "当参数为 - 时，等同于 c -1，回跳到倒数第1条历史路径，即上次路径"
				return	
				;;
			"--help")
				echo "支持 -h ，列出跳转历史路径"
				echo "支持 -N ，N为1到$max_cd_history之间的数字，表回跳到倒数第N条历史路径"
				echo "如 c -1 回跳到倒数第1条历史路径，c -2 回跳到倒数第2条历史路径"
				echo "当参数为 - 时，等同于 c -1，回跳到倒数第1条历史路径，即上次路径"
				return	
				;;
			*)
				echo "无效的选项，支持如下参数："
				echo "支持 -h ，列出跳转历史路径"
				echo "支持 -N ，N为1到$max_cd_history之间的数字，表回跳到倒数第N条历史路径"
				echo "如 c -1 回跳到倒数第1条历史路径，c -2 回跳到倒数第2条历史路径"
				echo "当参数为 - 时，等同于 c -1，回跳到倒数第1条历史路径，即上次路径"
				return	
				;;
		esac
	  fi
	  [ -f /temporary_dir/$userdir/cd_history.log ] && sed -i '1d' /temporary_dir/$userdir/cd_history.log && echo \`pwd\` >> /temporary_dir/$userdir/cd_history.log
	  if [ -d \$dst_dir ]; then
            cd \$dst_dir>/dev/null 2>&1 
            if [ \$? = 0 ]; then
 	      echo \$line1
	      ls -lhFAX --time-style="+%Y/%m/%d %H:%M"
	      echo \$line2
	      printf 当前目录：;pwd
	      echo \$line3
	    else
              echo "路径跳转失败，请检查是否有该路径的访问权限"
	    fi
         else
            echo "路径 \$dst_dir 不存在"
         fi
}
func_cd \$*
EOF
	[ `whoami` = root ] && chmod 777 /temporary_dir/$userdir/_visual_change_dir.sh
}
func_make_test_load_so()
{
	echo '#include<dlfcn.h>
	#include<stdio.h>
	int main(int argc,char* argv[])
	{
	  if(argc != 2)
	  {
		printf("falowed by a so file name as the param\n");
		return 0;
	  }
	  void * handle = NULL;
	  printf("test open file %s\n",argv[1]);
	  handle = dlopen(argv[1],RTLD_NOW);
	  if(handle)
	  {
		 printf("load library ok! handle = %p\n",handle);
		 dlclose(handle);
	  	 return 0;
	  }
	  else
	  {
		 printf("load library error : %s\n",dlerror());
		 return 1;
	  }
	}' > /temporary_dir/$userdir/test_load_so.cpp
	gcc -Wl,-rpath=.  /temporary_dir/$userdir/test_load_so.cpp -ldl -o /temporary_dir/$userdir/test_load_so.bin
	chmod a+x /temporary_dir/$userdir/test_load_so.bin
	rm -f /temporary_dir/$userdir/test_load_so.cpp
}
func_call_test_load_so()
{
    if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "后跟一个动态库名称，用以测试该动态库是否能正常加载"
      return 1
    fi
	/temporary_dir/$userdir/test_load_so.bin $1
    if [ $? -ne 0 ]; then
       echo ""
       echo "当前动态库所依赖的如下动态库加载失败："
       ldd $1 | cut -d ' ' -f 3 | awk '{cmd="/temporary_dir/test_load_so.bin "$0;if($0!="")system(cmd)}' | awk -v lastline="" '{if($0 ~ "error") print(lastline); lastline=$0}' | cut -d ' ' -f 4 
    fi
}
func_quit()
{
	count=1
	while(( $count ))
	do
          exit
	  let "count++"
	done	
}
func_updir()
{
    if [ "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "跳转到上级路径：需要一个数字n作为参数，默认为1"
      echo "该命令会从当前路径开始，向上跳n级"
      return 1
    fi
	count=1
	limit=$1
	if [ -z $limit ]; then
	  limit=1
	fi
	tempdir=`pwd`
	while(( $count<=$limit ))
	do
          cd .. 
	  let "count++"
	done	
	tempdir2=`pwd`
	cd $tempdir
	cd $tempdir2
	[ -f /temporary_dir/$userdir/cd_history.log ] && sed -i '1d' /temporary_dir/$userdir/cd_history.log && echo $tempdir >> /temporary_dir/$userdir/cd_history.log
	printLine2 1 "——"
	l
	printLine2 1 "-"
	echo "当前目录: ${PWD}"
	printLine2 1 "="
}
func_uptodir()
{
    if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "跳转到上级路径：需要一个名字作为参数，该命令会从当前路径开始，"
      echo "逐级往上查找，直到找到与指定字符串全部匹配或前部匹配的目录，"
      echo "然后跳转到该目录"
      return 1
    fi
	f1=${PWD}
	while(( 1 ))
	do
         cd .. 
	 limit=$1${PWD##*$1}
	 fold=${PWD##*/}
	 if [ "$limit" == "$fold" ];then
	   break 
	 fi	
	done	
	f2=${PWD}
 	cd $f1
	cd $f2	
	[ -f /temporary_dir/$userdir/cd_history.log ] && sed -i '1d' /temporary_dir/$userdir/cd_history.log && echo $f1 >> /temporary_dir/$userdir/cd_history.log
	printLine2 1 "——"
	l
	printLine2 1 "-"
	echo "当前目录: ${PWD}"
	printLine2 1 "="
}
func_help()
{
    if [ "$1" = "-h" ]; then
       awk '$1=="alias" { 
        sub("=.*","",$2);
        notes=substr($0,index($0,"#"));
        printf("%-20s%s\n",$2,notes);
        } 
        $1=="#*" { 
        print($2);
        }' $BASH_SOURCE
    elif [ "$1" = "" ]; then
       awk '$1=="alias" { 
        sub("=.*","",$2);
        notes=substr($0,index($0,"#"));
        printf("%-20s%s\n",$2,notes);
        }' $BASH_SOURCE | sort
    else
       echo "参数错误，可以不使用参数，或使用-h参数"
       echo "不使用参数时，按名字排序"
       echo "使用-h参数时，按类别排序"
    fi
}
func_cat2()
{
    if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "功能：显示文件的指定行"
      echo "用法：cat2 [-n] 文件名 [要显示的行]"
      echo "要显示的行号可以是一个数字，也可以用'起始行号,结束行号'表示多行"
      echo "可用\$表最后一行，不指定行号时，默认显示所有行"
      echo "更多的表示行号的方法，可参看sed命令的帮助"
      return 1
    fi
    if [ "$1" = "-n" ]; then
        echo "$3:"
        sed -n "$3p" $2
    else
        sed -n "$2=;$2p" $1 | sed "N;s/\n/ : /"
    fi
}
func_list_func()
{
    if [ -z "$1" -o "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "功能：列出文件中函数所在行，目前只适用于c/c++/java/js类的源文件"
      echo "注意：本功能列出的函数结果仅供参考，可能存在漏选或错选的情况"
      echo "请在命令后指定要检索的文件"
      return 1
    fi
    awk '{ 
	if(match($0,/^\s*([a-zA-Z0-9_*<>]+\s+)+[a-zA-Z0-9_*:<>]+\s*\([a-zA-Z0-9_, *<>]*/)>0)
	{
        if(match($0,/^\s*(if|elif|do|for|while)\s*\(/)==0)
	    {
	       if(match($0,/^\s*(else|return)\s+.*/)==0)
	       {print NR" : "$0;}
	    }
	}
    }' $1
}
func_exec_profile()
{
    tmp=`pwd`
    if [ "$profile_exec_flag" == "" ]; then
        profile_exec_flag=yes
        #source /etc/profile
    fi
    cd $tmp
    export EQ_COMPONENTS=$svn_path/basecomponents
    export EQ_CPP_PUBLIB=$EQ_COMPONENTS/projects/base/develop/cpp/cpp.publib/1.0.0.1/sdk
    export PS1='\[\e[33m\]\u@\h:\W:\!\$\[\e[m\] '
}
func_set_title()
{
    if [ "$1" = "-?" -o "$1" = "--help" ]
    then
      echo "用法: ti [要设置的窗口标题], 不指定标题时，恢复默认标题"
      return 1
    fi	  
    PS1_ORI='\[\e[33m\]\u@\h:\W:\!\$\[\e[m\] '
    if [ -z "$1" ]; then
        PS1=$PS1_ORI
        return 1
    fi
    TITLE="\[\e]2;$*\a\]"
    PS1=${PS1_ORI}${TITLE}
}
func_make_file_dir()
{
    if [ `whoami` == root ]
    then
        [ ! -d /temporary_dir/$userdir/notes ] && mkdir -p /temporary_dir/$userdir/notes
        [ ! -d /temporary_dir/$userdir/memdata_dir ] && mkdir -p /temporary_dir/$userdir/memdata_dir
        [ ! -d /temporary_dir/$userdir/file_transfer_stack ] && mkdir -p /temporary_dir/$userdir/file_transfer_stack && touch /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh 
        [ ! -e /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh ] && touch /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	[ ! -d /temporary_dir/$userdir ] && mkdir /temporary_dir/$userdir
	if [ ! -f /temporary_dir/$userdir/cd_history.log ]; then
		#for i in {1..10}
		for (( i=0;i<$max_cd_history;i++ )); 
		do
			echo '.' >> /temporary_dir/$userdir/cd_history.log
		done
	fi
	[ -f /temporary_dir/$userdir/cd_history.log ] && chmod 777 /temporary_dir/$userdir/cd_history.log
	[ ! -d /temporary_dir/$userdir/dustbin ] && mkdir /temporary_dir/$userdir/dustbin && echo "文件删除日志："> /temporary_dir/$userdir/dustbin/del_log
	[ ! -f /temporary_dir/$userdir/unexports.sh ] && touch /temporary_dir/$userdir/unexports.sh
	[ -d /temporary_dir/$userdir ] && chmod -R 777 /temporary_dir/$userdir
    else
        [ ! -d /temporary_dir/$userdir/notes ] && mkdir /temporary_dir/$userdir/notes && chmod 777 /temporary_dir/$userdir/notes
        [ ! -d /temporary_dir/$userdir/memdata_dir ] && mkdir /temporary_dir/$userdir/memdata_dir && chmod 777 /temporary_dir/$userdir/memdata_dir
        [ ! -d /temporary_dir/$userdir/file_transfer_stack ] && mkdir /temporary_dir/$userdir/file_transfer_stack && chmod 777 /temporary_dir/$userdir/file_transfer_stack && touch /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh && chmod 777 /temporary_dir/$userdir/file_transfer_stack/stack_files_info.sh
	[ ! -d /temporary_dir/$userdir/dustbin ] && mkdir /temporary_dir/$userdir/dustbin && chmod 777 /temporary_dir/$userdir/dustbin
	[ ! -e /temporary_dir/$userdir/dustbin/del_log ] && echo "文件删除日志："> /temporary_dir/$userdir/dustbin/del_log && chmod 777 /temporary_dir/$userdir/dustbin/del_log
	[ ! -e /temporary_dir/$userdir/unexports.sh ] && touch /temporary_dir/$userdir/unexports.sh && chmod 777 /temporary_dir/$userdir/unexports.sh
	if [ ! -d /temporary_dir/$userdir ]; then
		mkdir /temporary_dir/$userdir
		chmod	/temporary_dir/$userdir
	fi
	if [ ! -f /temporary_dir/$userdir/cd_history.log ]; then
		for (( i=0;i<$max_cd_history;i++ )); 
		do
			echo '.' >> /temporary_dir/$userdir/cd_history.log
		done
		[ -f /temporary_dir/$userdir/cd_history.log ] && chmod 777 /temporary_dir/$userdir/cd_history.log
	fi
    fi
}
init()
{
	if [[ -e /temporary_dir/$userdir ]]
	then
	   func_make_file_dir
	   func_make_visual_change_dir
	   func_exec_profile
	   func_export_memdatas yy
	   func_make_vim_cscopes
	   echo "----ok----"
	elif [[ `whoami` == root ]]
	then
	   [ ! -d /temporary_dir ] && mkdir /temporary_dir
	   chmod 777 /temporary_dir
	   if [ -n "$userdir" ];
	   then
	     mkdir /temporary_dir/$userdir
	     chmod 777 /temporary_dir/$userdir
	   fi
	   func_make_file_dir
	   func_make_visual_change_dir
	   func_make_test_load_so
	   func_exec_profile
	   func_export_memdatas yy
	   func_make_vim_cscopes
	   filename="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	   filename+="/"
	   filename+=$(basename ${BASH_SOURCE})
	   echo '#!/bin/bash' > /tmp/oes_path.sh
	   sed "/^\s*##/d;/^\s*$/d" $filename  >> /tmp/oes_path.sh
	   chattr -i $filename
	   mv -f /tmp/oes_path.sh $filename
	   chattr +i $filename
	   echo "----ok----"
	else
	   echo 这是第一次执行该脚本，请先切换到管理员身份执行	
	fi
}
init
