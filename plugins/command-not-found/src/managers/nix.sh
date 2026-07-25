get_nix_packages(){
   if command -v nix-env &>/dev/null; then
      local cmd="$1"
      local nix_result=$(nix-env -qaP "$cmd" 2>/dev/null | head -n 20)
      [ -n "$nix_result" ] && echo "  ${fg[green]}✔ Found in Nix${reset_color}" && sources+=("Nix::$nix_result") && found=true
   fi
}