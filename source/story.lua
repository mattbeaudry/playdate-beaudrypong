local gfx <const> = playdate.graphics

Story = {}
Story.__index = Story

function Story:new()
	function self:titleScreen()
		gfx.drawText("SHITTY PING PONG", 120, 40)
		gfx.drawText("press A to serve and swing", 20, 100)
		gfx.drawText("press UP and DOWN to move", 20, 120)
		gfx.drawText("hold B to charge.. release and CRANK to SMASH", 20, 140)
		gfx.drawText("press A to start", 120, 200)
	end
	
	function self:missionScreen()
		gfx.drawText("WELCOME TO SHITTY PING PONG", 120, 40)
		gfx.drawText("You work at Shitty Corp", 20, 100)
		gfx.drawText("You are the lead coder of Shitter", 20, 120)
		gfx.drawText("BOSS: The site is down, get back to work", 20, 140)
		gfx.drawText("--: Okay, but we are in the middle of a rally", 20, 160)
		gfx.drawText("press A to start", 120, 200)
	end
	
	function self:endScreen()
		gfx.drawText("Game Over", 150, 60)
		gfx.drawText("press A to restart", 20, 100)
	end
	
	return self
end