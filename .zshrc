function safe_source { [[ -f $1 ]] && source $1 || echo "couldn't source $1" }

# p10k::instant-prompt {
  if [[ -e "${HOME}/.disable_instant_prompt" ]]; then
    rm "${HOME}/.disable_instant_prompt"
  else
    safe_source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"
  fi
# }

# zinit {
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"

  # download {
    test ! -d $ZINIT_HOME && mkdir -p "$(dirname $ZINIT_HOME)"
    test ! -d $ZINIT_HOME/.git && git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
  # }

  # install
  safe_source "${ZINIT_HOME}/zinit.zsh"

  # path {
    # lbin links binaries to $ZPFX/bin
    if ! echo "${PATH}" | grep -q "${ZPFX}/bin"; then
      export PATH="${ZPFX}/bin:${PATH}"
    fi
    if ! echo "${PATH}" | grep -q "${HOME}/.local/bin"; then
      export PATH="${PATH}:${HOME}/.local/bin"
    fi
    unset sol_bin
  # }

  # annexes {
    zinit light NICHOLAS85/z-a-linkbin
    zinit light NICHOLAS85/z-a-eval
    zinit light zdharma-continuum/zinit-annex-patch-dl
  # }
# }

# p10k::install {
  zinit ice depth"1"
  zinit load romkatv/powerlevel10k
  safe_source "${ZDOTDIR}/.p10k.zsh"
# }

zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-syntax-highlighting

# history {
  zinit ice atload"zstyle ':prezto:module:history' histfile ${XDG_STATE_HOME:-${HOME}/.local/state}/zsh/history"
  zinit snippet PZTM::history
# }

# bat::install {
  zinit ice \
    from"gh-r" \
    lbin"!bat*/bat -> cat" \
    atload"!export BAT_THEME=base16"
  zinit light sharkdp/bat
# }

# eza {
  # install {
    zinit ice from"gh-r" ver"v0.18.17" lbin"!**/eza"
    zinit load eza-community/eza
  # }

  zinit ice \
    wait'command -v eza &>/dev/null' lucid \
    id-as'_local/eza-alias' \
    nocompile \
    aliases atload"!
      alias ls='eza -AF --group-directories-first --git-ignore --ignore-glob=\".git*\" -w 100'
      alias lsg='eza -AF --group-directories-first -w 100'
      alias tree='eza -TAl'"
  zinit light bluedragon1221/empty

  # fzf preview cmd
  ls_picker_cmd='eza -A1F --icons --color=always --group-directories-first $realpath'
# }

# fzf {
  # install
  zinit ice from"gh-r" lbin! eval"fzf --zsh"
  zinit load junegunn/fzf

  # tab-complete {
    zinit ice \
      wait'command -v fzf &>/dev/null' lucid \
      atload"!
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview \"$ls_picker_cmd\"" \
      blockf
    zinit load Aloxaf/fzf-tab
  # }
# }

# helix {
  # install {
    zinit ice \
      from"gh-r" \
      nocompile \
      mv"helix* -> helix" \
      lbin"!helix/hx -> helix" \
      dl'https://gist.github.com/bluedragon1221/e92fc9587d917c7cc130f2fb0656be58/raw -> config.toml' \
      atload'!export HELIX_RUNTIME="${PWD}/helix/runtime" HELIX_CONFIG="${PWD}/config.toml"'
    zinit light helix-editor/helix

    # make sure this doesn't load until HELIX_CONFIG exists
    zinit ice \
      id-as"_local/hx-alias" \
      wait'command -v helix &>/dev/null && [[ $HELIX_CONFIG != "" ]]' lucid \
      nocompile nocompletions aliases atload'!
alias hx="helix -c ${HELIX_CONFIG}"
export EDITOR=hx
alias vim=hx'
    zinit light bluedragon1221/empty
  # }

  # language-servers {
    zinit from"gh-r" for \
      lbin"!marksman* -> marksman"             artempyanykh/marksman \
      lbin"!markdown-oxide* -> markdown-oxide" Feel-ix-343/markdown-oxide \
      lbin"!bin/lua-language-server"           LuaLS/lua-language-server
  # }
# }

# python::install {
  zinit from"gh-r" for \
    lbin"!uv*/uv" @astral-sh/uv \
    lbin!         @astral-sh/ruff
# }

# rust {
  # rustup annex
  zinit light zdharma-continuum/zinit-annex-rust

  zinit ice \
    as"command" \
    rustup \
    id-as"_local/rust" \
    pick"bin/*" \
    atload'!export CARGO_HOME=$PWD/cargo
                  RUSTUP_HOME=$PWD/rustup
                  PATH="${PATH}:$PWD/cargo/bin"'
  zinit light bluedragon1221/empty
# }

alias wget=wget --no-hsts
alias feh="feh -."

# omz-plugins::install {
  zinit snippet OMZP::cp
  zinit snippet OMZP::sudo
  zinit snippet PZTM::environment
# }

# completions {
  # install
  zinit ice blockf
  zinit light zsh-users/zsh-completions

  # config {
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # don't care about case
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # colored output
    zstyle ':completion:*' special-dirs true # show dotfiles
  # }

  # load-completions {
    autoload compinit; compinit
    zicdreplay -q
  # }
# }
