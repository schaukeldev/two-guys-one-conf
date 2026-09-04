-- Keep configuration order explicit while the details live in focused modules.
require("config.monitors")
require("config.startup")
require("config.appearance")
require("config.input")
require("config.keybindings")
require("config.noctalia")
require("config.rules")

-- For Noctalia Color templates
require("noctalia").apply_theme()
