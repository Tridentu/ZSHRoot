get_apt_packages(){
   if command -v apt &>/dev/null; then
      local cmd="$1"
      local apt_result=$(apt-cache search "^${cmd}$" 2>/dev/null || apt-cache search "$cmd" 2>/dev/null)
      [ -n "$apt_result" ] && echo "  ${fg[green]}✔ Found in APT${reset_color}" && sources+=("APT::$apt_result") && found=true
   fi
}
