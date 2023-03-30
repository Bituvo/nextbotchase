nextbot.nextbots = {
	{name = "obunga", formal_name = "Obunga", speed = 10},
	{name = "selene", formal_name = "Selene Delgado López", speed = 11}
}

for _, nextbot_def in ipairs(nextbot.nextbots) do
	nextbot.register_nextbot(nextbot_def)
end