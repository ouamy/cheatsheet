#!/bin/bash

# === Create stream mount point if it doesn't exist ===
mkdir -p stream

# === Prepare the VNC startup script ===
VNC_STARTUP="$HOME/.vnc/xstartup"
cat > "$VNC_STARTUP" <<EOF
#!/bin/sh
xrdb $HOME/.Xresources
startxfce4 &

EOF
chmod +x "$VNC_STARTUP"

# === Start TightVNC server ===

tmux new-session -d -s xtightvncserver "vncserver :2"

# === Start noVNC server ===
tmux new-session -d -s novnc "cd \$HOME/projects/noVNC && python3 -m websockify --web . 6080 localhost:5902"

# === Start Icecast server ===
tmux new-session -d -s icecast "sudo systemctl start icecast2 && sleep infinity"

# === Start Audio Streaming ===
tmux new-session -d -s audio_stream 'ffmpeg -f pulse -i RDPSink.monitor -ac 2 -ar 44100 -f mp3 icecast://source:hackme@localhost:8000/stream'

# === Start cloudflared and log output to temp files ===
ICECAST_LOG="/tmp/cloudflared_icecast.log"
NOVNC_LOG="/tmp/cloudflared_novnc.log"

tmux new-session -d -s deployed_icecast "cloudflared tunnel --url http://localhost:8000 > $ICECAST_LOG 2>&1"
tmux new-session -d -s deployed_novnc "cloudflared tunnel --url http://localhost:6080 > $NOVNC_LOG 2>&1"

echo "You are now live."
echo "Waiting for URLs: "
sleep 5

# === Extract Cloudflare URLs from log files ===
get_cloudflared_url_from_log() {
    LOG_FILE="$1"
    NAME="$2"
    for i in {1..15}; do
        if [[ -f "$LOG_FILE" ]]; then
            URL=$(grep -Eo 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' "$LOG_FILE" | tail -n 1)
            if [[ -n "$URL" ]]; then
                if [[ "$NAME" == "deployed_novnc" ]]; then
                    URL="${URL}/vnc.html"
                fi
                echo "$URL"
                return
            fi
        fi
        sleep 1
    done
    echo "$NAME URL: Not found (timed out)"
}

# === Get URLs and clean up logs ===
get_cloudflared_url_from_log "$ICECAST_LOG" "deployed_icecast"
get_cloudflared_url_from_log "$NOVNC_LOG" "deployed_novnc"

# === Clean up temporary log files ===
rm -f "$ICECAST_LOG" "$NOVNC_LOG"
vncserver -kill :2 > tmp.txt 2>&1 && vncserver :2 >> tmp.txt 2>&1
rm -f tmp.txt
