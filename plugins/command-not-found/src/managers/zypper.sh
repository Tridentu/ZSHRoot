get_zypper_packages(){
   if command -v zypper &>/dev/null; then
      local cmd="$1"
      local zyp_result=$(zypper search "$cmd" 2>/dev/null | grep -E '^[[:space:]]*[il-] |^[[:space:]]*[|] ')
      [ -n "$zyp_result" ] && echo "  ${fg[green]}✔ Found in Zypper${reset_color}" && sources+=("Zypper::$zyp_result") && found=true
   fi

}