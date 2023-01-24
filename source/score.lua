
local gfx <const> = playdate.graphics
local data <const> = playdate.datastore

Score = {}
Score.__index = Score

function Score:new()
	self.scoreAdded = false
	self.wonTournament = false
	self.winningRounds = 0
	self.totalPoints = 0
	self.perfectStrokes = 0
	self.greatStrokes = 0
	self.goodStrokes = 0
	self.poorStrokes = 0
	self.smashes = 0
	self.roundScores = {
		{0, 0},
		{0, 0},
		{0, 0},
		{0, 0},
	}
	self.maxScore = 1
	self.totalScore = 0
	self.stats = {}
	self.stats['perfectHits'] = 0
	self.stats['greatHits'] = 0
	self.stats['goodHits'] = 0
	self.stats['poorHits'] = 0
	self.stats['smashes'] = 0
	
	function self:scoreboard()
		local scoreData = data.read("scores") or {}
		
		gfx.drawText("HIGH SCORES", 30, 20)
		
		if data.read("scores") then
			for i = 1, #scoreData do
				gfx.drawText(scoreData[i][1], 30, i * 15 + 40)
				gfx.drawText(scoreData[i][2], 230, i * 15 + 40)
			end
		else
			gfx.drawText("no scores", 30, 55)
		end
		
		gfx.drawText("PRESS A", 330, 210)
	end
	
	function self:addScore()
		local scoreData = data.read("scores") or {}
		local date = playdate.getTime()
		local formattedDate = date.year .. '-' .. date.month .. '-' .. date.day .. '  ' .. date.hour .. ':' .. date.minute
		local scoreRow = { self.totalScore, formattedDate }
		
		table.insert(scoreData, scoreRow)
		data.write(scoreData, "scores", true)
	end
	
	function self:calculateScore()
		self.totalScore = self.roundScores[1][1] + self.roundScores[2][1] + self.roundScores[3][1] + self.roundScores[4][1] + self.stats['goodHits'] + self.stats['greatHits'] + self.stats['perfectHits'] + self.stats['smashes']
	end
	
	return self
end
