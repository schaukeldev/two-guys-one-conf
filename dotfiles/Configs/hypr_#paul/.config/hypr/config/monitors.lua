-- Laptop display, far left.
hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1664@60",
    position = "-1925x0",
    scale    = 1.33,
})

-- Philips, center.
hl.monitor({
    output   = "DVI-I-1",
    mode     = "2560x1440@170",
    position = "0x0",
    scale    = 1,
})

-- Terra, right.
hl.monitor({
    output   = "DVI-I-2",
    mode     = "1920x1080@100",
    position = "2560x0",
    scale    = 1,
})

-- Fallback for any other display.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
