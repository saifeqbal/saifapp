#!/usr/bin/env bash

# ==============================================================================
# Terminal Break & Wellness App
# ==============================================================================

# Script path and persistence file
DATA_DIR="$HOME/.break_app"
DATA_FILE="$DATA_DIR/stats.txt"

mkdir -p "$DATA_DIR"
if [[ ! -f "$DATA_FILE" ]]; then
    echo "STREAK=0" > "$DATA_FILE"
    echo "WATER=0" >> "$DATA_FILE"
    echo "TOTAL_BREAKS=0" >> "$DATA_FILE"
    echo "LAST_DATE=$(date +%Y-%m-%d)" >> "$DATA_FILE"
fi

# Load Stats
source "$DATA_FILE"

# Check date reset for daily stats
TODAY=$(date +%Y-%m-%d)
if [[ "$LAST_DATE" != "$TODAY" ]]; then
    WATER=0
    LAST_DATE="$TODAY"
    echo "STREAK=$STREAK" > "$DATA_FILE"
    echo "WATER=0" >> "$DATA_FILE"
    echo "TOTAL_BREAKS=$TOTAL_BREAKS" >> "$DATA_FILE"
    echo "LAST_DATE=$TODAY" >> "$DATA_FILE"
fi

# Default Colors
COLOR_MAIN="\033[1;36m"   # Cyan
COLOR_ACCENT="\033[1;33m" # Yellow
COLOR_SUCCESS="\033[1;32m"# Green
COLOR_RESET="\033[0m"
COLOR_BG="\033[44m"
COLOR_DIM="\033[2m"

# Audio / Notification helper
notify_user() {
    local title="$1"
    local message="$2"
    
    # Terminal Bell
    echo -e "\a"
    
    # Desktop Notification (Linux)
    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message" -u critical 2>/dev/null
    fi
    
    # macOS Notification
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
    fi
}

save_stats() {
    echo "STREAK=$STREAK" > "$DATA_FILE"
    echo "WATER=$WATER" >> "$DATA_FILE"
    echo "TOTAL_BREAKS=$TOTAL_BREAKS" >> "$DATA_FILE"
    echo "LAST_DATE=$TODAY" >> "$DATA_FILE"
}

# Clear Terminal Screen
clear_screen() {
    clear
}

# Header Banner
show_header() {
    clear_screen
    echo -e "${COLOR_MAIN}=====================================================${COLOR_RESET}"
    echo -e "${COLOR_MAIN}   P A U S E  //  Terminal Wellness Companion ${COLOR_RESET}"
    echo -e "${COLOR_MAIN}=====================================================${COLOR_RESET}"
    echo -e " Breaks Completed: ${COLOR_ACCENT}${TOTAL_BREAKS}${COLOR_RESET} | Water: ${COLOR_ACCENT}${WATER} glasses${COLOR_RESET} | Streak: ${COLOR_ACCENT}${STREAK} days${COLOR_RESET}"
    echo -e "-----------------------------------------------------"
}

# Printable big timer display
draw_timer() {
    local title="$1"
    local total_sec="$2"
    local current_sec="$3"
    
    local remaining=$((total_sec - current_sec))
    local mins=$((remaining / 60))
    local secs=$((remaining % 60))
    
    # Progress bar calculations
    local bar_width=30
    local filled=$(( (current_sec * bar_width) / total_sec ))
    local empty=$(( bar_width - filled ))
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done

    clear_screen
    echo -e "${COLOR_MAIN}=====================================================${COLOR_RESET}"
    echo -e "   MODE: ${COLOR_ACCENT}${title}${COLOR_RESET}"
    echo -e "${COLOR_MAIN}=====================================================${COLOR_RESET}\n"
    
    # Big visual printout
    printf "                  %02d : %02d\n\n" "$mins" "$secs"
    echo -e "   Progress: [${COLOR_SUCCESS}${bar}${COLOR_RESET}] $(( (current_sec * 100) / total_sec ))%"
    echo -e "\n${COLOR_DIM}   Press Ctrl+C to cancel session at any time.${COLOR_RESET}\n"
}

