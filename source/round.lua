local EMPLOYEES = { "coworker", "developer", "designer", "boss" }

Round = {}
Round.__index = Round

function Round:new()
	self.round = 0
	self.opponent = 'coworker'
	self.timeSpeed = 4
	self.dialog = { "" }
	
	function self:firstRound()
		self.round = 1
		self.opponent = 'coworker'
		self.dialog = {
			{
				"coworker",
				"get back to twerk, i mean work",
			},
			{
				"player",
				"but we just started the tournament",
			}
		}
		self.timeSpeed = 5
	end
	
	function self:secondRound()
		self.round = 2
		self.opponent = 'developer'
		self.dialog = { 
			{
				"developer",
				"we've been hacked", 
			},
			{
				"player",
				"almost done!",
			}
		}
		self.timeSpeed = 4
	end
	
	function self:thirdRound()
		self.round = 3
		self.opponent = 'designer'
		self.dialog = { 
			{
				"designer",
				"the servers are on fire!",
			},
			{
				"player",
				"one more round!"
			}
		}
		self.timeSpeed = 3
	end
	
	function self:fourthRound()
		self.round = 4
		self.opponent = 'boss'
		self.dialog = {
			{
				"boss",
				"fine but if i win you fix things",
			},
			{
				"player",
				"okie dokie!" 
			}
		}
		self.timeSpeed = 2
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
		print("")
		print("ROUND, TIMESPEED")
		print(self.round)
		print(self.timeSpeed)
		print("")
	end
	
	return self
end
