import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Player = {}
Player.__index = Player

local playerStand = gfx.image.new("images/player-stand-2")
local playerSwing = gfx.image.new("images/player-swing-2")
local playerServe = gfx.image.new("images/player-serve-2")
local playerThrow = gfx.image.new("images/player-throw-2")
local playerSmash = gfx.image.new("images/player-smash")

local maxSmashPower = 100

function Player:new()
	
	local self = gfx.sprite.new(playerStand)
	self.playerSmashPower = 5
	
	function self:resetPoint()
		self.playerSmashPower = 0
	end
	
	function self:resetGame()
		playerServing = false
	end
	
	function self:throw()
		self:setImage(playerThrow)
		playdate.timer.performAfterDelay(300, function()
			self:setImage(playerStand)
		end)
	end
	
	function self:serve()
		self:setImage(playerServe)
	end
	
	function self:swing()
		self:setImage(playerSwing)
		playdate.timer.performAfterDelay(100, function()
			self:setImage(playerStand)
		end)
	end
	
	function self:smashWindUp()
		self:setImage(playerSmash)
	end
	
	function self:smashWinding()
		self.playerSmashPower += 1
	end
	
	return self
end