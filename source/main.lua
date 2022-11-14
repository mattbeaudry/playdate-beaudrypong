import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local debug = false

-- TODO
-- split into multiple files/classes
-- add title screen and game start / game over logic
-- track timing of player swing to calculate spin factor + or -
-- ... or use vertical alignment instead, you gotta get above or below the ball to counter spin
-- what if the players and table are a smily face of the playdate itself, optical illusion
-- ... and the secret is to undock the crank to bring character alive
-- Smash type swing that requires a pause and using the crank to do a smash
-- how can i implement strength factor to the player and ai swings
-- ball should go into AI or player hand depending on who won last show

local gfx <const> = playdate.graphics
local playerSprite = nil
local player2Sprite = nil
local tableSprite = nil
local ballSprite = nil
local ballSprite = nil
local line = nil
local playerStand = gfx.image.new("images/player-stand-2")
local playerSwing = gfx.image.new("images/player-swing-2")
local playerServe = gfx.image.new("images/player-serve-2")
local playerThrow = gfx.image.new("images/player-throw-2")
local playerCanSmash = false
local aiCanSmash = false
local aiStand = gfx.image.new("images/ai-stand")
local aiSwing = gfx.image.new("images/ai-swing")
local aiServe = gfx.image.new("images/ai-serve")
local aiThrow = gfx.image.new("images/ai-throw")
local ball = gfx.image.new("images/ball-outline")
local table = gfx.image.new("images/table")
local backgroundBorder = gfx.image.new("images/background")
local backgroundOffice = gfx.image.new("images/background-office")

local gameState = "title" -- [title, play, end]
local tableEdgeLeft = 110
local tableEdgeRight = 290
local tableEdgeTop = 140
local floorEdge = 190
local ballSpeed = 0
local ballMoving = false
local ballUpForce = 0
local ballBounceHeight = 0
local ballBounceMultiplier = 1
local ballSpeedMultiplier = 1
local ballSpin = 0
local ballLastTouched = "none"
local playerSpeed = 5
local playerServing = false
local time = 0
local timeSpeed = 5
local seconds = 0
local score = {0, 0}
local maxScore = 3
local gravity = 20
local showMessage = false

local function resetTimer()
	playTimer = playdate.timer.new(1000000, 0, 1000000, playdate.easingFunctions.linear)
end

local function resetPoint()
	-- Global variables
	ballSpeed = 0
	ballMoving = false
	ballUpForce = 0
	ballBounceHeight = 0
	ballBounceMultiplier = 1
	ballSpeedMultiplier = 1
	ballSpin = 0
	ballLastTouched = "none"
	
	-- Sprites
	playerSprite:moveTo(55, 120)
	player2Sprite:moveTo(345, 120)
	tableSprite:moveTo(200, 160)
	ballSprite:moveTo(420, 300)
end

local function resetGame()
	playerServing = false
	time = 0
	seconds = 0
	score = {0, 0}
end

local function moveBall()
	if ballMoving then

		-- ball hits table
		if ballSprite.x > tableEdgeLeft and ballSprite.x < tableEdgeRight then

			if ballSprite.y > tableEdgeTop then
				print("ball hits table");
				
				ballUpForce = (ballUpForce + 30) * ballBounceMultiplier
				ballBounceMultiplier *= 0.8
			end
		else

			if ballSprite.x > 300 then
				print("ball hits AI")

				math.randomseed(playdate.getSecondsSinceEpoch())
				local r = math.random(1, 10)

				if r == 1 then
					print("AI misses ball")

					score[1] += 1
					if score[1] == maxScore then
						gameState = "end"
					end
					showMessage = true
					resetPoint()

				else
					print("AI hits ball")

					player2Sprite:setImage(aiSwing, playdate.graphics.kImageFlippedX)
					playdate.timer.performAfterDelay(100, function()
						player2Sprite:setImage(aiStand, playdate.graphics.kImageFlippedX)
					end)
					ballSpeed -= 40 * ballSpeedMultiplier
					ballUpForce += 20
					ballBounceMultiplier = 1
					ballSpeedMultiplier *= 1.001
					ballLastTouched = "ai"

				end
				
			elseif ballSprite.x < 75 then
				print("ball hits player")
				
				score[2] += 1
				if score[2] == maxScore then
					gameState = "end"
				end
				showMessage = true
				resetPoint()
			end
		end
		
		if ballSprite.y > floorEdge then
			print("ball hits floor")
			
			ballUpForce = (ballUpForce + 30) * ballBounceMultiplier
			ballBounceMultiplier *= 0.8
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
		-- resetGame()
	end
end

