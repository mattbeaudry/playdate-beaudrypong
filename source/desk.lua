import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics
local blink = gfx.animation.blinker.new()

Desk = {}
Desk.__index = Desk

local EMPLOYEES = { "coworker", "developer", "server", "boss" }
local STATES = { "working", "afk", "trashed" }
local deskImages = {}

for i = 1, #EMPLOYEES do
	for j = 1, #STATES do
		for k = 1, 2 do 
			local fileName = "desk-"..EMPLOYEES[i].."-"..STATES[j].."-"..k
			deskImages[fileName] = gfx.image.new("images/"..fileName)
		end
	end
end

function Desk:new()
	local self = gfx.sprite.new(deskImages["desk-coworker-working"])
	self.employee = "coworker"
	self.state = "working"
	blink:startLoop()
	
	function self:updateImage()
		if blink.on then
			self:setImage(deskImages["desk-"..self.employee.."-"..self.state.."-1"])
		else
			self:setImage(deskImages["desk-"..self.employee.."-"..self.state.."-2"])
		end
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
	
	function self:update()
		blink:update()
		self:updateImage()
	end
	
	return self
end