#!/bin/bash

# === Create stream mount point if it doesn't exist ===
mkdir -p stream

# === Prepare the VNC startup script ===
VNC_STARTUP="$HOME/.vnc/xstartup"
cat > "$VNC_STARTUP" <<EOF
#!/bin/sh
xrdb \$HOME/.Xresources
startxfce4 &
EOF
chmod +x "$VNC_STARTUP"

# === Start TightVNC server ===
tmux new-session -d -s xtightvncserver "vncserver :1"

# === Start noVNC server ===
tmux new-session -d -s novnc "cd \$HOME/projects/noVNC && python3 -m websockify --web . 6080 localhost:5901"

# === Start Icecast server ===
tmux new-session -d -s icecast "sudo systemctl start icecast2 && sleep infinity"

# === Start Audio Streaming ===
tmux new-session -d -s audio_stream 'ffmpeg -f pulse -i RDPSink.monitor -ac 2 -ar 44100 -f mp3 icecast://username:password@localhost:8000/stream'

# === Expose Icecast via Cloudflared ===
tmux new-session -d -s deployed_icecast "cloudflared tunnel --url http://localhost:8000"

# === Expose noVNC via Cloudflared ===
tmux new-session -d -s deployed_novnc "cloudflared tunnel --url http://localhost:6080"

echo "URLs: "

# === Wait and extract Cloudflare URLs from tmux output ===
sleep 5

get_cloudflared_url() {
    SESSION_NAME="$1"
    for i in {1..10}; do
        URL=$(tmux capture-pane -p -t "$SESSION_NAME" | grep -Eo 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' | tail -n 1)
        if [[ -n "$URL" ]]; then
            echo "$SESSION_NAME $URL"
            return
        fi
        sleep 1
    done
    echo "$SESSION_NAME URL: Not found (timed out)"
}

get_cloudflared_url deployed_icecast
get_cloudflared_url deployed_novnc

echo "You are now live."

