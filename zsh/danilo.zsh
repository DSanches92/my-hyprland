# Configuração pessoal do zsh, carregada pelo Oh My Zsh.
#
# O install.sh do my-hyprland copia este arquivo para ~/.oh-my-zsh/custom/.
# O Oh My Zsh carrega todo ~/.oh-my-zsh/custom/*.zsh depois dos plugins,
# então o .zshrc gerado por ele continua padrão. Só o tema e a lista de
# plugins precisam ficar no .zshrc (o install.sh ajusta essas duas linhas).

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export TERMINAL=alacritty

# --- zsh-histdb: histórico em SQLite + sugestões baseadas nele ---------------
source "$ZSH_CUSTOM/plugins/zsh-histdb/sqlite-history.zsh"
_zsh_autosuggest_strategy_histdb_top() {
    local query="
      select commands.argv from history
      left join commands on history.command_id = commands.rowid
      left join places on history.place_id = places.rowid
      where commands.argv LIKE '$(sql_escape $1)%'
      group by commands.argv, places.dir
      order by places.dir != '$(sql_escape $PWD)', count(*) desc, max(history.start_time) desc
      limit 1 "
    suggestion=$(_histdb_query "$query")
}
ZSH_AUTOSUGGEST_STRATEGY=histdb_top

# --- Podman -----------------------------------------------------------------
podman-nuke() {
  echo -e "\n\e[1;34m Iniciando limpeza total do Podman (Containers, Imagens, Volumes)...\e[0m\n"

  podman system prune --all --volumes --force && \
    podman rm -f -a && podman rmi -f -a

  echo -e "\n\e[1;32m Podman limpo com sucesso!\e[0m\n"
}

# --- nvm --------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Go ---------------------------------------------------------------------
export GOPATH="$HOME/Projects/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# --- bun --------------------------------------------------------------------
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
