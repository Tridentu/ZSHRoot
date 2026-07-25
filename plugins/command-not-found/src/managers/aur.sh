get_yay_packages(){
   if command -v yay &>/dev/null; then
      local cmd="$1"
      local yay_result=$(yay -Ss --aur "$cmd" 2>/dev/null | grep -E '^[a-z0-9/]+ ' | head -n 20)
      [ -n "$yay_result" ] && echo "  ${fg[green]}✔ Found in AUR with yay${reset_color}" && sources+=("YAY::$yay_result") && found=true
   fi
}

get_paru_packages(){
   if command -v paru &>/dev/null; then
      local cmd="$1"
      local paru_result=$(paru -a "$cmd" 2>/dev/null | grep -E '^[a-z0-9/]+ ' | head -n 20)
      [ -n "$paru_result" ] && echo "  ${fg[green]}✔ Found in AUR with paru${reset_color}" && sources+=("PARU::$yay_result") && found=true
   fi
}

get_aura_packages(){
   if command -v aura &>/dev/null; then
      local cmd="$1"
      local aura_result=$(aura -A "$cmd" 2>/dev/null | grep -E '^[a-z0-9/]+ ' | head -n 20)
      [ -n "$aura_result" ] && echo "  ${fg[green]}✔ Found in AUR with aura${reset_color}" && sources+=("AURA::$yay_result") && found=true
   fi
}