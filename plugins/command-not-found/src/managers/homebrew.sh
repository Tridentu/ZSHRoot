get_homebrew_packages(){
   if command -v brew &>/dev/null; then
      local cmd="$1"
      local brew_result=$(brew search "$cmd" 2>/dev/null | head -n 20)
      [ -n "$brew_result" ] && echo "  ${fg[green]}✔ Found in Homebrew${reset_color}" && sources+=("Homebrew::$brew_result") && found=true
   fi
}