# Roblox-Docker

A small, web-accessible Linux desktop container for running Roblox on Linux through **Sober** (the Linux Roblox runtime), exposed through **noVNC**.

> **Important:** This project does not spoof hardware, patch Roblox, disable Hyperion, or bypass Roblox security checks. It uses the Linux/Android Roblox runtime instead of the Windows client/Wine path. Current Sober documentation lists x86-64 + SSE4.1 and OpenGL ES 3.0 as minimum requirements. (see https://vinegarhq.org/Sober/Installation.html)

## What it does

- Debian-based lightweight desktop
- XFCE desktop inside the container
- Xorg with the dummy display driver
- Mesa software rendering (`llvmpipe`) so the container does not require `/dev/dri` GPU passthrough
- Sober installed automatically from Flathub
- Roblox's client downloaded by Sober's normal automatic installation flow
- noVNC web desktop on port `6080`
- persistent Sober data in `./config/sober`
- Docker Compose deployment
- Codespaces-friendly port configuration

## Reality check on the "no GPU" goal

The design does **not** require a physical GPU passed into the container. It attempts software OpenGL through Mesa/llvmpipe. That is different from removing the graphics requirement entirely: Roblox still needs an OpenGL ES 3.0-capable renderer, and software rendering can be very slow. Sober's published requirements explicitly include OpenGL ES 3.0. (see https://vinegarhq.org/Sober/Installation.html)

Likewise, there is no KVM/VM emulation in this design. The container is just a Linux userspace environment, so Docker does not need KVM.

## Quick start

```bash
git clone https://github.com/minecaftmaker/docker-roblox.git
cd docker-roblox
docker compose up -d --build
```

Open:

- http://localhost:6080/

The first start installs Sober and launches it. Sober normally downloads the Roblox Android client automatically during first-run. (see https://vinegarhq.org/Sober/Installation.html)

## Codespaces

Open the repository in GitHub Codespaces, then run:

```bash
docker compose up -d --build
```

Forward port **6080**. In Codespaces, open the forwarded port in the browser.

The included `.devcontainer/devcontainer.json` labels 6080 as the main application port.

## Resource target

The image is designed to be useful on a small machine and Compose defaults the container to:

- 2 CPU cores
- 2 GiB RAM
- 512 MiB shared memory

The repository itself is intentionally small. Runtime Roblox/Sober assets are stored in `./config/sober` and can grow over time; Docker cannot enforce a portable 32 GB per-container filesystem quota across all storage drivers. Use a host filesystem quota if you need a hard 32 GB cap.

## Compose

```yaml
services:
  roblox:
    build: .
    container_name: roblox-docker
    ports:
      - "6080:6080"
    volumes:
      - ./config/sober:/home/roblox/.var/app/org.vinegarhq.Sober
    environment:
      DISPLAY: ":0"
      ROBLOX_WIDTH: "1280"
      ROBLOX_HEIGHT: "720"
      LIBGL_ALWAYS_SOFTWARE: "1"
      GALLIUM_DRIVER: "llvmpipe"
    mem_limit: 2g
    cpus: 2.0
    shm_size: 512m
    restart: unless-stopped
```

## Useful commands

```bash
# Logs
docker compose logs -f

# Open a shell
docker compose exec roblox bash

# Stop
docker compose down

# Rebuild
docker compose build --no-cache
```

Inside the container:

```bash
/opt/roblox-docker/status.sh
/opt/roblox-docker/launch-sober.sh
```

## Troubleshooting

### Black screen / Sober closes

Check the container logs first:

```bash
docker compose logs --tail=250 roblox
```

Then test software GL inside the container:

```bash
docker compose exec roblox glxinfo -B
```

You should see Mesa/llvmpipe rather than a physical GPU.

### Sober says there is no supported graphics device

This means the current Sober build did not accept the software renderer exposed by the container. A software-rendered Docker desktop is therefore **not guaranteed** by Sober. Current Sober reports show failures when a supported graphics device cannot be found. (see https://github.com/vinegarhq/sober/issues/1931)

In that case, the recommended fallback is a real Linux host GPU passed through to the container, not a hardware-spoofing shim.

### Roblox itself works on Linux, but not through Wine

That is expected. The contemporary Linux Roblox ecosystem uses Sober or other native Android-runtime approaches because the Windows client is blocked under Wine by Hyperion. (see https://github.com/SpeeNotPee/Pigment and https://github.com/WaviestBalloon/ApplejuiceCLI)

## Architecture

```text
Browser
  │
  ▼
noVNC :6080
  │ WebSocket
  ▼
X11 :0  ── XFCE
  │
  ├── x11vnc
  │
  └── Sober (Flatpak)
          │
          └── Roblox Android x86-64 client

Mesa llvmpipe
     │
     └── software OpenGL/OpenGL ES
```

## Relationship to linuxserver/docker-steam

The idea is inspired by the web-accessible desktop pattern used by [linuxserver/docker-steam](https://github.com/linuxserver/docker-steam), which exposes a GUI application through a browser and supports Docker Compose deployment. Their project also documents that GPU access can be passed to a container when needed. (see https://github.com/linuxserver/docker-steam)

This repository intentionally differs by using Sober and software rendering as the default path instead of trying to make the Windows Roblox client believe it is running on a physical gaming PC.

## Legal / policy note

Roblox is a third-party service. This repository is not affiliated with Roblox or VinegarHQ/Sober. Do not redistribute Roblox's proprietary client files. Let Sober obtain its client through its supported installation mechanism.
