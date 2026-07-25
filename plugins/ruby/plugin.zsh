alias clean-user-gems='rm -rf ~/.gem/ruby/*/extensions/ ~/.bundle/cache/'
export RUBYOPT="-W:no-deprecated -W:no-experimental"
# Direct bundle configurations out of the home root and into proper caching specs
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bundle"
export BUNDLE_USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/bundle"
export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME:-$HOME/.local/share}/bundle"

# Load chruby core environment logic natively
if [ -f /usr/share/chruby/chruby.sh ]; then
  source /usr/share/chruby/chruby.sh

  # Enable auto-switching if a directory has a .ruby-version file
  if [ -f /usr/share/chruby/auto.sh ]; then
    source /usr/share/chruby/auto.sh
  fi

  # Select your LFS system-compiled Ruby as the fallback baseline
  chruby system 2>/dev/null
fi


