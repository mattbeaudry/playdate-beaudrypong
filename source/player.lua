import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Player = {}
Player.__index = Player

local playerStance = gfx.image.new("images/player-stance")
local playerSwing = gfx.image.new("images/player-swing")
local playerServe = gfx.image.new("images/player-serve")
local playerThrow = gfx.image.new("images/player-throw")
local playerSmash = gfx.image.new("images/player-smash")
local playerInjured = gfx.image.new("images/player-injured")

local maxSmashPower = 100

function Player:new()
	local self = gfx.sprite.new(playerStance)
	self.playerSmashPower = 5
	self.velocity = 0
	
	function self:stance()
		self:setImage(playerStance)
	end
	
	function self:injured()
		self:setImage(playerInjured)
	end
	
	function self:resetPoint()
		self.playerSmashPower = 0
	end
	
	function self:resetGame()
		playerServing = false
	end
	
	function self:throw()
		self:setImage(playerThrow)
		playdate.timer.performAfterDelay(300, function()
			self:setImage(playerStance)
		end)
	end
	
	function self:serve()
		self:setImage(playerServe)
	end
	
	function self:swing()
		self:setImage(playerSwing)
		playdate.timer.performAfterDelay(100, function()
			self:setImage(playerStance)
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