local icons = require("icons")
local colors = require("colors")

local pomodoro_item = sbar.add("item", "pomodoro_item", {
	position = "left",
	drawing = true,
	padding_left = 3,
	padding_right = 3,
	background = {
		color = colors.bg2,
		corner_radius = 6,
	},
	icon = {
		string = icons.pomodoro.idle,
		color = colors.grey,
	},
	label = {
		string = "25:00",
		font = {
			size = 10,
		},
		color = colors.white,
	},
	script = "/Users/itohleo/.config/sketchybar/helpers/pomodoro_app_update.sh",
	update_freq = 2,
	popup = {
		align = "center",
		horizontal = true,
	},
})

-- Start/Pause button
sbar.add("item", "pomodoro_start_pause", {
	position = "popup." .. pomodoro_item.name,
	icon = {
		string = icons.pomodoro.start,
		color = colors.green,
	},
	label = {
		drawing = false,
	},
	click_script = "~/.config/sketchybar/helpers/pomodoro_app_click.sh toggle-timer",
})

-- Reset button
sbar.add("item", "pomodoro_reset", {
	position = "popup." .. pomodoro_item.name,
	icon = {
		string = icons.pomodoro.reset,
		color = colors.red,
	},
	label = {
		drawing = false,
	},
	click_script = "~/.config/sketchybar/helpers/pomodoro_app_click.sh reset-timer",
})

-- Session counter
sbar.add("item", "pomodoro_sessions", {
	position = "popup." .. pomodoro_item.name,
	icon = {
		string = "●",
		color = colors.yellow,
	},
	label = {
		string = "0/4",
		font = {
			size = 9,
		},
		color = colors.white,
	},
})

-- Click events
pomodoro_item:subscribe("mouse.clicked", function(env)
	pomodoro_item:set({
		popup = {
			drawing = "toggle",
		},
	})
end)

pomodoro_item:subscribe("mouse.exited.global", function(env)
	pomodoro_item:set({
		popup = {
			drawing = false,
		},
	})
end)