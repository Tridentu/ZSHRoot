get_pacman_packages(){
   if command -v pacman &>/dev/null; then
      local cmd="$1"
      local pac_result=$(pacman -Ss "$cmd" 2>/dev/null | grep -E '^[a-z0-9/]+ ' | head -n 20)
      [ -n "$pac_result" ] && echo "  ${fg[green]}✔ Found in Pacman${reset_color}" && sources+=("Pacman::$pac_result") && found=true
   fi
}