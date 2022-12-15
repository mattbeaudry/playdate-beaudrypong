import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Coworker = {}
Coworker.__index = Coworker

local coworkerStand = gfx.image.new("images/coworker-stand")
local coworkerSwing = gfx.image.new("images/coworker-swing")
local coworkerServe = gfx.image.new("images/coworker-serve")
local coworkerThrow = gfx.image.new("images/coworker-throw")
local coworkerSmash = gfx.image.new("images/coworker-smash")
local coworkerInjured = gfx.image.new("images/coworker-injured")

function Coworker:new()
	
	local self = gfx.sprite.new(coworkerStand)
	self:setImage(coworkerStand, gfx.kImageFlippedX)
	self.velocity = 0
	self.hasSwung = false
	self.hasServed = false
	
	function self:stance()
		self:setImage(coworkerStand, gfx.kImageFlippedX)
	end
	
	function self:injured()
		self:setImage(coworkerInjured, gfx.kImageFlippedX)
	end
	
	function self:swing()
		self:setImage(coworkerSwing, gfx.kImageFlippedX)
		playdate.timer.performAfterDelay(100, function()
			self:setImage(coworkerStand, gfx.kImageFlippedX)
		end)
	end
	
	function self:throw()
		self:setImage(coworkerThrow, gfx.kImageFlippedX)
		playdate.timer.performAfterDelay(300, function()
			self:setImage(coworkerStand, gfx.kImageFlippedX)
		end)
	end
	
	function self:serve()
		self:setImage(coworkerServe, gfx.kImageFlippedX)
	end
	
	return self
end