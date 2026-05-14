hs.loadSpoon("Hammerflow")

-- optionally set ui format (must be done before loading toml config)
-- 🌸 Catppuccin Mocha theme
spoon.Hammerflow.registerFormat({
	atScreenEdge = 2,
	fillColor = { alpha = .875, hex = "1e1e2e" },
	padding = 18,
	radius = 12,
	strokeColor = { alpha = .875, hex = "cba6f7" },
	textColor = { alpha = 1, hex = "cdd6f4" },
	textStyle = {
		paragraphStyle = { lineSpacing = 6 },
		shadow = { offset = { h = -1, w = 1 }, blurRadius = 10, color = { alpha = .50, white = 0 } }
	},
	strokeWidth = 6,
	textFont = "Monaco",
	textSize = 18,
})

spoon.Hammerflow.loadFirstValidTomlFile({
    "home.toml",
    "work.toml",
    "Spoons/Hammerflow.spoon/sample.toml"
})

-- optionally respect auto_reload setting in the toml config.
if spoon.Hammerflow.auto_reload then
    hs.loadSpoon("ReloadConfiguration")
    -- set any paths for auto reload
    -- spoon.ReloadConfiguration.watch_paths = {hs.configDir, "~/path/to/my/configs/"}
    spoon.ReloadConfiguration:start()
end
