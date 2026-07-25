get_dnf_packages(){
   if command -v dnf &>/dev/null; then
      local cmd="$1"
      local dnf_result=$(dnf search "$cmd" 2>/dev/null | grep -E '^[[:alnum:]-]+\.' | head -n 20)
      [ -n "$dnf_result" ] && echo "  ${fg[green]}✔ Found in DNF${reset_color}" && sources+=("DNF::$dnf_result") && found=true
   fi
}