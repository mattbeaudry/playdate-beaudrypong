import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Desk = {}
Desk.__index = Desk

local EMPLOYEES = { "coworker", "developer", "server", "boss" }
local STATES = { "working", "afk", "trashed" }
local deskImages = {}

for i = 1, #EMPLOYEES do
	for j = 1, #STATES do 
		local fileName = "desk-"..EMPLOYEES[i].."-"..STATES[j]
		deskImages[fileName] = gfx.image.new("images/"..fileName)
	end
end

function Desk:new()
	local self = gfx.sprite.new(deskImages["desk-coworker-working"])
	self.employee = "coworker"
	self.state = "working"
	
	function self:updateImage()
		self:setImage(deskImages["desk-"..self.employee.."-"..self.state])
	end
	
	function self:updateEmployee(newEmployee)
		self.employee = newEmployee;
		self:updateImage()
	end
	
	function self:updateState(newState)
		self.state = newState;
		self:updateImage()
	end
	
	self:updateImage()
	
	return self
end