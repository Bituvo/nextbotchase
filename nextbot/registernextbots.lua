nextbot.nextbots = {
	{name = "obunga", formal_name = "Obunga", speed = 10}
}

for _, nextbot_def in ipairs(nextbot.nextbots) do
	nextbot.register_nextbot(nextbot_def)
end