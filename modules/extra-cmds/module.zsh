# take functions

# mkcd is equivalent to takedir
alias cd="z"

function mkcd takedir() {
  mkdir -p $@ && cd ${@:$#}
}

function takeurl() {
  local data thedir
  data="$(mktemp)"
  curl -L "$1" > "$data"
  tar xf "$data"
  thedir="$(tar tf "$data" | head -n 1)"
  rm "$data"
  cd "$thedir"
}

function takezip() {
  local data thedir
  data="$(mktemp)"
  curl -L "$1" > "$data"
  unzip "$data" -d "./"
  thedir="$(unzip -l "$data" | awk 'NR==4 {print $4}' | sed 's/\/.*//')"
  rm "$data"
  cd "$thedir"
}

function takegit() {
  git clone "$1"
  cd "$(basename ${1%%.git})"
}

function take() {
  if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]; then
    takeurl "$1"
  elif [[ $1 =~ ^(https?|ftp).*\.(zip)$ ]]; then
    takezip "$1"
  elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]; then
    takegit "$1"
  else
    takedir "$@"
  fi
}

bat_alias_wrapper() {
    bat --theme=Nord "$@"
}

touch() {
  # Loop through all arguments
  for arg in "$@"; do
    # Extract the directory part of the path
    local dir_path=$(dirname "$arg")

    # Create the directory if it doesn't exist
    if [ ! -d "$dir_path" ]; then
      mkdir -p "$dir_path"
    fi

    # Use the original 'touch' command to create the file
    command touch "$arg"
  done
}

alias cat='bat_alias_wrapper'
eval "$(tempit init bash)"
