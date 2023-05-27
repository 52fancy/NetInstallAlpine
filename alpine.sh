#!sh

# Check if user is root
if [ "$(id -u)" != "0" ]; then
    echo "Error: You must be root to run this script"
    exit
fi

clear
echo "+------------------------------------------------------------------------+"
echo "|                             Alpine                                     |"
echo "+------------------------------------------------------------------------+"
echo "|                  A script to Net Install  Alpine                       |"
echo "+------------------------------------------------------------------------+"
echo "|              Welcome to  https://github.com/52Fancy                    |"
echo "+------------------------------------------------------------------------+"

read -p "请选择分支版本[默认latest-stable]：" branch
if [ -z ${branch} ]; then
    branch=latest-stable
fi
echo "分支：${branch}"

read -p "请选择apk源[默认cdn]：" mirror
if [ -z ${mirror} ]; then
    mirror=http://dl-cdn.alpinelinux.org/alpine
fi
echo "apk源：${mirror}"

if [ "$(uname -m)" = "x86_64" ]; then
    arch="x86_64"
elif [ "$(uname -m)" = "i386" ] || [ "$(uname -m)" = "i686" ] || [ "$(uname -m)" = "x86" ]; then
    arch="x86"
elif [ "$(uname -m)" = "armv8" ] || [ "$(uname -m)" = "armv8l" ] || [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then
    arch="aarch64"
else
    arch="$(uname -m)"
fi
echo "系统平台：${arch}"

read -p "是否开启VIRTUAL[y/n]：" flavor
if [ "${flavor}" = "y" ] || [ "${flavor}" = "Y" ] || [ "${flavor}" = "yes" ]; then
    flavor=virt
    echo "开启VIRTUAL"
else
    flavor=lts
    echo "关闭VIRTUAL"
fi

console=tty0
echo yes | ssh-keygen -t ed25519 -N '' -f KEY
if [ $? -ne 0 ]; then
    echo "请安装OpenSSH"
    exit
fi
ssh_key="$(curl -k -F "file=@KEY.pub" https://file.io | sed 's/.*"link":"//;s/".*//')"
if [ $? -ne 0 ]; then
    echo "请安装Curl"
    exit
fi

if ! curl -k -f -# ${mirror}/${branch}/releases/${arch}/netboot/vmlinuz-${flavor} -o /boot/vmlinuz-netboot; then
    echo "Failed to download file!"
    exit 
fi

if ! curl -k -f -# ${mirror}/${branch}/releases/${arch}/netboot/initramfs-${flavor} -o /boot/initramfs-netboot; then
    echo "Failed to download file!"
    exit 
fi

cat > /etc/grub.d/40_custom << EOF
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
menuentry 'Alpine' {
    linux /boot/vmlinuz-netboot alpine_repo="${mirror}/${branch}/main" modloop="${mirror}/${branch}/releases/${arch}/netboot/modloop-${flavor}" modules="loop,squashfs" initrd="initramfs-netboot" console="${console}" ssh_key="${ssh_key}"
    initrd /boot/initramfs-netboot
}
EOF

if grub-install --version >/dev/null 2>&1; then
    grub-mkconfig -o /boot/grub/grub.cfg
    grub-reboot Alpine
elif grub2-install --version >/dev/null 2>&1; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
    grub2-reboot Alpine
else
    echo "不支持当前系统"
    exit
fi

cat KEY
echo "请自行下载或者保存私钥，然后重启服务器继续安装"
echo "$(curl -k -F "file=@KEY" https://file.io | sed 's/.*"link":"//;s/".*//')"

read -p "重启服务器[y/n]：" reboot
if [ "${reboot}" = "y" ] || [ "${reboot}" = "yes" ] || [ "${reboot}" = "Y" ]; then
    reboot
fi
