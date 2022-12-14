local EMPLOYEES = { "coworker", "developer", "designer", "boss" }

Round = {}
Round.__index = Round

function Round:new()
	self.round = 0
	self.opponent = 'coworker'
	self.gameSpeed = 1
	self.dialog = { "get back to work" }
	
	function self:firstRound()
		self.round = 1
		self.opponent = 'coworker'
		self.dialog = { "get back to twerk, i mean work", "but we just started the tounament" }
		self.gameSpeed = 1
	end
	
	function self:secondRound()
		self.round = 2
		self.opponent = 'developer'
		self.dialog = { "we've been hacked", "almost done!" }
		self.gameSpeed = 2
	end
	
	function self:thirdRound()
		self.round = 3
		self.opponent = 'designer'
		self.dialog = { "the servers are on fire!", "one more round!" }
		self.gameSpeed = 3
	end
	
	function self:fourthRound()
		self.round = 4
		self.opponent = 'boss'
		self.dialog = { "fine but if i win you fix things", "okie dokie!" }
		self.gameSpeed = 4
	end
	
	function self:setRound()
		if self.round == 1 then
			self:firstRound()
		elseif self.round == 2 then
			self:secondRound()
		elseif self.round == 3 then
			self:thirdRound()
		elseif self.round == 4 then
			self:fourthRound()
		end
	end
	
	function self:nextRound()
		self.round += 1
		self:setRound()
	end
	
	return self
end
