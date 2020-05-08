#!/bin/bash
# mz 2020-05-7
 
#consul的地址
CONSUL_ADDRESS="10.10.10.1:8500"
logspwd='/root/script/logs' 
test -d logs || mkdir $logspwd
 
#echo "---------------" >>  ${logspwd}/`date +%Y%m`.log
# 获取当前consul中状态为critical的service_ID
CONSUL_CRITICAL=`curl -s -XGET http://${CONSUL_ADDRESS}/v1/health/state/critical | python -m json.tool | grep ServiceID | awk '{print $2}' |sed 's/"//g' | sed 's/,//g'`
# 获取当前consul中状态为critical的service_IP
CONSUL_IP=`curl -s -XGET http://${CONSUL_ADDRESS}/v1/health/state/critical | python -m json.tool | grep Output | awk '{print $4}' | sed 's/"//g' | sed 's/,//g' | awk -F ':' '{print $1}' | sort -u `
# 获取当前consul中状态为critical的service_PROT
CONSUL_PORT=`curl -s -XGET http://${CONSUL_ADDRESS}/v1/health/state/critical | python -m json.tool | grep Output | awk '{print $4}' | sed 's/"//g' | sed 's/,//g' | awk -F ':' '{print $2}'`
#删除出错的服务
for critical in ${CONSUL_CRITICAL}
do
  echo "${critical} 已删除" >> ${logspwd}/`date +%Y%m`.log
  # 使用consul的API删除对于的serviceID
  curl -XPUT http://${CONSUL_ADDRESS}/v1/agent/service/deregister/${critical}
done
#创建ip地址池,微服务地址
service_ip=("10.10.10.1" "10.10.10.2" "10.10.10.3" "10.10.10.4")
#定义一个函数
consul1 () {
#把获取的service ip进行循环
for  ip in ${CONSUL_IP}; do
  #创建if条件判断是否匹配地址池IP
  if [ ${ip} == ${service_ip[0]} ] || [ ${ip} == ${service_ip[1]} ] || [ ${ip} == ${service_ip[2]} ] || [ ${ip} == ${service_ip[3]} ] ;then
    #获取服务端口，进行端口服务的匹配，触发条件
     for port in  ${CONSUL_PORT}; do  
        #匹配consul服务端口
        if   [ ${port} == 18301 ];then 
             #echo $ip $port
             #sshpass -p 'fg^$%^&*()1$%z@#GX' ssh root@${ip} 'touch /data/1222'
             ssh www@${ip} '/usr/local/php/bin/php /data/wwwroot/service-user/bin/swoft rpc:restart'
             echo "${ip}:service-user was restart by `date +%F-%H-%M`" >> ${logspwd}/`date +%Y%m`.log
        elif [ ${port} == 18302 ];then 
             ssh www@${ip} '/usr/local/php/bin/php /data/wwwroot/service-order/bin/swoft rpc:restart'
             echo "${ip}:service-order was restart by `date +%F-%H-%M`"  >> ${logspwd}/`date +%Y%m`.log
        elif [ ${port} == 18303 ];then 
             ssh www@${ip} '/usr/local/php/bin/php /data/wwwroot/service-terminal/bin/swoft rpc:restart'
             echo "${ip}:service-terminal was restart by `date +%F-%H-%M`" >> ${logspwd}/`date +%Y%m`.log
        elif [ ${port} == 18304 ];then
             ssh www@${ip} '/usr/local/php/bin/php /data/wwwroot/service-pda/bin/swoft rpc:restart'
             echo "${ip}:service-pda was restart  by `date +%F-%H-%M`" >> ${logspwd}/`date +%Y%m`.log
        elif [ ${port} == 18305 ];then 
             ssh www@${ip} '/usr/local/php/bin/php /data/wwwroot/service-pay/bin/swoft rpc:restart'
             echo "${ip}:service-pay was restart by `date +%F-%H-%M`" >> ${logspwd}/`date +%Y%m`.log
        elif [ ${port} == 18306 ];then 
             ssh www@${ip} '/usr/local/php/bin/php /data/wwwroot/message/bin/swoft rpc:restart  -d'
             echo "${ip}:service-message was restart by `date +%F-%H-%M`" >> ${logspwd}/`date +%Y%m`.log
        elif [ ${port} == 18307 ];then 
             ssh www@${ip} '/usr/local/php/bin/php /data/wwwroot/service-notice/bin/swoft rpc:restart'
             echo "${ip}:service-notice was restart by `date +%F-%H-%M`" >> ${logspwd}/`date +%Y%m`.log
        fi
    done
  fi
done
}
consul1
