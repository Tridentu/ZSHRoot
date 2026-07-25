get_flatpak_packages(){
   if command -v flatpak &>/dev/null; then
      local cmd="$1"
      local flat_result=$(flatpak search "$cmd" 2>/dev/null | head -n 20)
      if [[ -n "$flat_result" ]] && ! echo "$flat_result" | grep -qi "no matches\|not found\|error"; then
         echo "  ${fg[green]}✔ Found in Flatpak${reset_color}" && sources+=("Flatpak::$flat_result") && found=true
      fi
   fi
}
