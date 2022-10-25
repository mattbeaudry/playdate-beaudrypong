import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local playerSprite = nil
local player2Sprite = nil
local tableSprite = nil
local ballSprite = nil
local playerStand = gfx.image.new("images/player-stand")
local playerSwing = gfx.image.new("images/player-swing")
local playerServe = gfx.image.new("images/player-serve")
local playerThrow = gfx.image.new("images/player-throw")
local ball = gfx.image.new("images/ball-outline-2")
local table = gfx.image.new("images/table")
local backgroundImage = gfx.image.new("images/background")

local ballSpeed = 0
local ballMoving = false
local ballUpForce = 0
local ballBounceHeight = 0
local playerSpeed = 5
local playerServing = false
local time = 0
local seconds = 0
local score = 0
local gravity = 20

local function resetTimer()
	playTimer = playdate.timer.new(1000000, 0, 1000000, playdate.easingFunctions.linear)
end

local function resetGame()
	playerSprite:setImage(playerStand)
	player2Sprite:setImage(playerStand, playdate.graphics.kImageFlippedX)
	playerSprite:moveTo(60, 120)
	player2Sprite:moveTo(340, 120)
	tableSprite:moveTo(200, 130)
	ballSprite:moveTo(400, 240)
	
	ballSpeed = 0
	ballMoving = false
	ballUpForce = 0
	ballBounceHeight = 0
	playerSpeed = 5
	playerServing = false
	time = 0
	seconds = 0
	score = 0
	gravity = 20
end

local function moveBall()
	-- move the ball
	if ballMoving then
		
		-- ball hits player2
		if ballSprite.x > 300 then
			print("ball hits player 2")
			-- AI of player 2 decides what to do
			player2Sprite:setImage(playerSwing, playdate.graphics.kImageFlippedX)
			playdate.timer.performAfterDelay(100, function()
				player2Sprite:setImage(playerStand, playdate.graphics.kImageFlippedX)
			end)
			ballSpeed = -ballSpeed
			
		-- ball hits player1
		elseif ballSprite.x < 100  then
			ballSpeed = -ballSpeed
		end
		
		-- ball hits table
		if ballSprite.y > 120 then
			ballUpForce = ballUpForce + 30
		end
		local verticalSpeed = gravity - ballUpForce
		ballSprite:moveBy(ballSpeed, verticalSpeed)	
	end
	
	-- use gravity to reduce the ballUpForce
	if ballUpForce > 5 then
		ballUpForce = ballUpForce - 5
	end
	
	-- if ball off the screen reset game
	if ballSprite.x > 400 or ballSprite.x < 0 or ballSprite.y > 240 or ballSprite.y < 0 then
		resetGame()
	end
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	
	-- sprites
	playerSprite = gfx.sprite.new(playerStand)
	playerSprite:moveTo(60, 120)
	playerSprite:setCollideRect(0, 0, playerSprite:getSize())
	playerSprite:add()
	
	player2Sprite = gfx.sprite.new()
	player2Sprite:setImage(playerStand, playdate.graphics.kImageFlippedX)
	player2Sprite:moveTo(340, 120)
	player2Sprite:setCollideRect(0, 0, playerSprite:getSize())
	player2Sprite:add()
	
	tableSprite = gfx.sprite.new(table)
	tableSprite:moveTo(200, 130)
	tableSprite:setCollideRect(0, 0, tableSprite:getSize())
	tableSprite:add()
	
	ballSprite = gfx.sprite.new(ball)
	ballSprite:moveTo(400, 240)
	ballSprite:setCollideRect(0, 0, ballSprite:getSize())
	ballSprite:add()
	
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0, 0)
			gfx.clearClipRect()
		end
	)

	resetTimer()
end

initialize()

function playdate.update()
	
	-- A Button
	if playdate.buttonJustPressed(playdate.kButtonA) then
		playerSprite:setImage(playerSwing)
		-- if they hit the ball increase ballSpeed and ballUpForce
		ballUpForce += 20 
		ballSpeed += 20
		playdate.timer.performAfterDelay(100, function()
			playerSprite:setImage(playerStand)
		end)
	end
	
	-- B Button
	if playdate.buttonJustPressed(playdate.kButtonB) then
		if playerServing == true then
			playerSprite:setImage(playerThrow)
			ballSprite:moveTo(100, 70)
			ballSpeed = 0
			ballMoving = true
			playdate.timer.performAfterDelay(300, function()
				playerSprite:setImage(playerStand)
				playerServing = false
			end)
		end
		if playerServing == false then
			ballSprite:moveTo(98, 102)
			playerSprite:setImage(playerServe)
			playerServing = true
		end
	end
	
	-- Up
	if playdate.buttonIsPressed(playdate.kButtonUp) then
		playerSprite:moveBy(0, -playerSpeed)
	end
	
	-- Down
	if playdate.buttonIsPressed(playdate.kButtonDown) then
		playerSprite:moveBy(0, playerSpeed)
	end
	
	-- do every half second
	if time % 10 == 0 then
		moveBall()
	end
	
	-- do every second
	if time % 30 == 0 then
		seconds = seconds + 1
	end
	
	-- update the screen
	playdate.timer.updateTimers()
	gfx.sprite.update()
	gfx.drawText("time: " .. seconds .. " BSpeed: " .. ballSpeed .. "  BUpForce: " .. ballUpForce .. "  BBounceHeight: " .. ballBounceHeight, 5, 5)	
	gfx.drawText("ball.x" .. ballSprite.x .. "ball.y" .. ballSprite.y, 5, 30)
	time = time + 1
end