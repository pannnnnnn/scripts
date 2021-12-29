#退格
stty erase ^H

#变量
echo "key?(y/n)"
read key
echo "Shanghai(s)/Tokyo(t)?"
read timezone
echo "Global(g)/CN(c)?"
read region
echo "docker?(y/n)"
read dockerinstall

#公钥
if [ $key = y ]
    then
        mkdir ~/.ssh
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAqlbyBD6Tst8e+Fja7WcyEzipn9WfKfLM9IGlAlpDvTKugzmVoZqr9CCruUwR8h7S5XJQXePov85Be8MJaBbQKVS28F4Vm+Rzp1NliOiIAXyQufvapxOnrEZL7EaAidYwIrWenKHM2y2pmZ0r1T5Zba2QC674pQP8zgz+MTyCWypxiP4x0mz8mAPJexCXuvT6bJUG10QTRQZj+VVHAjNZuk1ZGtVLIPvXNDgypP75GNUOLwKwMuvcn8VSmdBHureI4gefDkDznqrtASUobmtXO0GbnaD2EBUDE8LxhxuXPvb8w1mN+OWFT38e7QqyHFeXGS1GCC8+XI3HNd6Myc6Z1w== rsa 2048-042620" >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        chmod 700 ~/.ssh
fi

#swap
free -h
df -h | grep G
echo "no(n)/yes(y)/swapoff&yes(sy)/azure(az)?"
read swap
if [ $swap != n ]
    then
        echo "swap size?(G)"
        read swapsize
fi
case $swap in
    y)
        swapsize64=`expr ${swapsize} \* 16`
        dd if=/dev/zero of=/swapfile bs=64M count=${swapsize64}
        chmod -R 0600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo "/swapfile swap swap defaults 0 0" >>  /etc/fstab
    ;;
    sy)
        oldswap=$(grep swap /etc/fstab | grep 0 | cut -d ' ' -f 1)
        swapoff ${oldswap}
        rm -rf ${oldswap}
        sed -i '/swap/d' /etc/fstab
        swapsize64=`expr ${swapsize} \* 16`
        dd if=/dev/zero of=/swapfile bs=64M count=${swapsize64}
        chmod -R 0600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo "/swapfile swap swap defaults 0 0" >>  /etc/fstab
    ;;
    az)
        azswapsize=`expr ${swapsize} \* 1024`
        sed -i 's/ResourceDisk.Format=n/ResourceDisk.Format=y/' /etc/waagent.conf
        sed -i 's/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/' /etc/waagent.conf
        sed -i "s/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=${azswapsize}/" /etc/waagent.conf
        systemctl restart walinuxagent
    ;;
esac

#时区
if [ $timezone = s ]
    then
        timedatectl set-timezone Asia/Shanghai
    else
        timedatectl set-timezone Asia/Tokyo
fi

#DNS
echo "DNS?(y/n)"
read dns
if [ $dns = y ]
    then
        apt update
        apt install e2fsprogs -y
        chattr -i /etc/resolv.conf
        rm -f /etc/resolv.conf
        if [ $region = g ]
            then
                echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > /etc/resolv.conf
            else
                echo -e "nameserver 119.29.29.29\nnameserver 223.5.5.5" > /etc/resolv.conf
        fi
        chattr +i /etc/resolv.conf
fi

#update
if [ $region = c ]
    then
        echo "mirror? u20(1)/手动(2)"
        read mirror
        case $mirror in
            1)
                echo -e "deb https://mirrors.ustc.edu.cn/ubuntu/ focal main restricted universe multiverse\ndeb https://mirrors.ustc.edu.cn/ubuntu/ focal-security main restricted universe multiverse\ndeb https://mirrors.ustc.edu.cn/ubuntu/ focal-updates main restricted universe multiverse\ndeb https://mirrors.ustc.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" > /etc/apt/sources.list
            ;;
            2)
                echo "waiting"
                read waiting
            ;;
        esac
fi
apt update
apt upgrade -y
apt autoremove -y --purge

#vnstat
apt install vnstat -y

#docker
if [ $dockerinstall = y ]
    then
        apt install curl -y
        curl -fsSL https://get.docker.com -o get-docker.sh
        if [ $region = c ]
            then
                sed -i 's#download.docker.com#mirrors.ustc.edu.cn/docker-ce#' get-docker.sh
        fi
        sh get-docker.sh
        systemctl enable docker
        rm -f get-docker.sh
fi

#bbr
wget --no-check-certificate https://cdn.jsdelivr.net/gh/teddysun/across@master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
rm -f bbr.sh
rm -f install_bbr.log
