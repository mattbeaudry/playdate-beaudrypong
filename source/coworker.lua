import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Coworker = {}
Coworker.__index = Coworker

local EMPLOYEES = { "coworker", "developer", "designer", "boss" }
local STATES = { "stand", "stance", "swing", "serve", "throw", "smash", "injured" }
local employeeImages = {}

for i = 1, #EMPLOYEES do
	for j = 1, #STATES do 
		local fileName = EMPLOYEES[i].."-"..STATES[j]
		employeeImages[fileName] = gfx.image.new("images/"..fileName)
	end
end

function Coworker:new()
	
	local self = gfx.sprite.new()
	self.employee = "coworker"
	self:setImage(employeeImages[self.employee.."-stance"], gfx.kImageFlippedX)
	self.velocity = 0
	self.hasSwung = false
	self.hasServed = false
	
	function self:stance()
		self:setImage(employeeImages[self.employee.."-stance"], gfx.kImageFlippedX)
	end
	
	function self:injured()
		self:setImage(employeeImages[self.employee.."-injured"], gfx.kImageFlippedX)
	end
	
	function self:swing()
		self:setImage(employeeImages[self.employee.."-swing"], gfx.kImageFlippedX)
		playdate.timer.performAfterDelay(100, function()
			self:setImage(employeeImages[self.employee.."-stance"], gfx.kImageFlippedX)
		end)
	end
	
	function self:throw()
		self:setImage(employeeImages[self.employee.."-throw"], gfx.kImageFlippedX)
		playdate.timer.performAfterDelay(300, function()
			self:setImage(employeeImages[self.employee.."-stance"], gfx.kImageFlippedX)
		end)
	end
	
	function self:serve()
		self:setImage(employeeImages[self.employee.."-serve"], gfx.kImageFlippedX)
	end
	
	return self
end