local function playerSwings()
	print("player swings")
	
	playerSprite:setImage(playerSwing)
	playdate.timer.performAfterDelay(100, function()
		playerSprite:setImage(playerStand)
	end)
	
	-- if ball is near player
	if ballSprite.x < 150 then
		print("ball near player")
		
		local paddleLocation = playerSprite.y - 10
		if paddleLocation < ballSprite.y + 30 and paddleLocation > ballSprite.y - 30 then
		-- if paddleLocation < ballSprite.y + 30 and paddleLocation > ballSprite.y - 30 and ballLastTouched ~= "player" then
			print("player vertically aligned to ball, a HIT!")
			
			-- calculate spin
			if paddleLocation < ballSprite.y then
				local addSpin = ballSprite.y - paddleLocation
				ballSpin -= addSpin
				print("swing above ball, add "..addSpin.." top spin")
			elseif paddleLocation < ballSprite.y then
				local addSpin = paddleLocation - ballSprite.y
				ballSpin += addSpin
				print("swing below ball, add "..addSpin.."bottom spin")
			else
				print("**** PERFECT ACCURACY ****")
				
			end
			
			ballUpForce += 20
			ballSpeedMultiplier *= 1.001
			ballLastTouched = "player"
			if ballSpeed == 0 then
				ballSpeed += 20
			else 
				ballSpeed += 40 * ballSpeedMultiplier
			end
		else
			print("player not vertically aligned to ball, a MISS!")
		end
	end
end

local function playerServes()
	if playerServing == true then
		print("player serves")
		playerSprite:setImage(playerThrow)
		local throwBall = ballSprite.y - 30
		print(throwBall)
		playerServing = false
		ballSprite:moveTo(98, throwBall)
		ballUpForce += 15
		ballSpeed = 0
		ballMoving = true
		playdate.timer.performAfterDelay(300, function()
			playerSprite:setImage(playerStand)
		end)
	else
		print("player serving")
		ballSprite:moveTo(98, playerSprite.y)
		playerSprite:setImage(playerServe)
		playerServing = true
	end
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())

	playerSprite = gfx.sprite.new(playerStand)
	player2Sprite = gfx.sprite.new()
	player2Sprite:setImage(aiStand, playdate.graphics.kImageFlippedX)
	tableSprite = gfx.sprite.new(table)
	ballSprite = gfx.sprite.new(ball)
	
	playerSprite:add()
	player2Sprite:add()
	tableSprite:add()
	ballSprite:add()
	
	resetGame()
	resetPoint()
	resetTimer()
	
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundBorder:draw(0, 0)
			backgroundOffice:draw(0, 0)
			
			if debug then
				gfx.drawLine(0, tableEdgeTop, 400, tableEdgeTop)
				gfx.drawLine(tableEdgeLeft, 0, tableEdgeLeft, 240)
				gfx.drawLine(tableEdgeRight, 0, tableEdgeRight, 240)
				gfx.drawLine(0, floorEdge, 400, floorEdge)
			end
			
			gfx.clearClipRect()
		end
	)
end

initialize()

function playdate.update()
	if gameState == "title" then
		gfx.drawText("SHITTY PING PONG", 120, 40)
		gfx.drawText("press A to serve and swing", 20, 100)
		gfx.drawText("press UP and DOWN to move", 20, 120)
		gfx.drawText("hold B to charge.. release and CRANK to SMASH", 20, 140)
		gfx.drawText("press A to start", 120, 200)
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "play"
		end
	elseif gameState == "end" then
		gfx.sprite.removeAll()
		gfx.sprite.update()
		gfx.drawText("Game Over", 150, 60)
		gfx.drawText("press A to rematch", 20, 100)
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "title"
			gfx.sprite.removeAll()
			gfx.sprite.update()
			initialize()
			
		end
	elseif gameState == "play" then
		-- Controls
		if playdate.buttonJustPressed(playdate.kButtonA) then
			if ballMoving then
				playerSwings()
			else
				playerServes()
			end
		end
		
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			playerSprite:moveBy(0, -playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			playerSprite:moveBy(0, playerSpeed)
		end
		
		-- Time
		if time % timeSpeed == 0 then
			moveBall()
		end
		if time % 30 == 0 then
			seconds += 1
		end
		time += 1
		
		if playerServing then
			ballSprite:moveTo(98, playerSprite.y - 20)
		end
		
		local paddleLocation = playerSprite.y - 10
		
		-- Update screen
		playdate.timer.updateTimers()
		gfx.sprite.update()
		
		-- if playdate.buttonJustPressed(playdate.kButtonB) then
		-- 	print("SMASH")
		-- 	gfx.drawText("CRANK SMASH!!", 20, 20)
		-- end
		
		-- UI
		gfx.drawText(score[1], 55, 180)
		gfx.drawText(score[2], 340, 180)
		gfx.drawText("SPIN " .. ballSpin, 160, 180)
		
		if playerCanSmash then
			gfx.drawText("SMASH", 100, 180)
		elseif aiCanSmash then
			gfx.drawText("SMASH", 300, 180)
		end
		
		if debug == false then
			gfx.drawText("SHITTY PING-PONG", 380, 20)
		end
			
		-- On-screen messages
		if showMessage then
			gfx.drawText("POINT!", 200, 170)
			playdate.timer.performAfterDelay(1000, function()
				showMessage = false
			end)
		end
		
		-- Debug UI
		if debug then
			gfx.drawText("time: " .. seconds .. " BSpeed: " .. ballSpeed .. "  BUpForce: " .. ballUpForce .. "  BBounceHeight: " .. ballBounceHeight, 5, 5)	
			gfx.drawText("ball.x" .. ballSprite.x .. " ball.y" .. ballSprite.y .. " paddle.y" .. paddleLocation, 5, 30)
		end
	end
end