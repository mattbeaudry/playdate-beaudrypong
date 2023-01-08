import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "desk"

local gfx <const> = playdate.graphics

Desks = {}
Desks.__index = Desks

function Desks:new()
	self.currentDesks = {
		{"coworker", "working"},
		{"coworker", "working"},
		{"developer", "working"},
		{"developer", "working"},
		{"boss", "working"},
		{"server", "working"},
		{"server", "working"},
	}
	
	self.deskSprites = {}
	
	for i = 1, #self.currentDesks do
	  self.deskSprites[i] = Desk:new()
	end
	
	function self:firstRound()
		self.currentDesks = {
			{"coworker", "afk"},
			{"coworker", "working"},
			{"developer", "working"},
			{"developer", "working"},
			{"boss", "working"},
			{"server", "working"},
			{"server", "working"},
		}
	end
	
	function self:secondRound()
		self.currentDesks = {
			{"coworker", "trashed"},
			{"coworker", "trashed"},
			{"developer", "afk"},
			{"developer", "working"},
			{"boss", "working"},
			{"server", "working"},
			{"server", "working"},
		}
	end
	
	function self:thirdRound()
		self.currentDesks = {
			{"coworker", "trashed"},
			{"coworker", "trashed"},
			{"developer", "trashed"},
			{"developer", "trashed"},
			{"boss", "working"},
			{"server", "afk"},
			{"server", "working"},
		}
	end
	
	function self:fourthRound()
		self.currentDesks = {
			{"coworker", "trashed"},
			{"coworker", "trashed"},
			{"developer", "trashed"},
			{"developer", "trashed"},
			{"boss", "afk"},
			{"server", "trashed"},
			{"server", "trashed"},
		}
	end
	
	function self:clearDesks()
		print("CLEAR DESKS")
		for i = 1, #self.currentDesks do
			self.deskSprites[i]:remove()
			-- gfx.sprite:updateSprite(self.deskSprites[i])
		end
		gfx.sprite.update()
	end
	
	function self:drawDesks()
		self:clearDesks()
		print("DRAW DESKS")
		for i = 1, #self.currentDesks do
		  self.deskSprites[i]:add()
		  self.deskSprites[i]:updateEmployee(self.currentDesks[i][1])
		  self.deskSprites[i]:updateState(self.currentDesks[i][2])
		  self.deskSprites[i]:moveTo(40+(i*40), 35)
		end
	end
	
	return self
end