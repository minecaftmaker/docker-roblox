FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    XDG_RUNTIME_DIR=/run/user/1000 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    GALLIUM_DRIVER=llvmpipe \
    MESA_GL_VERSION_OVERRIDE=4.6 \
    MESA_GLES_VERSION_OVERRIDE=3.2 \
    ROBLOX_WIDTH=1280 \
    ROBLOX_HEIGHT=720

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    dbus-x11 \
    flatpak \
    fonts-dejavu \
    gosu \
    mesa-utils \
    libegl1-mesa \
    libgles2-mesa \
    libgl1-mesa-dri \
    libglx-mesa0 \
    novnc \
    python3 \
    supervisor \
    x11-utils \
    x11-xserver-utils \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    xorg \
    xserver-xorg-video-dummy \
    xauth \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash roblox \
    && mkdir -p /run/user/1000 /home/roblox/.var/app /opt/roblox-docker \
    && chown -R roblox:roblox /run/user/1000 /home/roblox /opt/roblox-docker \
    && chmod 700 /run/user/1000

COPY xorg.conf /etc/X11/xorg.conf
COPY scripts/ /opt/roblox-docker/
COPY supervisord.conf /etc/supervisor/conf.d/roblox.conf

RUN chmod +x /opt/roblox-docker/*.sh

EXPOSE 6080 5900

VOLUME ["/home/roblox/.var/app/org.vinegarhq.Sober"]

ENTRYPOINT ["/opt/roblox-docker/entrypoint.sh"]
