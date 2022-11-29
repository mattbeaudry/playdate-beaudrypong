import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Coworker = {}
Coworker.__index = Coworker

local coworkerSprite = nil
local coworkerStand = gfx.image.new("images/coworker-stand")
local coworkerSwing = gfx.image.new("images/coworker-swing")
local coworkerServe = gfx.image.new("images/coworker-serve")
local coworkerThrow = gfx.image.new("images/coworker-throw")
local coworkerSmash = gfx.image.new("images/coworker-smash")

function Coworker:new()
	
	local self = gfx.sprite.new(coworkerStand)
	self:setImage(coworkerStand, gfx.kImageFlippedX)
	
	function self:swing()
		self:setImage(coworkerSwing, gfx.kImageFlippedX)
		playdate.timer.performAfterDelay(100, function()
			self:setImage(coworkerStand, gfx.kImageFlippedX)
		end)
	end
	
	return self
end