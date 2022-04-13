#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ $(whoami) != "root" ];then
	echo "请使用root权限执行命令！"
	exit 1;
fi
if [ ! -d /www/server/panel ] || [ ! -f /etc/init.d/bt ];then
	echo "未安装宝塔面板"
	exit 1
fi 

#解锁所有付费插件为永不过期
sed -i "s/\"endtime\": -1/\"endtime\": 999999999999/g" /www/server/panel/data/plugin.json
echo "解锁所有付费插件为永不过期."

#显示永久专业版或企业版标识
sed -i "s/\"pro\": -1/\"pro\": 0/g" /www/server/panel/data/plugin.json
#sed -i "s/\"ltd\": -1/\"ltd\": 0/g" /www/server/panel/data/plugin.json
echo "已显示永久专业版标识."

Layout_file="/www/server/panel/BTPanel/templates/default/layout.html";
JS_file="/www/server/panel/BTPanel/static/bt.js";
if [ `grep -c "<script src=\"/static/bt.js\"></script>" $Layout_file` -eq '0' ];then
	sed -i '/{% block scripts %} {% endblock %}/a <script src="/static/bt.js"></script>' $Layout_file;
fi;
wget -q https://raw.githubusercontent.com/122al/bt/main/bt.js -O $JS_file;
echo "已去除各种计算题与延时等待."

sed -i "/htaccess = self.sitePath+'\/.htaccess'/, /public.ExecShell('chown -R www:www ' + htaccess)/d" /www/server/panel/class/panelSite.py
sed -i "/index = self.sitePath+'\/index.html'/, /public.ExecShell('chown -R www:www ' + index)/d" /www/server/panel/class/panelSite.py
sed -i "/doc404 = self.sitePath+'\/404.html'/, /public.ExecShell('chown -R www:www ' + doc404)/d" /www/server/panel/class/panelSite.py
echo "已去除创建网站自动创建的垃圾文件."

sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/class/panelSite.py
if [ -f /www/server/panel/vhost/nginx/0.default.conf ]; then
	sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/vhost/nginx/0.default.conf
fi
echo "已关闭未绑定域名提示页面."

sed -i "s/return render_template('autherr.html')/return abort(404)/" /www/server/panel/BTPanel/__init__.py
echo "已关闭安全入口登录提示页面."

sed -i "/p = threading.Thread(target=check_files_panel)/, /p.start()/d" /www/server/panel/task.py
sed -i "/p = threading.Thread(target=check_panel_msg)/, /p.start()/d" /www/server/panel/task.py
echo "已去除消息推送与文件校验."

if [ ! -f /www/server/panel/data/not_recommend.pl ]; then
	echo "True" > /www/server/panel/data/not_recommend.pl
fi
if [ ! -f /www/server/panel/data/not_workorder.pl ]; then
	echo "True" > /www/server/panel/data/not_workorder.pl
fi
echo "已关闭活动推荐与在线客服."

/etc/init.d/bt restart

echo -e "=================================================================="
echo -e "\033[32m宝塔面板优化脚本执行完毕\033[0m"
echo -e "=================================================================="
echo  "适用宝塔面板版本：7.7"
echo  "如需还原之前的样子，请在面板首页点击“修复”"
echo -e "=================================================================="
echo  "禁止解锁插件后自动修复为免费版"
echo  "文件路径：www/server/panel/data/repair.json"
echo  "查找字符串："id": 16，将这段修复权限的代码删除"
echo -e "=================================================================="
echo  "禁止宝塔面板检测升级，防止失效"
echo  "文件路径：www/server/panel/data/plugin.json"
echo  '查找字符串：name": "coll_admin"，将这段里的update_mgs删除或者改为null'
echo -e "=================================================================="
echo  "修改文件后执行以下命令限制宝塔自动修改"
echo  "chattr +i /www/server/panel/data/plugin.json"
echo  "chattr +i /www/server/panel/data/repair.json"
