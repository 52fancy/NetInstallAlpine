# NetInstallAlpine
A script to Net Install Alpine

## 系统要求
- 支持Grub引导的Linux系统
- 需提前安装Curl和OpenSSH

## 使用方法
```
sh <(curl -k 'https://cdn.jsdelivr.net/gh/52fancy/NetInstallAlpine/alpine.sh')
```

## 特别注意 OS＜3.16.0
为了避免安装之后无法ssh登录服务器，请执行以下操作
- 查看磁盘名称（例如：sda）
```
fdisk -l
```

- 挂载并允许root登录
```
mount /dev/sda3 /mnt
sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /mnt/etc/ssh/sshd_config
umount /dev/sda3
```

- 重启即可
```
reboot
```
