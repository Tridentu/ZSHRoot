#================================================
#*        Package Selection Parsing Function
# Extracts package manager and package name from user's fzf selection
#================================================

parse_package_selection() {
   local chosen="$1"
   local manager package clean_chosen
   
   # Extract manager (first word before the arrow)
   manager=$(echo "$chosen" | grep -o '^[A-Za-z]*' | head -1)

   # Remove ANSI color codes and manager prefix
   clean_chosen=$(echo "$chosen" | sed -E 's/^[A-Za-z]+ → //' | sed -E 's/\x1B\[[0-9;]*[mGK]//g')

   # Extract package name based on package manager format
   case "$manager" in
      APT)
         # APT: "package - description" → take first word
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      DNF)
         # DNF: "package.arch description" → take first word and remove .arch
         package=$(echo "$clean_chosen" | awk '{print $1}' | sed 's/\..*$//')
         ;;
      Pacman)
         # Pacman: "repo/package version description" → take repo/package part
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      YAY)
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      PARU)
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      AURA)
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      Zypper)
         # Zypper: complex table format - take the package name column
         package=$(echo "$clean_chosen" | awk '{print $2}')
         ;;
      Homebrew)
         # Homebrew: usually just package names
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      Flatpak)
         # Flatpak: "application ID version branch description" → take application ID
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      Snap)
         # Snap: "package version developer notes" → take first word
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      Nix)
         # Nix: "attribute.name package-name-version" → take attribute.name
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      Pip)
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
      *)
         # Fallback: take first word
         package=$(echo "$clean_chosen" | awk '{print $1}')
         ;;
   esac

   # Final cleanup
   package=$(echo "$package" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

   # Remove any trailing characters that might cause issues
   package=$(echo "$package" | sed 's/[:\/].*$//')

   if [[ -z "$manager" || -z "$package" ]]; then
      echo "${fg[red]}❌ Failed to parse package selection.${reset_color}"
      echo "${fg[red]}Debug: manager='$manager', package='$package'${reset_color}"
      return 1
   fi
   
   # Set global variables for use by install function
   selected_manager="$manager"
   selected_package="$package"
   
   return 0
}

