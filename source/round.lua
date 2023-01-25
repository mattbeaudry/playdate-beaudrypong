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
				"Hey, down for a quick pong tournament?",
			},
			{
				"player",
				"After launching code to production? I'm in!!",
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
				"The site is down and we got hacked! Customers are losing data.", 
			},
			{
				"player",
				"It'll be fine, one more game!",
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
				"The servers are on fire we have to evacuate the building!",
			},
			{
				"player",
				"Not after I beat you!"
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
				"The company is destroyed. If I win, you fix things! ",
			},
			{
				"player",
				"Okie dokie!" 
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
	end
	
	return self
end
