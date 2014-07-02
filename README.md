sidekiq的web界面
======

### 介绍
 * 来源：https://github.com/mperham/sidekiq
 * 增加了用户管理及参数配置功能

### 用法:
 	rake -T # 列出所有任务
    rake user:add # 添加用户
    rake user:del # 删除用户
    rake user:list # 列出所有用户
    rake web:start # 启动
    rake web:stop # 停止
    rake web:setup # 设置参数
	rake web:info # 查看当前配置
	rake web:nginx # nginx示例配置
	rake logs # 查看日志



