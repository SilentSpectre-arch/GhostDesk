
#!/usr/bin/env bash

# =========================================
# GhostDesk 2.0 - Ultimate Desktop Prank
# KDE Plasma / XFCE / GNOME
# Safe, local and temporary simulation
# =========================================

set -u

VERSION="2.0"
RUNNING=1
WALLPAPER_CHANGED=0
DESKTOP="UNKNOWN"
OLD_WALLPAPER=""
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ghostdesk.XXXXXX")"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

trap cleanup EXIT
trap 'exit 0' INT TERM

banner() {
    clear
    echo -e "${RED}"
    cat <<'EOF'
   ____ _               _   ____
  / ___| |__   ___  ___| |_|  _ \
 | |  _|  _ \ / _ \/ __| __| | | |
 | |_| | | | | (_) \__ \ |_| |_| |
  \____|_| |_|\___/|___/\__|____/
EOF
    echo -e "${RESET}"
    echo -e "${CYAN}     GHOSTDESK ULTIMATE v${VERSION}${RESET}"
    echo -e "${YELLOW}       DESKTOP PRANK SIMULATOR${RESET}"
    echo
}

detect_desktop() {
    local session="${XDG_CURRENT_DESKTOP:-} ${DESKTOP_SESSION:-}"

    if [[ "$session" =~ KDE|Plasma ]] ||
       [[ -n "${KDE_FULL_SESSION:-}" ]]; then
        DESKTOP="KDE"
    elif [[ "$session" =~ XFCE ]]; then
        DESKTOP="XFCE"
    elif [[ "$session" =~ GNOME ]]; then
        DESKTOP="GNOME"
    fi

    echo -e "${GREEN}[+] Desktop: $DESKTOP${RESET}"
}

notify_user() {
    local title="$1"
    local message="$2"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$message" 2>/dev/null || true
    else
        echo "[NOTIFICATION] $title: $message"
    fi
}

terminal_run() {
    local command="$1"

    if [[ "$DESKTOP" == "KDE" ]] &&
       command -v konsole >/dev/null 2>&1; then
        konsole --new-tab -e bash -c "$command" \
            >/dev/null 2>&1 &
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal --disable-server \
            --command="bash -c '$command'" >/dev/null 2>&1 &
    elif command -v x-terminal-emulator >/dev/null 2>&1; then
        x-terminal-emulator -e bash -c "$command" \
            >/dev/null 2>&1 &
    else
        echo "No supported terminal found."
    fi
}

matrix_effect() {
    local count=0
    clear
    echo -e "${GREEN}"

    while (( count < 35 )) && (( RUNNING )); do
        printf '%04d  %s\n' "$count" \
            "$(tr -dc '01ABCDEF' </dev/urandom | head -c 35)"
        ((count+=1))
        sleep 0.08
    done

    echo -e "${RESET}"
    echo
    echo "[SIMULATION] Matrix connection established."
    read -r -p "Press Enter to continue..."
}

fake_terminal() {
    local script="$TEMP_DIR/fake.sh"

    cat > "$script" <<'EOF'
#!/usr/bin/env bash
clear
echo "======================================"
echo "        GHOSTDESK ACCESS CONSOLE"
echo "======================================"
echo

messages=(
"Initializing fake hacking engine..."
"Connecting to imaginary satellite..."
"Scanning coffee machine..."
"Decrypting pizza database..."
"Searching for lost motivation..."
"SIMULATION COMPLETE!"
)

for msg in "${messages[@]}"; do
    echo "[*] $msg"
    sleep 1
done

echo
echo "[SIMULATION] No files were modified."
echo "Relax. It's just a prank! 😂"
read -r -p "Press Enter to close..."
EOF

    chmod +x "$script"
    terminal_run "$script"
}

notification_storm() {
    local count=5

    read -r -p "Number of notifications (1-20): " count
    [[ "$count" =~ ^[0-9]+$ ]] || return
    (( count >= 1 && count <= 20 )) || return

    local -a messages=(
        "Your cat has root privileges."
        "404: Motivation not found."
        "Coffee.exe needs more RAM."
        "Alien activity detected."
        "Your keyboard is judging you."
        "The Matrix wants a coffee break."
        "Your PC says hello!"
    )

    for ((i=1; i<=count && RUNNING; i++)); do
        local msg="${messages[RANDOM % ${#messages[@]}]}"
        notify_user "👻 GHOSTDESK" "$msg"
        sleep 1
    done
}

simulation_alerts() {
    local -a alerts=(
        "SIMULATION: Fake firewall activity."
        "SIMULATION: Alien signal received."
        "SIMULATION: Suspicious meme detected."
        "SIMULATION: Matrix synchronization."
        "SIMULATION: Coffee levels critical."
    )

    for alert in "${alerts[@]}"; do
        (( RUNNING )) || break
        notify_user "⚠ SIMULATION ALERT" "$alert"
        sleep 2
    done
}

fake_blue_screen() {
    local message="SIMULATION - FAKE SYSTEM CRASH"

    if command -v zenity >/dev/null 2>&1; then
        zenity --info \
            --title="GhostDesk Simulation" \
            --width=500 \
            --text="$message\n\nYour system is perfectly fine. 😂" \
            2>/dev/null || true
    elif command -v kdialog >/dev/null 2>&1; then
        kdialog --title "GhostDesk Simulation" \
            --msgbox "$message\n\nYour system is perfectly fine. 😂" \
            2>/dev/null || true
    else
        echo "$message"
        read -r -p "Press Enter..."
    fi
}