# Run countdown timer
run_countdown() {
    local label="$1"
    local duration_minutes="$2"
    local is_break="$3"
    local total_seconds=$((duration_minutes * 60))
    
    trap 'echo -e "\n\n${COLOR_ACCENT}Session interrupted.${COLOR_RESET}"; sleep 1; return' INT

    for ((sec=0; sec<=total_seconds; sec++)); do
        draw_timer "$label" "$total_seconds" "$sec"
        sleep 1
    done

    trap - INT
    
    notify_user "Time's up!" "$label session has completed."
    
    if [[ "$is_break" == "true" ]]; then
        TOTAL_BREAKS=$((TOTAL_BREAKS + 1))
        STREAK=$((STREAK + 1))
        save_stats
    fi

    echo -e "${COLOR_SUCCESS}✔ Session finished successfully!${COLOR_RESET}"
    echo -e "Press Enter to return to main menu..."
    read -r
}

# 20-20-20 Eye Strain Tool
eye_relief() {
    clear_screen
    echo -e "${COLOR_MAIN}=== 20-20-20 Eye Strain Relief ===${COLOR_RESET}"
    echo -e "Every 20 minutes, look at an object 20 feet away for 20 seconds.\n"
    echo -e "Find a far object (out a window, or across the room)..."
    echo -e "Press Enter when ready..."
    read -r
    
    for ((i=20; i>0; i--)); do
        clear_screen
        echo -e "${COLOR_MAIN}=== Look at something 20+ feet away ===${COLOR_RESET}\n"
        echo -e "             Target: 👁️  遠 "
        echo -e "\n               [ ${COLOR_ACCENT}${i}${COLOR_RESET} sec ]\n"
        echo -e "${COLOR_DIM}Blink naturally and relax your eye muscles...${COLOR_RESET}"
        sleep 1
    done
    
    TOTAL_BREAKS=$((TOTAL_BREAKS + 1))
    save_stats
    notify_user "Eye Break Done" "Great job giving your eyes a rest!"
    echo -e "\n${COLOR_SUCCESS}Done! Your eyes thank you.${COLOR_RESET}"
    echo -e "Press Enter to return..."
    read -r
}

# Box Breathing Exercise
box_breathing() {
    clear_screen
    echo -e "${COLOR_MAIN}=== Box Breathing Exercise (4-4-4-4) ===${COLOR_RESET}"
    echo -e "How many cycles would you like to perform? (Default: 4): "
    read -r cycles
    cycles=${cycles:-4}

    trap 'echo -e "\n${COLOR_ACCENT}Breathing session stopped.${COLOR_RESET}"; sleep 1; return' INT

    for ((c=1; c<=cycles; c++)); do
        # Inhale
        for s in {1..4}; do
            clear_screen
            echo -e "${COLOR_MAIN}Box Breathing - Cycle $c / $cycles${COLOR_RESET}\n"
            echo -e "  [ Inhale ] 🫁  ( $s / 4 )"
            echo -e "  ▲\n  │"
            sleep 1
        done
        # Hold
        for s in {1..4}; do
            clear_screen
            echo -e "${COLOR_MAIN}Box Breathing - Cycle $c / $cycles${COLOR_RESET}\n"
            echo -e "  [ Hold ] ⏸️  ( $s / 4 )"
            echo -e "  ───►"
            sleep 1
        done
        # Exhale
        for s in {1..4}; do
            clear_screen
            echo -e "${COLOR_MAIN}Box Breathing - Cycle $c / $cycles${COLOR_RESET}\n"
            echo -e "  [ Exhale ] 💨  ( $s / 4 )"
            echo -e "  │\n  ▼"
            sleep 1
        done
        # Hold
        for s in {1..4}; do
            clear_screen
            echo -e "${COLOR_MAIN}Box Breathing - Cycle $c / $cycles${COLOR_RESET}\n"
            echo -e "  [ Hold ] ⏸️  ( $s / 4 )"
            echo -e "  ◄───"
            sleep 1
        done
    done

    trap - INT
    TOTAL_BREAKS=$((TOTAL_BREAKS + 1))
    save_stats
    notify_user "Breathing Done" "Feeling calm and centered."
    echo -e "\n${COLOR_SUCCESS}Breathing session complete!${COLOR_RESET}"
    echo -e "Press Enter to return..."
    read -r
}

