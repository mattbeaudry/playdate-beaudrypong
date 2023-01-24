
local gfx <const> = playdate.graphics
local data <const> = playdate.datastore

local splashScreenCard = gfx.image.new("card.png")

Story = {}
Story.__index = Story

function Story:new()
	function self:titleScreen()
		gfx.drawText("SHITTY PING PONG", 130, 30)
		splashScreenCard:draw(30, 20)
		
		gfx.drawText("PRESS B for Scoreboard", 30, 210)
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
	
	function self:endScreen(score, maxScore, totalScore, stats)
		if score[4][1] >= maxScore then
			gfx.drawText("Congratulations, you ", 30, 30)
			gfx.drawText("won the tournament!", 30, 45)
			gfx.drawText("The company burns to", 30, 60)
			gfx.drawText("the ground and you lose", 30, 75)
			gfx.drawText("your job.", 30, 90)
			gfx.drawText("YOU WIN", 30, 120)
		elseif score[4][2] >= maxScore then
			gfx.drawText("Finally you go back to", 30, 30)
			gfx.drawText("your desk and easily", 30, 45)
			gfx.drawText("get the site back up,", 30, 60)
			gfx.drawText("the company is saved!", 30, 75)
			gfx.drawText("GAME OVER", 30, 105)
		end
				
		gfx.drawText("Round 1: " .. score[1][1] .. " - " .. score[1][2], 250, 30)
		gfx.drawText("Round 2: " .. score[2][1] .. " - " .. score[2][2], 250, 45)
		gfx.drawText("Round 3: " .. score[3][1] .. " - " .. score[3][2], 250, 60)
		gfx.drawText("Round 4: " .. score[4][1] .. " - " .. score[4][2], 250, 75)
		
		gfx.drawText("Good hits: " .. stats['goodHits'], 250, 90)
		gfx.drawText("Great hits: " .. stats['greatHits'], 250, 105)
		gfx.drawText("Perfect hits: " .. stats['perfectHits'], 250, 120)
		gfx.drawText("Smashes: " .. stats['smashes'], 250, 135)
		
		gfx.drawText("TOTAL SCORE: "..totalScore, 250, 190)
		
		gfx.drawText("PRESS B for Scoreboard", 30, 210)
		gfx.drawText("PRESS A", 330, 210)
	end
	
	return self
end
