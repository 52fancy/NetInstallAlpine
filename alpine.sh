#!/bin/sh

# Check if user is root
if [ "$(id -u)" != "0" ]; then
    echo "Error: You must be root to run this script"
    exit 1
fi

clear
echo "+------------------------------------------------------------------------+"
echo "|                             Alpine                                     |"
echo "+------------------------------------------------------------------------+"
echo "|                  A script to Net Install Alpine                        |"
echo "+------------------------------------------------------------------------+"
echo "|              Welcome to https://github.com/52Fancy                     |"
echo "+------------------------------------------------------------------------+"

read -p "请选择分支版本[默认latest-stable]：" branch
branch=${branch:-latest-stable}
echo "分支：${branch}"

read -p "请选择密钥上传接口[默认file.io]：" loadKey
loadKey=${loadKey:-https://file.io}
echo "密钥上传接口：${loadKey}"

read -p "请选择apk源[默认cdn]：" mirror
mirror=${mirror:-https://dl-cdn.alpinelinux.org/alpine}
echo "apk源：${mirror}"

case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    i386|i686|x86) arch="x86" ;;
    armv8|armv8l|aarch64|arm64) arch="aarch64" ;;
    *) arch="$(uname -m)" ;;
esac
echo "系统平台：${arch}"

read -p "是否开启VIRTUAL[y/n]：" flavor
case "${flavor}" in
    y|Y|yes) flavor="virt"; echo "开启VIRTUAL" ;;
    *) flavor="lts"; echo "关闭VIRTUAL" ;;
esac

console=tty0
yes | ssh-keygen -t ed25519 -N '' -f KEY
if [ $? -ne 0 ]; then
    echo "请安装OpenSSH"
    exit 1
fi
ssh_key="$(curl -k -F "file=@KEY.pub" ${loadKey} | sed 's/.*"link":"//;s/".*//')"
if [ $? -ne 0 ]; then
    echo "请安装Curl"
    exit 1
fi

version="$(curl -k ${mirror}/${branch}/releases/${arch}/latest-releases.yaml | grep version | sed -n 1p | sed 's/version: //g' | xargs echo -n)"
if ! curl -k -f -# ${mirror}/${branch}/releases/${arch}/netboot/vmlinuz-${flavor} -o /boot/vmlinuz-${version}-netboot; then
    echo "Failed to download file!"
    exit 1
fi

if ! curl -k -f -# ${mirror}/${branch}/releases/${arch}/netboot/initramfs-${flavor} -o /boot/initramfs-${version}-netboot; then
    echo "Failed to download file!"
    exit 1
fi

cat > /etc/grub.d/40_custom << EOF
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
menuentry 'Alpine' {
    linux /boot/vmlinuz-${version}-netboot alpine_repo="${mirror}/${branch}/main" modloop="${mirror}/${branch}/releases/${arch}/netboot/modloop-${flavor}" modules="loop,squashfs" initrd="initramfs-${version}-netboot" console="${console}" ssh_key="${ssh_key}"
    initrd /boot/initramfs-${version}-netboot
}
EOF

if command -v grub-install >/dev/null 2>&1; then
    grub-mkconfig -o /boot/grub/grub.cfg
    grub-reboot Alpine
elif command -v grub2-install >/dev/null 2>&1; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
    grub2-reboot Alpine
else
    echo "不支持当前系统"
    exit 1
fi

cat KEY
echo "请自行下载或者保存私钥，然后重启服务器继续安装"
echo "$(curl -k -F "file=@KEY" ${loadKey} | sed 's/.*"link":"//;s/".*//')"

read -p "重启服务器[y/n]：" reboot
if [ "${reboot}" = "y" ] || [ "${reboot}" = "yes" ] || [ "${reboot}" = "Y" ]; then
    reboot
fi
