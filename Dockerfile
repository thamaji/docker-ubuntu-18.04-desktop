FROM ubuntu:18.04

# aptリポジトリ
RUN set -x \
    && sed -e 's/archive.ubuntu.com/jp.archive.ubuntu.com/g' -i /etc/apt/sources.list

# manを有効化
RUN set -x \
    && sed -i /etc/dpkg/dpkg.cfg.d/excludes -e '/\/usr\/share\/man\/*/d' \
    && apt-get update -qq \
    && dpkg -l | grep '^.i' | cut -d' ' -f3 | xargs apt-get install -y -qq --reinstall \
    && apt-get install -y -qq --no-install-recommends \
        man-db \
        manpages-ja \
        manpages-ja-dev \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# CA証明書更新
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        ca-certificates \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# タイムゾーン
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        tzdata \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo Asia/Tokyo > /etc/timezone

# 日本語
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        language-pack-ja \
        language-pack-ja-base \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
ENV LANG=ja_JP.UTF-8

# supervisord
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        supervisor \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && { \
        echo '[supervisord]'; \
        echo 'user=root'; \
    } > /etc/supervisor/conf.d/supervisor.conf

# x11
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        dbus-x11 \
        xvfb \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && install -o root -g root -m 0755 -d /var/run/dbus \
    && { \
        echo '[program:x11]'; \
        echo 'command=/usr/bin/Xvfb :0 -screen 0 1024x768x16'; \
        echo "[program:dbus]"; \
        echo "command=/usr/bin/dbus-daemon --system --nofork --nopidfile"; \
    } > /etc/supervisor/conf.d/x11.conf
ENV DISPLAY=:0

# vnc
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        x11vnc \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && { \
        echo '[program:x11vnc]'; \
        echo 'command=/usr/bin/x11vnc -xkb -forever -shared'; \
    } > /etc/supervisor/conf.d/x11vnc.conf
EXPOSE 5900

# noVNC
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        curl \
        tar \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && mkdir /usr/local/noVNC \
    && curl -fsSL https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xz --strip-components=1 -C /usr/local/noVNC \
    && mkdir /usr/local/noVNC/utils/websockify \
    && curl -fsSL https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar -xz --strip-components=1 -C /usr/local/noVNC/utils/websockify \
    && ln -s /usr/local/noVNC/vnc.html /usr/local/noVNC/index.html \
    && { \
        echo "[program:noVNC]"; \
        echo "command=/usr/local/noVNC/utils/launch.sh --vnc localhost:5900 --listen 8080"; \
    } > /etc/supervisor/conf.d/noVNC.conf
EXPOSE 8080

# デスクトップ
RUN set -x \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
        exo-utils \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        xfce4 \
        xfce4-settings \
        elementary-icon-theme \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && echo "startxfce4" > /etc/skel/.xsession

# IME
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        fcitx \
        fcitx-config-gtk \
        fcitx-frontend-all \
        fcitx-mozc \
        fcitx-ui-classic \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# 最低限のアプリ（for xfce4）
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
        mousepad \
        firefox \
        thunderbird \
        xfce4-terminal \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# sudo
RUN set -x \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends sudo \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ALL \
    && chmod u+s /usr/sbin/useradd \
    && chmod u+s /usr/sbin/groupadd
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
