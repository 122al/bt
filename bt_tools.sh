#!/bin/bash
#全局变量
version_url=https://download.btpanel.cm
down_url=https://22.al
btdown_url=https://download.bt.cn
panel_path=/www/server/panel
tools_version='Build 210903'
#检测新版本
new_version(){
    new_version=$(curl -Ss --connect-timeout 100 -m 300 https://www.btpanel.cm/home/tools/version)
    if [ "$new_version" = '' ];then
	    echo -e "获取版本号失败正在尝试更新......"
	    wget -O btpanel_tools.sh ${version_url}/tools/btpanel_tools.sh && bash btpanel_tools.sh
	    exit 0
	    
    fi
    if [ "${new_version}" != ${tools_version} ];then
        echo -e "检测到已发布新版本正在尝试更新......"
	    wget -O btpanel_tools.sh ${version_url}/tools/btpanel_tools.sh && bash btpanel_tools.sh
	    exit 0
    fi
    echo -e "还没有发布新版本"
    back_home
}
#获取宝塔版本
auth_version(){
    auth_version='官方正版'
    crackurl="0"
	CRACK_URL=(oss.yuewux.com download.btpanel.net 182.61.16.58 hostcli.com fenhao.me seele.wang moetas.com 05bt.com);
	for url in ${CRACK_URL[@]};
	do
		CRACK_INIT=$(cat /etc/init.d/bt |grep ${url})
		if [ "${CRACK_INIT}" ];then
			auth_version='破解版本'
			crackurl=${url}
		fi
		CRACK_TOOLS=$(cat ${panel_path}/tools.py|grep ${url})
		if [ "${CRACK_TOOLS}" ];then
			auth_version='破解版本'
			crackurl=${url}
		fi
		CRACK_PLUGIN=$(cat ${panel_path}/class/panelPlugin.py|grep ${url})
		if [ "${CRACK_PLUGIN}" ];then
			auth_version='破解版本'
			crackurl=${url}
		fi
	done
	g_version=$(cat ${panel_path}/class/common.py |grep 'g.version =')
	btpanel_version=${g_version:21:5}
}
auth_version

#清理垃圾
cleaning_garbage(){
    echo -e "正在清理面板缓存......"
    rm -f ${panel_path}/*.pyc
    rm -f ${panel_path}/class/*.pyc
    echo -e "已完成清理面板缓存......"
    echo -e "正在清理PHP_SESSION......"
    rm -rf /tmp/sess_*
    echo -e "已完成清理PHP_SESSION......"
    echo -e "正在清理网站日志......"
    rm -rf /www/wwwlogs/*.log
    rm -rf /www/wwwlogs/*.gz
    echo -e "已完成清理网站日志......"
    echo -e "正在清理面板日志......"
    rm -rf ${panel_path}/logs/*.log
    rm -rf ${panel_path}/logs/*.gz
    rm -rf ${panel_path}/logs/request/*
    echo -e "已完成清理面板日志......"
    echo -e "正在清理邮件日志......"
    rm -rf /var/spool/plymouth/*
    rm -rf /var/spool/postfix/*
    rm -rf /var/spool/lpd/*
    echo -e "已完成清理邮件日志......"
    echo -e "正在清理系统使用痕迹..."
    cat /dev/null > /var/log/boot.log
    cat /dev/null > /var/log/btmp
    cat /dev/null > /var/log/cron
    cat /dev/null > /var/log/dmesg
    cat /dev/null > /var/log/firewalld
    cat /dev/null > /var/log/grubby
    cat /dev/null > /var/log/lastlog
    cat /dev/null > /var/log/mail.info
    cat /dev/null > /var/log/maillog
    cat /dev/null > /var/log/messages
    cat /dev/null > /var/log/secure
    cat /dev/null > /var/log/spooler
    cat /dev/null > /var/log/syslog
    cat /dev/null > /var/log/tallylog
    cat /dev/null > /var/log/wpa_supplicant.log
    cat /dev/null > /var/log/wtmp
    cat /dev/null > /var/log/yum.log
    history -c
    echo -e "已完成清理系统使用痕迹..."
    echo -e "垃圾文件清理完毕！您的服务器身轻如燕！"
    back_home
}
#宝塔磁盘挂载
mount_disk(){
	echo -e "注意：本工具会将数据盘挂载到www目录。15秒后跳转到挂载脚本。"
    sleep 15s
	wget -O auto_disk.sh ${down_url}/bt/auto_disk.sh && bash auto_disk.sh
	rm -rf /auto_disk.sh
    rm -rf auto_disk.sh
    back_home
}

#降级版本
degrade_btpanel(){
    if [ ! -d ${panel_path}/BTPanel ];then
    	echo "============================================="
    	echo "错误, 5.x不可以使用此命令升级!"
    	echo "5.9平滑升级到6.0的命令：curl http://download.bt.cn/install/update_to_6.sh|bash"
    	exit 0;
    fi
    wget -T 5 -O panel.zip ${btdown_url}/install/update/LinuxPanel-${version}.zip
    unzip -o panel.zip -d /www/server/ > /dev/null
    rm -f panel.zip
    rm -f ${panel_path}/*.pyc
    rm -f ${panel_path}/class/*.pyc
    sleep 1 && service bt restart > /dev/null 2>&1 &
    echo "====================================="
    echo "你已降级为${version}版";
    back_home
}
#卸载面板
uninstall_btpanel(){
    wget -O bt-uninstall.sh ${down_url}/bt/bt-uninstall.sh && bash bt-uninstall.sh
    rm -rf bt-uninstall.sh
    rm -rf /tmp/*.sh
    rm -rf /tmp/*.sock
}
#修复面板
update_panel(){
    sed -i 's/[0-9\.]\+[ ]\+www.bt.cn//g' /etc/hosts
    chattr -i ${panel_path}/class/panelAuth.py
    chattr -i ${panel_path}/class/panelPlugin.py
    chattr -i /etc/init.d/bt
    rm -f /etc/init.d/bt
    wget -O /etc/init.d/bt ${btdown_url}/install/src/bt6.init -T 10
    chmod +x /etc/init.d/bt
    chattr -i ${panel_path}/data/plugin.json
    rm -f ${panel_path}/data/plugin.json
    wget -O ${panel_path}/data/plugin.json http://bt.cn/api/panel/get_soft_list_test -T 10
    chattr -i ${panel_path}/install/check.sh
    rm -f ${panel_path}/install/check.sh
    wget -O ${panel_path}/install/check.sh ${btdown_url}/install/check.sh -T 10
    chattr -i ${panel_path}/install/public.sh
    rm -f ${panel_path}/install/public.sh
    wget -O ${panel_path}/install/public.sh ${btdown_url}/install/public.sh -T 10
    rm -rf ${panel_path}/plugin/shoki_cdn
    rm -f ${panel_path}/data/home_host.pl
    rm -rf ${panel_path}/adminer
    rm -rf /www/server/adminer
    rm -rf /www/server/phpmyadmin/pma
    rm -f ${panel_path}/*.pyc
    rm -f ${panel_path}/class/*.pyc
    rm -f /dev/shm/session.db
    curl ${btdown_url}/install/update_panel.sh|bash
    back_home
}
#升级查杀库
update_wafrule(){
    wget -O /root/rule.json ${down_url}/bt/Template/rule.json
	PLUGIN_NAME=(free_waf btwaf btwaf_httpd hm_shell_san webshell);
	for name in ${PLUGIN_NAME[@]};
	do
		PLUGIN_PATH=${panel_path}/plugin/${name}/rule.json
		if [ -e "${PLUGIN_PATH}" ];then
		    \cp -rf /root/rule.json  ${PLUGIN_PATH}
		    echo -e "完成升级${name}的查杀库"
		fi
	done
	rm -rf /root/rule.json
	back_home
}
#开启完全离线服务
open_offline(){
    rm -f ${panel_path}/data/home_host.pl
    echo 'True' >${panel_path}/data/not_network.pl
    echo '[ "127.0.0.1" ]' >${panel_path}/config/hosts.json
    sed -i 's/[0-9\.]\+[ ]\+www.bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+download.bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+api.bt.cn//g' /etc/hosts
    echo '192.168.88.127 www.bt.cn' >>/etc/hosts
    echo '192.168.88.127 bt.cn' >>/etc/hosts
    echo '192.168.88.127 download.bt.cn' >>/etc/hosts
    echo '192.168.88.127 api.bt.cn' >>/etc/hosts
    if [[ "${crackurl}" != "0" ]]; then
        sed -i "s/[0-9\.]\+[ ]\+${crackurl}//g" /etc/hosts
        sed -i "s/[0-9\.]\+[ ]\+www.${crackurl}//g" /etc/hosts
        sed -i "s/[0-9\.]\+[ ]\+download.${crackurl}//g" /etc/hosts
        echo "192.168.88.127 ${crackurl}" >>/etc/hosts
        echo "192.168.88.127 www.${crackurl}" >>/etc/hosts
        echo "192.168.88.127 download.${crackurl}" >>/etc/hosts
	fi
    if [[ "${crackurl}" != "hostcli.com" ]]; then
        sed -i "s/[0-9\.]\+[ ]\+v7.hostcli.com//g" /etc/hosts
        echo "192.168.88.127 v7.hostcli.com" >>/etc/hosts
	fi
    back_home
}
#关闭完全离线服务
close_offline(){
    rm -f ${panel_path}/data/home_host.pl
    rm -f ${panel_path}/data/not_network.pl
    wget -O ${panel_path}/config/hosts.json ${down_url}/bt/Template/hosts.json
    sed -i 's/[0-9\.]\+[ ]\+www.bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+download.bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+api.bt.cn//g' /etc/hosts
    if [[ "${crackurl}" != "0" ]]; then
        sed -i "s/[0-9\.]\+[ ]\+${crackurl}//g" /etc/hosts
        sed -i "s/[0-9\.]\+[ ]\+www.${crackurl}//g" /etc/hosts
        sed -i "s/[0-9\.]\+[ ]\+v7.hostcli.com//g" /etc/hosts
        sed -i "s/[0-9\.]\+[ ]\+download.${crackurl}//g" /etc/hosts
	fi
    back_home
}
#返回首页
back_home(){
	read -p "请输入0返回首页:" function
	if [[ "${function}" == "0" ]]; then
	    clear
		main
	else
		clear
		exit 0
	fi
	
}
# 退出脚本
delete(){
    clear
    echo -e "感谢使用宝塔工具箱"
    rm -rf /bt_tools.sh
    rm -rf bt_tools.sh
}

main(){
    clear
	echo -e "
#====================================================#
#  脚本名称:    BTPanel_tools Version ${tools_version}   #
#----------------------------------------------------#
#  授权版本:${auth_version}      面板版本:${btpanel_version}             #
#--------------------[实用工具]----------------------#
#( 1)清理垃圾[清理系统面板网站产生的缓存日志文件慎用]#
#( 2)修复面板[清理破解版修复面板环境并更新到官方最新]#
#( 3)挂载磁盘[官方的一键自动挂载工具]                #
#( 4)卸载面板[本功能会清空所有数据卸载网站环境]      #
#--------------------[降级版本]----------------------#
#( 5)7.7.0                                           #
#-------------------[升级查杀库]---------------------#
#  版本号:Build 210829    ( 6)一键自动智能升级       #
#--------------------[离线宝塔]----------------------#
#(11)开启完全离线服务     (12)关闭完全离线服务       #
#注意:离线功能会完全断开与宝塔的通讯部分功能无法使用 #
#--------------------[其他功能]----------------------#
#(a)更新脚本                      (0)退出脚本    #
#====================================================#
	"
	read -p "请输入需要输入的选项:" function
	case $function in
    1)  cleaning_garbage
    ;;
    2)  update_panel
    ;;
    3)  mount_disk
    ;;
    4)  uninstall_btpanel
    ;;
    5) version=7.7.0
        degrade_btpanel
    ;;
    6) update_wafrule
    ;;
    11) open_offline
    ;;
    12) close_offline
    ;;
    a)  new_version
    ;;
    *)  delete
    ;;
    esac
}
main