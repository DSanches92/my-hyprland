#!/usr/bin/env bash
#
# Aplica os dotfiles do my-hyprland copiando os arquivos (sem links simbólicos).
#
# Uso: ./install.sh [--no-sddm]
#
# - Cada pasta de config do repo é copiada para ~/.config/<pasta>, arquivo por
#   arquivo. Arquivos que o app cria por conta própria e que não estão no repo
#   continuam onde estão.
# - Se o destino já existe e é diferente, ele vira <arquivo>.bak-<data> antes de
#   ser sobrescrito. Arquivos idênticos são pulados.
# - zsh/danilo.zsh vai para ~/.oh-my-zsh/custom/, e o tema e os plugins são
#   ajustados no ~/.zshrc gerado pelo Oh My Zsh.
# - O tema do SDDM é instalado no sistema com sudo (o SDDM não lê a sua home).
#   Use --no-sddm para pular essa parte.
#
# Depois de editar algo em ~/.config, copie de volta para o repo na mão.
#

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

#------------------------------------------------------------------------------#
#                    CONFIGURAÇÕES — AJUSTE SE NECESSÁRIO                      #
#------------------------------------------------------------------------------#

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
STAMP="$(date +%Y%m%d-%H%M%S)"

ZSH_THEME_NAME="refined"
ZSH_PLUGINS="git node podman golang zsh-autosuggestions zsh-syntax-highlighting"

# Pastas do repo que NÃO vão para ~/.config.
SKIP_DIRS=(.git zsh)

INSTALL_SDDM=true

#------------------------------------------------------------------------------#
#                               ARGUMENTOS                                     #
#------------------------------------------------------------------------------#
for arg in "$@"; do
  case "$arg" in
    --no-sddm) INSTALL_SDDM=false ;;
    -h|--help)
      sed -n '3,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo -e "${RED}[ERRO] Opção desconhecida: $arg${NC}" >&2
      exit 1
      ;;
  esac
done

if [[ $EUID -eq 0 ]]; then
  echo -e "${RED}[ERRO] Não execute como root. Use seu usuário normal.${NC}" >&2
  exit 1
fi

#------------------------------------------------------------------------------#
#                               FUNÇÕES                                        #
#------------------------------------------------------------------------------#
COPIED=0
SKIPPED=0
BACKED_UP=0

# copy_file <origem> <destino>
# Copia preservando as permissões (scripts continuam executáveis).
copy_file() {
  local src="$1" dst="$2"

  if [[ -f "$dst" && ! -L "$dst" ]] && cmp -s "$src" "$dst"; then
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.bak-$STAMP"
    echo -e "    ${YELLOW}backup:${NC} ${dst/#$HOME/\~}.bak-$STAMP"
    BACKED_UP=$((BACKED_UP + 1))
  fi
  cp -p "$src" "$dst"
  echo -e "    ${GREEN}cópia:${NC}  ${dst/#$HOME/\~}"
  COPIED=$((COPIED + 1))
}

is_skipped() {
  local name="$1" skip
  for skip in "${SKIP_DIRS[@]}"; do
    [[ "$name" == "$skip" ]] && return 0
  done
  return 1
}

#------------------------------------------------------------------------------#
#                     1. CONFIGS EM ~/.config                                  #
#------------------------------------------------------------------------------#
echo -e "${CYAN}:: [1/3] Copiando configs para ${CONFIG_DIR/#$HOME/\~}...${NC}"

