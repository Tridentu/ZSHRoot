#================================================
# *  Package Display Function
# 
# Formats package list and displays it using fzf for user selection
#================================================

display_packages() {
   local cmd="$1"
   local package_list=""
   
   echo "${fg[blue]}📦 Package list...${reset_color}"

   for src in "${sources[@]}"; do
      local pm="${src%%::*}"
      local data="${src#*::}"
      while IFS= read -r line; do
         # Only process non-empty lines and remove any trailing whitespace
         if [[ -n "${line// }" ]]; then
         package_list+="${fg[green]}$pm${reset_color} → ${fg[yellow]}$line${reset_color}\n"
         fi
      done <<< "$data"
   done

   local line_count
   line_count=$(echo -e "$package_list" | wc -l)
   package_list=$(echo -e "$package_list" | sed '/^[[:space:]]*$/d')
   chosen=$(echo -e "$package_list" | fzf --ansi \
                                          --exact \
                                          --border \
                                          --prompt="📦 Select package to install: " \
                                          --height=~$line_count% \
                                          --min-height=12+ \
                                          --footer="Results for '$cmd'" \
                                          --cycle \
                                          --wrap \
                                          --highlight-line \
                                          --info-command='echo "[$FZF_POS/$FZF_MATCH_COUNT]"')

   [[ -z "$chosen" ]] && { echo "${fg[red]}❌ No package selected.${reset_color}"; return 0; }
   
   return 0
}

