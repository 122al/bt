installpanel_version=7.7.0 #版本
installpanel_admin_path_pl=False #取消入口限制
installpanel_port=18888 #面板端口
installpanel_user=123456 #自定义用户名
installpanel_pass=123456 #自定义密码

apt update && apt upgrade -y

#正常安装官方最新版
wget -O install.sh http://download.bt.cn/install/install_panel.sh && bash install.sh

#切换成自己想要的版本
#curl -sL http://download.bt.cn/install/update6.sh|sed "s/version=.*/version=${installpanel_version}/g"|bash
wget -T 5 -O panel.zip http://download.bt.cn/install/update/LinuxPanel-${installpanel_version}.zip
    unzip -o panel.zip -d /www/server/ > /dev/null
    rm -f panel.zip
    rm -f ${panel_path}/*.pyc
    rm -f ${panel_path}/class/*.pyc
    sleep 1 && service bt restart > /dev/null 2>&1 &

#取消入口限制
if [[ "${installpanel_admin_path_pl}" == "False" ]];then
bt 11
fi

#改端口
if [[ "${installpanel_port}" ]];then
bt 8 <<EOF
$installpanel_port
EOF
fi

#改用户名
if [[ "${installpanel_user}" ]];then
bt 6 <<EOF
$installpanel_user
EOF
fi

#改密码
if [[ "${installpanel_pass}" ]];then
bt 5 <<EOF
$installpanel_pass
EOF
fi

if [ ! -f /www/server/panel/data/userInfo.json ]; then
	echo "{\"uid\":1000,\"username\":\"admin\",\"serverid\":1}" > /www/server/panel/data/userInfo.json
	sed -i "s|bind_user == 'True'|bind_user == 'Close'|" /www/server/panel/BTPanel/static/js/index.js
	rm -rf /www/server/panel/data/bind.pl
fi
echo "已去除宝塔面板强制绑定账号."

bt default
