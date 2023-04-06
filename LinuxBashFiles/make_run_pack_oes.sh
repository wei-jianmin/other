#! /bin/bash
#run安装包头
lines=46
rand=$RANDOM
echo "正在执行安装操作，请稍等..."
ziptool=`whereis unzip | cut -d:  -f2`
if [ "$ziptool" == "" ]; then
    echo "请先在您的电脑上安装unzip工具"
    exit 0
fi
if [ ! `whoami` == root ]; then
    echo "请切换到管理员权限下执行安装操作"
    exit 0
fi
if [ ! -d /opt/apps/com.tongzhi.oesplugin/files ]; then
    mkdir -p /opt/apps/com.tongzhi.oesplugin/files
    if [ ! $? = 0 ]; then
	echo "创建安装目录失败"
	exit 0
    fi
fi
tail -n +$lines $0 >/tmp/$rand.zip 
if [ ! -f /tmp/$rand.zip ];then
    echo "分离oes签章插件压缩包失败"
    exit 0
fi
cd /tmp
unzip -qo $rand.zip "lib/*" -d /opt/apps/com.tongzhi.oesplugin/files
if [[ $? != 0 ]]; then
    echo "oes签章插件安装包解压失败"
    exit 0
fi
unzip -qoj $rand.zip "udev/*" -d /etc/udev/rules.d
if [[ $? != 0 ]]; then
    echo "oes签章插件安装包解压失败"
    exit 0
fi
unzip -qoj $rand.zip "etc/*" -d /etc/profile.d
if [[ $? != 0 ]]; then
    echo "oes签章插件安装包解压失败"
    exit 0
fi
rm -f /tmp/$rand.zip 
echo "oes签章插件安装在 /opt/apps/com.tongzhi.oesplugin/files/lib 目录下, 重启后生效"
exit 0
