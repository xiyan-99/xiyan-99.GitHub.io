#!name= 盒子兑换通知 by 夕颜
#!desc= 微信主题兑换通知 by 夕颜-loon插件
#!author= 夕颜
#!homepage= https://cert.xiyan.store
#!icon= https://img.xiyan.pro/i/u/2025/04/14/IMG_7887.png
#!system = iOS
#!system_version = 16.0
#!loon_version = 3.2.1(372)
#!tag = 主题,盒子,通知

[script]
http-request ^https:\/\/theme\.25mao\.com\/index\/redeem script-path=https://raw.githubusercontent.com/xiyan-99/xiyan-99.GitHub.io/main/Loon/xythemeboxtz.js, requires-body=true, timeout=20, tag=兑换主题通知,


[mitm]
hostname = theme.25mao.com
