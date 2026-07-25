#^ currently not working because pip deprecated the search command 
#^ I just wrote it in case they make it work again 
get_pip_packages(){
   if command -v pip &>/dev/null; then
      local cmd="$1"
      local pip_results
      pip_results=$(pip search "$cmd" 2>/dev/null | head -n 20)
      [ -n "$pip_results" ] && echo "  ${fg[green]}✔ Found in Pip${reset_color}" && sources+=("Pip::$pip_result") && found=true
   fi
}