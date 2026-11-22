-- hyprland.lua — configuração principal do Hyprland (migrado de hyprland.conf)

local mainMod  = "SUPER"
local terminal = "alacritty"

--------------------------------------------------------------------
-- Monitor
--------------------------------------------------------------------
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1080@75",
    position = "0x0",
    scale    = 1,
})
-- fallback caso o nome acima não bata com nenhum monitor conectado:
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

--------------------------------------------------------------------
-- Environment
--------------------------------------------------------------------
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

--------------------------------------------------------------------
-- Autostart
--------------------------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper") -- wallpaper definido em hyprpaper.conf
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("dex -a -s /etc/xdg/autostart/:~/.config/autostart/")
    hl.exec_cmd("gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
end)

--------------------------------------------------------------------
-- Input
--------------------------------------------------------------------
hl.config({
    input = {
        kb_layout    = "br",
        kb_variant   = "abnt2",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

--------------------------------------------------------------------
-- General / decoração / animações / layout / misc
--------------------------------------------------------------------
hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 1,
        col = {
            active_border   = "rgb(c6a0f6)",
            inactive_border = "rgb(6e738d)",
        },
        layout            = "dwindle",
        resize_on_border  = true,
    },

    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        -- drop_shadow   = true,
        blur = {
            enabled = true,
            size    = 4,
            passes  = 2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        -- pseudotile     = true,
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

--------------------------------------------------------------------
-- Atalhos
--------------------------------------------------------------------

-- arrastar/redimensionar janela flutuante segurando o mod + mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- abrir terminal
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))

-- fechar janela em foco
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- launcher de aplicativos
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun -show-icons"))

-- abrir aplicativos específicos
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + Y",         hl.dsp.exec_cmd(terminal .. " -e yazi"))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("firefox"))

-- mover o foco entre janelas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

-- mover a janela em foco
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))

-- alternar a orientação do split do container em foco
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))

-- tela cheia
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- agrupar janelas em abas (toggle)
hl.bind(mainMod .. " + W", hl.dsp.group.toggle())

-- fixar janela em todos os workspaces
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.pin({ action = "toggle" }))

-- alternar entre flutuante/tiled
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))

-- capturar região da tela
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

-- trocar de workspace / mover a janela em foco para um workspace
for i = 1, 10 do
    local key = i % 10 -- 10 mapeia para a tecla 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- recarregar a configuração do Hyprland
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))

-- menu de logout/desligar/reiniciar
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("wlogout -b 5"))

-- modo de redimensionamento com as setas (Enter/Esc/mod+R pra sair)
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("left",   hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
    hl.bind("right",  hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

-- travar a tela
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- teclas de volume do teclado
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

--------------------------------------------------------------------
-- Regras de janela
--------------------------------------------------------------------
hl.window_rule({ match = { class = "^(calculator)$", title = "^(Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(Timer)$" }, float = true })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(nwg-look)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(mpv)$" }, float = true })
hl.window_rule({ match = { class = "^(imv)$" }, float = true })
hl.window_rule({ match = { class = "^(zenity)$" }, float = true })
hl.window_rule({ match = { class = "^([Tt]hunar)$" }, float = true })
