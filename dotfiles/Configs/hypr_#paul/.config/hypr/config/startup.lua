hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia-shell")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

-- Hardware GPU first, then EVDI devices.
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2:/dev/dri/card0:/dev/dri/card3")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("EVDI_LATENCY", "1")
