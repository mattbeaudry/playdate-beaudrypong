import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Player = {}
Player.__index = Player

local playerSprite = nil
local playerStand = gfx.image.new("images/player-stand-2")
local playerSwing = gfx.image.new("images/player-swing-2")
local playerServe = gfx.image.new("images/player-serve-2")
local playerThrow = gfx.image.new("images/player-throw-2")
local playerSmash = gfx.image.new("images/player-smash")

local playerSmashPower = 0
local maxSmashPower = 100

function Player:new()
	
	local self = gfx.sprite.new(playerStand)
	
	function self:resetPoint()
		playerSmashPower = 0
	end
	
	function self:resetGame()
		playerServing = false
	end
	
	function self:move(x,y)
		self:moveTo(x, y)
	end
	
	function self:move(x,y)
		self:moveTo(x, y)
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
	
	return self
end