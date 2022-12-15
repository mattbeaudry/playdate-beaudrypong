local gfx <const> = playdate.graphics

Story = {}
Story.__index = Story

function Story:new()
	function self:titleScreen()
		gfx.drawText("SHITTY PING PONG", 130, 30)
		
		gfx.drawText("PRESS A", 330, 210)
	end
	
	function self:howToPlay()
		gfx.drawText("HOW TO PLAY", 130, 30)
		
		gfx.drawText("PRESS UP and DOWN to move", 20, 80)
		gfx.drawText("PRESS A to serve and swing", 20, 100)
		gfx.drawText("swing above or below the ball to add SPIN", 20, 120)
		gfx.drawText("HOLD B to charge, release to SMASH", 20, 140)
		
		gfx.drawText("PRESS A", 330, 210)
	end
	
	function self:missionScreen()
		gfx.drawText("WELCOME TO SHITTY PING PONG", 90, 30)
		
		gfx.drawText("you work at Shitty Corp", 20, 75)
		gfx.drawText("you are the lead coder of Shitter", 20, 90)
		
		gfx.drawText("the app crashed!", 20, 115)
		gfx.drawText("customers are losing their data!", 20, 130)
		gfx.drawText("you must get the site back up", 20, 145)
		
		gfx.drawText("... so finish that game and get back to your desk!", 20, 170)
		
		gfx.drawText("PRESS A", 330, 210)
	end
	
	function self:gameOne()
		gfx.drawText("BOSS: The site is down, get back to work", 20, 140)
		gfx.drawText("--: Okay, but we are in the middle of a game", 20, 160)
	end
	
	function self:endScreen(score, maxScore)
		print(score[1].." "..score[2])
		
		if score[1] >= maxScore then
			gfx.drawText("Congratulations, you won the tournament!", 30, 75)
			gfx.drawText("The company burns to the ground", 30, 90)
			gfx.drawText("and you lose your job.", 30, 105)
			gfx.drawText("YOU WIN", 30, 135)
		elseif score[2] >= maxScore then
			gfx.drawText("Finally you go back to your desk", 30, 75)
			gfx.drawText("and easily get the site back up,", 30, 90)
			gfx.drawText("the company is saved!", 30, 105)
			gfx.drawText("GAME OVER", 30, 125)
		end
		
		gfx.drawText("You: " .. score[1], 30, 190)
		gfx.drawText("Coworker: " .. score[2], 30, 205)
		
		gfx.drawText("PRESS A", 330, 210)
	end
	
	return self
end
