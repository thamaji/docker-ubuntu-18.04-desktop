#!/bin/bash
set -e -u -x

# docker run -u で指定されたユーザーとグループをつくる
if [ ! $(getent group $(id -g)) ]; then
    groupadd \
        --gid $(id -g) \
        user
fi

HOME=/root
if [ ! $(getent passwd $(id -u)) ]; then
    HOME=/home/user
    useradd \
        --uid $(id -u) \
        --gid $(id -g) \
        --home-dir ${HOME} \
        --create-home \
        --shell /bin/bash \
        user
fi
export HOME

sudo chmod u-s /usr/sbin/useradd
sudo chmod u-s /usr/sbin/groupadd

# なにかと起動
sudo /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

# 起動待ち
sleep 3

# ↓でたしかに設定ファイルは変わるんだけど、反映されない。。
# xfconf-query -c xsettings -p /Net/ThemeName -s Xfce-flat
# xfconf-query -c xsettings -p /Net/IconThemeName -s elementary-mono-dark

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx
/usr/bin/fcitx-autostart

/usr/bin/startxfce4