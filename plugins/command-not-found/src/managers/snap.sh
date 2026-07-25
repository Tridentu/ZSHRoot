get_snap_packages(){
   if command -v snap &>/dev/null; then
      local cmd="$1"
      local snap_result=$(snap find "$cmd" 2>/dev/null | head -n 20)
      [ -n "$snap_result" ] && echo "  ${fg[green]}✔ Found in Snap${reset_color}" && sources+=("Snap::$snap_result") && found=true
   fi
}
