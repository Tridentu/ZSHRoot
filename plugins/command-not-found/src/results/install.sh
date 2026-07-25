#================================================
# *       Package Installation Function
# Executes the appropriate install command based on package manager
#================================================

install_package() {
   local manager="$1"
   local package="$2"
   
   echo "${fg[cyan]}➡ Installing '${fg[yellow]}$package${fg[cyan]}' via ${fg[green]}$manager${reset_color}..."

   case "$manager" in
      APT) if command -v nala &>/dev/null; then
            sudo nala install "$package"
         else
            sudo apt install "$package"
         fi ;; 

      DNF) sudo dnf install "$package" ;;

      Pacman) sudo pacman -S "$package" ;;

      YAY) sudo yay -S "$package" ;;
      
      PARU) sudo paru -S "$package" ;;
      
      AURA) sudo aura -S "$package" ;;

      Zypper) sudo zypper install "$package" ;;

      Homebrew) brew install "$package" ;;

      Flatpak) flatpak install -y flathub "$package" ;;

      Snap) sudo snap install "$package" ;;

      Nix) nix-env -iA nixpkgs."$package" ;;

      Pip) pip install "$package" ;;

      *) echo "${fg[red]}❌ Unsupported package manager: $manager${reset_color}" ;;
   esac
}