system_monitor() {
    while (( RUNNING )); do
        clear
        echo -e "${CYAN}=== GHOSTDESK SYSTEM MONITOR ===${RESET}"
        echo
        echo "SIMULATION: Monitor is informational."
        echo

        if command -v free >/dev/null 2>&1; then
            free -h
        fi

        echo
        if [[ -r /proc/loadavg ]]; then
            echo "CPU load averages:"
            cat /proc/loadavg
        fi

        echo
        echo "Press Ctrl+C in this terminal to stop."
        sleep 2
    done
}

save_wallpaper() {
    case "$DESKTOP" in
        XFCE)
            if command -v xfconf-query >/dev/null 2>&1; then
                xfconf-query -c xfce4-desktop -l 2>/dev/null |
                grep '/last-image$' > "$TEMP_DIR/xfce-props"

                while IFS= read -r prop; do
                    [[ -n "$prop" ]] || continue
                    value="$(xfconf-query -c xfce4-desktop -p "$prop" 2>/dev/null || true)"
                    printf '%s\t%s\n' "$prop" "$value" \
                        >> "$TEMP_DIR/xfce-backup"
                done < "$TEMP_DIR/xfce-props"
            fi
            ;;
        GNOME)
            if command -v gsettings >/dev/null 2>&1; then
                gsettings get org.gnome.desktop.background picture-uri \
                    > "$TEMP_DIR/gnome-light"
                gsettings get org.gnome.desktop.background picture-uri-dark \
                    > "$TEMP_DIR/gnome-dark"
            fi
            ;;
        KDE)
            local config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
            if [[ -f "$config" ]]; then
                cp -p "$config" "$TEMP_DIR/kde-backup"
                grep -m1 -E '^Image=file://' "$config" |
                    cut -d= -f2- > "$TEMP_DIR/kde-image" || true
            fi
            ;;
    esac
}

change_wallpaper() {
    local image="$1"
    [[ -f "$image" ]] || {
        echo "Image not found."
        return 1
    }

    save_wallpaper

    case "$DESKTOP" in
        XFCE)
            while IFS= read -r prop; do
                [[ -n "$prop" ]] || continue
                xfconf-query -c xfce4-desktop -p "$prop" \
                    -s "$image" 2>/dev/null || true
            done < "$TEMP_DIR/xfce-props"
            WALLPAPER_CHANGED=1
            ;;
        GNOME)
            local uri
            uri="$(python3 -c \
                'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' \
                "$image")"
            gsettings set org.gnome.desktop.background picture-uri "$uri"
            gsettings set org.gnome.desktop.background picture-uri-dark "$uri"
            WALLPAPER_CHANGED=1
            ;;
        KDE)
            if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
                plasma-apply-wallpaperimage "$image" \
                    >/dev/null 2>&1 &&
                    WALLPAPER_CHANGED=1
            else
                echo "Install the Plasma wallpaper utility first."
            fi
            ;;
        *)
            echo "Unsupported desktop environment."
            ;;
    esac
}

restore_wallpaper() {
    [[ "$WALLPAPER_CHANGED" == "1" ]] || return 0

    echo -e "${YELLOW}[*] Restoring wallpaper...${RESET}"

    case "$DESKTOP" in
        XFCE)
            if [[ -f "$TEMP_DIR/xfce-backup" ]]; then
                while IFS=$'\t' read -r prop value; do
                    [[ -n "$prop" ]] || continue
                    xfconf-query -c xfce4-desktop -p "$prop" \
                        -s "$value" 2>/dev/null || true
                done < "$TEMP_DIR/xfce-backup"
            fi
            ;;
        GNOME)
            if [[ -f "$TEMP_DIR/gnome-light" ]]; then
                gsettings set org.gnome.desktop.background picture-uri \
                    "$(cat "$TEMP_DIR/gnome-light")" || true
                gsettings set org.gnome.desktop.background picture-uri-dark \
                    "$(cat "$TEMP_DIR/gnome-dark")" || true
            fi
            ;;
        KDE)
            if [[ -s "$TEMP_DIR/kde-image" ]] &&
               command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
                plasma-apply-wallpaperimage \
                    "$(cat "$TEMP_DIR/kde-image")" \
                    >/dev/null 2>&1 || true
            else
                echo "KDE original wallpaper could not be identified."
            fi
            ;;
    esac

    WALLPAPER_CHANGED=0
}

cleanup() {
    RUNNING=0
    restore_wallpaper
    rm -rf -- "$TEMP_DIR"
    echo
    echo -e "${GREEN}[+] GhostDesk safely stopped.${RESET}"
}

menu() {
    while (( RUNNING )); do
        echo
        echo -e "${CYAN}========== MAIN MENU ==========${RESET}"
        echo "1) Matrix Terminal"
        echo "2) Fake Hacker Terminal"
        echo "3) Notification Storm"
        echo "4) Simulation Alerts"
        echo "5) Fake Blue Screen"
        echo "6) System Monitor"
        echo "7) Change Wallpaper Temporarily"
        echo "8) Restore Wallpaper"
        echo "9) Run All Effects"
        echo "0) Exit"
        echo

        read -r -p "Select an option: " choice

        case "$choice" in
            1) matrix_effect ;;
            2) fake_terminal ;;
            3) notification_storm ;;
            4) simulation_alerts ;;
            5) fake_blue_screen ;;
            6) system_monitor ;;
            7)
                read -r -p "Wallpaper image path: " image
                change_wallpaper "$image"
                ;;
            8) restore_wallpaper ;;
            9)
                matrix_effect
                fake_terminal
                notification_storm
                simulation_alerts
                fake_blue_screen
                ;;
            0) exit 0 ;;
            *) echo "Invalid option." ;;
        esac
    done
}

main() {
    banner
    detect_desktop
    save_wallpaper

    echo
    echo "GhostDesk is ready!"
    echo "All fake alerts are marked as SIMULATION."
    read -r -p "Press Enter to start..."

    menu
}

main
