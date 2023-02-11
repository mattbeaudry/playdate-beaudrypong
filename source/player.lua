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
	
	local function randomAngle()
	  return math.random() * 2 * math.pi
	end
	
	local function randomPointOnCircle(radius, center_x, center_y)
	  local angle = randomAngle()
	  local x = radius * math.cos(angle) + center_x
	  local y = radius * math.sin(angle) + center_y
	  return x, y
	end
	
	function self:smashWinding()
		self.playerSmashPower += 1
		local rRadius = math.random(0, 30)
		local paddleX = self.x - 35
		local paddleY = self.y - 35
		local x, y = randomPointOnCircle(rRadius, paddleX, paddleY)
		gfx.drawLine(paddleX, paddleY, x, y)
	end
	
	return self
end