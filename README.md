# NetInstallAlpine
A script to Net Install Alpine

## 系统要求
  
- 支持Grub引导的Linux系统
  
- 需提前安装Curl和请安装OpenSSH
  
## 使用方法

```
sh <(curl -k 'https://cdn.jsdelivr.net/gh/52fancy/NetInstallAlpine/alpine.sh')
```

### 特别注意

为了避免成功安装alpine无法ssh登录服务器，请执行以下操作

- 查看磁盘名称（例如：sda）

 ```
 fdisk -l
 ```
 
- 挂载并保存SSH私钥
 
 ```
 mount /dev/sda3 /mnt
 mkdir -p /mnt/root/.ssh
 chmod 700 /mnt/root/.ssh
 cp /root/.ssh/authorized_keys /mnt/root/.ssh/authorized_keys
 chmod 600 /mnt/root/.ssh/authorized_keys
 umount /dev/sda3
 ```
 
- 重启后使用私钥链接即可

 ```
 reboot
 ```
