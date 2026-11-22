# my-hyprland

Dotfiles do meu desktop **Hyprland** no Arch Linux, com tema **Catppuccin Macchiato** em tudo.

A instalação do sistema e dos pacotes fica em outro repositório: [arch-install](https://github.com/DSanches92/arch-install). O `install-hyprland.sh` de lá clona este repo e aplica os dotfiles automaticamente.

## O que tem aqui

| Pasta | App | Destino |
|---|---|---|
| `hypr/` | Hyprland (`hyprland.lua`), hyprpaper, hypridle, hyprlock e wallpapers | `~/.config/hypr` |
| `waybar/` | Barra: workspaces, relógio, atualizações, áudio, rede e bandeja | `~/.config/waybar` |
| `rofi/` | Launcher de aplicativos | `~/.config/rofi` |
| `alacritty/` | Terminal | `~/.config/alacritty` |
| `yazi/` | Gerenciador de arquivos no terminal (flavor Catppuccin) | `~/.config/yazi` |
| `zed/` | Editor Zed | `~/.config/zed` |
| `gtk-3.0/`, `gtk-4.0/`, `qt6ct/` | Tema escuro para apps GTK e Qt | `~/.config/...` |
| `sddm/` | Tema da tela de login (`macchiato`) e avatar | `~/.config/sddm` + sistema |
| `zsh/` | Config pessoal do zsh (`danilo.zsh`) | `~/.oh-my-zsh/custom/` |

## Instalação

Numa instalação nova, o [arch-install](https://github.com/DSanches92/arch-install) faz isso sozinho. Para aplicar na mão:

```bash
git clone https://github.com/DSanches92/my-hyprland.git
cd my-hyprland
./install.sh            # ou ./install.sh --no-sddm para pular o tema do SDDM
```

O `install.sh`:

- **Copia** cada arquivo para `~/.config`. Ele não cria links simbólicos.
  - Arquivo igual ao do repo: pula.
  - Arquivo diferente: guarda o atual como `<arquivo>.bak-<data>` antes de sobrescrever.
  - Arquivo que só existe em `~/.config`: fica intacto.
- **zsh:** copia o `danilo.zsh` para `~/.oh-my-zsh/custom/` e ajusta só o tema (`refined`) e a lista de plugins no `~/.zshrc`. O resto do `.zshrc` continua o padrão do Oh My Zsh.
- **SDDM:** instala o tema da tela de login no sistema com `sudo`, porque o SDDM não lê arquivos da home.

Pode rodar quantas vezes quiser: na segunda vez, nada muda.

Depois de aplicar:

```bash
hyprctl reload                 # ou SUPER+SHIFT+C
pkill waybar && waybar &
exec zsh
```

> As configs são cópias. Se você editar algo direto em `~/.config`, copie de volta para o repo antes de fazer o commit.

## Atalhos principais

`SUPER` é a tecla Windows.

| Atalho | Ação |
|---|---|
| `SUPER + Enter` | Terminal (Alacritty) |
| `SUPER + D` | Launcher (Rofi) |
| `SUPER + B` | Firefox |
| `SUPER + Y` | Yazi |
| `SUPER + SHIFT + T` | Thunar |
| `SUPER + Q` | Fechar janela |
| `SUPER + F` | Tela cheia |
| `SUPER + SHIFT + Espaço` | Janela flutuante |
| `SUPER + W` | Agrupar janelas |
| `SUPER + SHIFT + W` | Fixar janela em todos os workspaces |
| `SUPER + T` | Alternar a divisão da janela |
| `SUPER + R` | Modo redimensionar (setas; `Esc` para sair) |
| `SUPER + setas` / `SUPER + SHIFT + setas` | Mover o foco / mover a janela |
| `SUPER + 1..0` / `SUPER + SHIFT + 1..0` | Ir para o workspace / mover a janela para ele |
| `SUPER + SHIFT + S` | Captura de uma área da tela |
| `SUPER + L` | Bloquear a tela |
| `SUPER + SHIFT + E` | Menu de saída (wlogout) |
| `SUPER + SHIFT + C` | Recarregar o Hyprland |

## Monitor e teclado

- **Monitor:** `HDMI-A-1` em 2560x1080 a 75 Hz. Para outro monitor, ajuste o `hl.monitor` no começo do `hypr/hyprland.lua`. Lá também tem um exemplo comentado de configuração automática.
- **Teclado:** layout `br` (ABNT2).

---

<p align="center">
  Criado com ❤️ por <a href="https://github.com/DSanches92">Danilo Sanches</a>
</p>
