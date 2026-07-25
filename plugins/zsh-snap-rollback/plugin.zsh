# ============================================================
# zsh-snap-rollback — Oh My Zsh plugin for openSUSE Tumbleweed
# Safe guided snapper rollback with confirmation and reboot warning
# Version: 1.2 — 2026-04-12
# ============================================================

# Override any previous definition (alias or function)
unalias snap-rollback 2>/dev/null
unfunction snap-rollback 2>/dev/null

# Guided rollback : no argument → shows list + instruction
#                   with argument → confirms and executes
# Usage : snap-rollback          → list + instruction
#         snap-rollback <id>     → rollback to snapshot <id>
#         snap-rollback <id> --dry-run
function snap-rollback {
    local RED="\033[31m" GREEN="\033[32m" YELLOW="\033[33m"
    local CYAN="\033[36m" BOLD="\033[1m" RESET="\033[0m"
    local dry_run=0
    local snap_id=""

    # Detect whether sudo is required for snapper
    local -a SNAPPER
    if snapper list-configs &>/dev/null 2>&1; then
        SNAPPER=(snapper)
    else
        SNAPPER=(sudo snapper)
    fi

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --dry-run) dry_run=1 ;;
            [0-9]*) snap_id="$arg" ;;
            *)
                echo -e "${RED}Unknown option: $arg${RESET}"
                echo -e "Usage: snap-rollback <id> [--dry-run]"
                return 1
                ;;
        esac
    done

    # No argument: display list and instruction
    if [[ -z "$snap_id" ]]; then
        if command -v snap-list &>/dev/null; then
            snap-list -a
        else
            "${SNAPPER[@]}" list
        fi
        echo ""
        echo -e "${BOLD}Choose a number from the list above and type:${RESET}"
        echo -e "  ${CYAN}snap-rollback <number>${RESET}"
        echo -e "  ${CYAN}snap-rollback <number> --dry-run${RESET}  (simulate without action)"
        return 0
    fi

    # Validate ID is a number
    if ! [[ "$snap_id" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: \"$snap_id\" is not a valid number.${RESET}"
        echo -e "Usage: snap-rollback <number>  (e.g. snap-rollback 5)"
        return 1
    fi

    # Fetch snapshot info via robust CSV parsing (locale-independent)
    local snap_info
    snap_info=$("${SNAPPER[@]}" --csvout --separator '|' --no-headers list \
        --columns number,type,date,description,userdata 2>/dev/null \
        | awk -F'|' -v id="$snap_id" '$1==id')

    if [[ -z "$snap_info" ]]; then
        echo -e "${RED}Error: snapshot #${snap_id} not found.${RESET}"
        echo -e "Type ${CYAN}snap-rollback${RESET} without argument to see the list."
        return 1
    fi

    # Extract fields — $1=number $2=type $3=date $4=description $5=userdata
    local snap_type snap_date snap_desc snap_userdata
    snap_type=$(echo "$snap_info"     | awk -F'|' '{print $2}')
    snap_date=$(echo "$snap_info"     | awk -F'|' '{print $3}')
    snap_desc=$(echo "$snap_info"     | awk -F'|' '{print $4}')
    snap_userdata=$(echo "$snap_info" | awk -F'|' '{print $5}')

    local importance_label importance_color
    if echo "$snap_userdata" | grep -q "important=yes"; then
        importance_label="important"
        importance_color="$YELLOW"
    else
        importance_label="standard"
        importance_color="$GREEN"
    fi

    local desc_display="${snap_desc:-${YELLOW}(none)${RESET}}"

    # Display target snapshot summary
    echo -e "${BOLD}Target snapshot:${RESET}"
    echo -e "  Number      : ${CYAN}#${snap_id}${RESET}"
    echo -e "  Date        : ${snap_date:-${YELLOW}(none)${RESET}}"
    echo -e "  Type        : ${snap_type}"
    echo -e "  Importance  : ${importance_color}${importance_label}${RESET}"
    echo -e "  Description : ${BOLD}${desc_display}${RESET}"

    if [[ "$dry_run" -eq 1 ]]; then
        echo ""
        echo -e "${CYAN}[Dry-run]${RESET} No action taken."
        echo -e "Command that would run: ${BOLD}${SNAPPER[*]} rollback ${snap_id}${RESET}"
        echo -e "${YELLOW}⚠ A reboot would be required for the rollback to take effect.${RESET}"
        return 0
    fi

    # Critical warning
    echo ""
    echo -e "${RED}${BOLD}⚠ WARNING${RESET} — This action is irreversible."
    echo -e "  The system will be restored to the state of snapshot ${CYAN}#${snap_id}${RESET}."
    echo -e "  ${YELLOW}A reboot is required for the rollback to take effect.${RESET}"
    echo ""
    printf "Confirm rollback to #${snap_id}? [y/N] : "
    read -r confirm

    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        echo -e "${YELLOW}Cancelled.${RESET}"
        return 0
    fi

    # Execute rollback
    echo ""
    echo -e "${CYAN}Rolling back to #${snap_id}...${RESET}"
    "${SNAPPER[@]}" rollback "$snap_id"
    local exit_code=$?

    echo ""
    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}${BOLD}✗ Rollback failed (snapper exit code: ${exit_code}).${RESET}"
        echo -e "  Check the output above for details."
        return 1
    fi

    echo -e "${GREEN}${BOLD}✓ Rollback complete.${RESET}"
    echo -e "${YELLOW}${BOLD}⚠ Reboot the system to apply the rollback:${RESET}"
    echo -e "  ${BOLD}sudo reboot${RESET}"
}