for dir in "$REPO_DIR"/*/; do
  name="$(basename "$dir")"
  is_skipped "$name" && continue

  echo -e "${CYAN}  -> $name${NC}"
  while IFS= read -r -d '' file; do
    rel="${file#"$REPO_DIR"/}"
    copy_file "$file" "$CONFIG_DIR/$rel"
  done < <(find "$dir" -type f ! -name '*.bak' ! -name '*.bak-*' -print0 | sort -z)
done

echo -e "${GREEN}:: [1/3] Concluído: $COPIED copiado(s), $SKIPPED sem mudança, $BACKED_UP backup(s).${NC}"
echo ""

#------------------------------------------------------------------------------#
#                     2. ZSH (por cima do Oh My Zsh)                           #
#------------------------------------------------------------------------------#
echo -e "${CYAN}:: [2/3] Aplicando a config do zsh...${NC}"

if [[ ! -d "$ZSH_DIR" ]]; then
  echo -e "${YELLOW}:: Oh My Zsh não encontrado em ${ZSH_DIR/#$HOME/\~}. Pulando o zsh.${NC}"
  echo -e "${YELLOW}   (ele é instalado pelo post-install.sh do arch-install)${NC}"
else
  copy_file "$REPO_DIR/zsh/danilo.zsh" "$ZSH_CUSTOM_DIR/danilo.zsh"

  if [[ ! -f "$ZSHRC" ]]; then
    echo -e "${YELLOW}:: ${ZSHRC/#$HOME/\~} não existe. Pulando tema e plugins.${NC}"
  else
    NEW_THEME="ZSH_THEME=\"$ZSH_THEME_NAME\""
    NEW_PLUGINS="plugins=($ZSH_PLUGINS)"

    if grep -qxF "$NEW_THEME" "$ZSHRC" && grep -qxF "$NEW_PLUGINS" "$ZSHRC"; then
      echo -e "    Tema e plugins já estão no ${ZSHRC/#$HOME/\~}."
    elif ! grep -q '^ZSH_THEME=' "$ZSHRC" || ! grep -q '^plugins=(.*)$' "$ZSHRC"; then
      # Lista de plugins em várias linhas, ou .zshrc fora do padrão: não arrisca.
      echo -e "${YELLOW}:: Não achei 'ZSH_THEME=' ou 'plugins=(...)' em uma linha só no ${ZSHRC/#$HOME/\~}.${NC}"
      echo -e "${YELLOW}   Ajuste na mão:${NC}"
      echo "     $NEW_THEME"
      echo "     $NEW_PLUGINS"
    else
      cp -p "$ZSHRC" "$ZSHRC.bak-$STAMP"
      echo -e "    ${YELLOW}backup:${NC} ${ZSHRC/#$HOME/\~}.bak-$STAMP"
      sed -i \
        -e "s|^ZSH_THEME=.*|$NEW_THEME|" \
        -e "s|^plugins=(.*)$|$NEW_PLUGINS|" \
        "$ZSHRC"
      echo -e "    ${GREEN}ajustado:${NC} $NEW_THEME"
      echo -e "    ${GREEN}ajustado:${NC} $NEW_PLUGINS"
    fi
  fi

  for plugin in $ZSH_PLUGINS zsh-histdb; do
    case "$plugin" in
      zsh-*)
        [[ -d "$ZSH_CUSTOM_DIR/plugins/$plugin" ]] || \
          echo -e "${YELLOW}:: Plugin $plugin não está em ${ZSH_CUSTOM_DIR/#$HOME/\~}/plugins (rode o post-install.sh).${NC}"
        ;;
    esac
  done
fi

echo -e "${GREEN}:: [2/3] Concluído.${NC}"
echo ""

#------------------------------------------------------------------------------#
#                     3. TEMA DO SDDM (sistema, com sudo)                      #
#------------------------------------------------------------------------------#
echo -e "${CYAN}:: [3/3] Tema do SDDM...${NC}"

if [[ "$INSTALL_SDDM" != true ]]; then
  echo -e "    Pulado (--no-sddm)."
elif [[ ! -x "$REPO_DIR/sddm/install.sh" ]]; then
  echo -e "${YELLOW}:: sddm/install.sh não encontrado ou sem permissão de execução. Pulando.${NC}"
else
  sudo "$REPO_DIR/sddm/install.sh"
fi

echo -e "${GREEN}:: [3/3] Concluído.${NC}"
echo ""

VERSION="$(git -C "$REPO_DIR" describe --tags --always --dirty 2>/dev/null || echo "sem versão")"
echo -e "${GREEN}:: my-hyprland $VERSION aplicado.${NC}"
echo -e "${YELLOW}:: Para ver as mudanças: hyprctl reload · pkill waybar && waybar & · exec zsh${NC}"
