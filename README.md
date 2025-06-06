# CheatSheet

## Tools

- **XAMPP** – Local web server (Apache, MySQL, PHP)
- **VSCode** – Code editor
- **Epson** – Printer drivers/software
- **Node.js** – JavaScript runtime
- **Windscribe** – VPN client
- **Composer** – PHP dependency manager
- **TightVNC** – Remote desktop server
- **Steam** – Gaming client
- **Firefox** – Web browser
- **uTorrent** – Torrent client
- **DS4Windows** – DualShock controller support
- **Caddy** – Fast and secure web server
- **Cloudflared** – Secure tunnel to localhost
- **Python** – General purpose programming
- **noVNC** – VNC in browser

---

## Remote Desktop via Browser

### Architecture

- **TightVNC**: VNC server (port `5900`)
- **Websockify**: Bridges VNC over WebSocket (e.g. `6080`)
- **noVNC**: HTML5 VNC client

### Commands

```bash
# Launch Websockify + noVNC from current directory
python -m websockify --web . 6080 localhost:5900

# Optional: HTTP server (if needed for serving files)
python -m http.server 8080
```

### Access URLs

- Local: [http://localhost/vnc.html](http://localhost:6080/vnc.html)
- Exposed via Cloudflared :
```bash
cloudflared tunnel --url http://localhost:6080
```

---

## VM Notes

### SSH Access

```bash
ssh -i pooptop.key opc@89.168.51.129
```

- **Public IP:** `89.168.51.129`
- **Username:** `opc`

### Tmux

```bash
# Start new session
tmux new-session -s minebot

# Detach from session
Ctrl + b, then d

# List sessions
tmux ls

# Reattach
tmux attach-session -t minebot

# Kill session
tmux kill-session -t minebot
```

---

## File Transfer (SCP)

```bash
# From local machine to VM
./send_to_vm.sh directory/or/file
```

---

## Streaming

```bash
# Start live session
./stream.sh

# Windows path (WSL)
cd /mnt/c/Users/user0/Desktop
```
