#! /bin/bash
#run安装包头
lines=31
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
if [ ! -d /opt/apps/com.tongzhi.tzreader ]; then
    mkdir -p /opt/apps/com.tongzhi.tzreader
fi
tail -n +$lines $0 >/opt/apps/com.tongzhi.tzreader/tzreader.zip 
if [ ! -f /opt/apps/com.tongzhi.tzreader/tzreader.zip ];then
    echo "分离阅读器压缩包失败"
    exit 0
fi
cd /opt/apps/com.tongzhi.tzreader
unzip -qo tzreader.zip 
if [[ $? != 0 ]]; then
    echo "阅读器安装包解压失败"
    exit 0
fi
rm -f /opt/apps/com.tongzhi.tzreader/tzreader.zip 
echo "阅读器安装在 /opt/apps/com.tongzhi.tzreader 目录下"
exit 0