# Desk Stretches
stretch_routine() {
    clear_screen
    echo -e "${COLOR_MAIN}=== Guided Desk Stretches ===${COLOR_RESET}\n"
    
    stretches=(
        "Neck Roll: Slowly roll head in circles. (30 sec)"
        "Wrist Extension: Pull fingers back gently with arm straight. (30 sec)"
        "Shoulder Shrugs: Roll shoulders backwards and up to ears. (30 sec)"
        "Seated Torso Twist: Twist gently side to side in chair. (30 sec)"
    )

    for stretch in "${stretches[@]}"; do
        for ((i=15; i>0; i--)); do
            clear_screen
            echo -e "${COLOR_MAIN}=== Quick Desk Stretches ===${COLOR_RESET}\n"
            echo -e "${COLOR_ACCENT}STRETCH:${COLOR_RESET} $stretch"
            echo -e "\nTime remaining: ${COLOR_SUCCESS}${i}${COLOR_RESET}s"
            sleep 1
        done
    done

    TOTAL_BREAKS=$((TOTAL_BREAKS + 1))
    save_stats
    notify_user "Stretches Complete" "Your body appreciates the movement!"
    echo -e "\n${COLOR_SUCCESS}Great job moving your body!${COLOR_RESET}"
    echo -e "Press Enter to return..."
    read -r
}

# Hydration Tracker
log_water() {
    WATER=$((WATER + 1))
    save_stats
    echo -e "${COLOR_SUCCESS}+1 Glass of water logged! Total today: $WATER glasses 💧${COLOR_RESET}"
    sleep 1.5
}

# Color Theme Switcher
select_theme() {
    clear_screen
    echo -e "Select Terminal Theme:"
    echo -e "1) Cyberpunk Cyan (Default)"
    echo -e "2) Matrix Green"
    echo -e "3) Sunset Magenta"
    echo -e "4) Amber Gold"
    read -p "Choice [1-4]: " tchoice

    case $tchoice in
        1) COLOR_MAIN="\033[1;36m"; COLOR_ACCENT="\033[1;33m"; COLOR_SUCCESS="\033[1;32m" ;;
        2) COLOR_MAIN="\033[1;32m"; COLOR_ACCENT="\033[1;36m"; COLOR_SUCCESS="\033[1;33m" ;;
        3) COLOR_MAIN="\033[1;35m"; COLOR_ACCENT="\033[1;31m"; COLOR_SUCCESS="\033[1;33m" ;;
        4) COLOR_MAIN="\033[1;33m"; COLOR_ACCENT="\033[1;31m"; COLOR_SUCCESS="\033[1;32m" ;;
    esac
}

# Main Application Menu Loop
main_menu() {
    while true; do
        show_header
        echo -e "  ${COLOR_ACCENT}1)${COLOR_RESET} 🎯 Focus / Pomodoro Work (25 min)"
        echo -e "  ${COLOR_ACCENT}2)${COLOR_RESET} ☕ Short Break (5 min)"
        echo -e "  ${COLOR_ACCENT}3)${COLOR_RESET} 🌴 Long Break (15 min)"
        echo -e "  ${COLOR_ACCENT}4)${COLOR_RESET} ⏱️  Custom Duration Timer"
        echo -e "  ---------------------------------------------------"
        echo -e "  ${COLOR_ACCENT}5)${COLOR_RESET} 👁️  20-20-20 Eye Strain Relief"
        echo -e "  ${COLOR_ACCENT}6)${COLOR_RESET} 🫁 Box Breathing Guide"
        echo -e "  ${COLOR_ACCENT}7)${COLOR_RESET} 🧘 Desk Stretch Routine"
        echo -e "  ${COLOR_ACCENT}8)${COLOR_RESET} 💧 Log Glass of Water ($WATER glasses today)"
        echo -e "  ---------------------------------------------------"
        echo -e "  ${COLOR_ACCENT}9)${COLOR_RESET} 🎨 Change Theme"
        echo -e "  ${COLOR_ACCENT}0)${COLOR_RESET} ❌ Exit"
        echo -e "====================================================="
        read -p "Select an option [0-9]: " choice

        case $choice in
            1) run_countdown "Focus Session" 25 "false" ;;
            2) run_countdown "Short Break" 5 "true" ;;
            3) run_countdown "Long Break" 15 "true" ;;
            4) 
                read -p "Enter break/focus title: " ctitle
                read -p "Enter duration in minutes: " cdur
                run_countdown "${ctitle:-Custom Timer}" "${cdur:-5}" "true"
                ;;
            5) eye_relief ;;
            6) box_breathing ;;
            7) stretch_routine ;;
            8) log_water ;;
            9) select_theme ;;
            0) 
                clear_screen
                echo -e "${COLOR_MAIN}Take care & stay refreshed! Goodbye!${COLOR_RESET}"
                exit 0
                ;;
            *)
                echo -e "${COLOR_ACCENT}Invalid choice!${COLOR_RESET}"
                sleep 1
                ;;
        esac
    done
}

# Launch App
main_menu
