import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local debug = false

-- TODO
-- split into multiple files/classes
-- gameState object?
-- calculate spin factor + or - (top or bottom spin) 
-- what if the players and table are a smily face of the playdate itself, optical illusion
-- Smash type swing that requires a pause and using the crank to do a smash
-- ball should go into AI or player hand depending on who won last show
-- coworker movement and serve functionality
-- make sure correct player gets point, whoHitLast() and must bounce on table
-- make it time sensitive where you can only play one game and have to play next game the net day or week

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local playerSprite = nil
local coworkerSprite = nil
local tableSprite = nil
local ballSprite = nil
local ballSprite = nil
local line = nil
local playerStand = gfx.image.new("images/player-stand-2")
local playerSwing = gfx.image.new("images/player-swing-2")
local playerServe = gfx.image.new("images/player-serve-2")
local playerThrow = gfx.image.new("images/player-throw-2")
local coworkerStand = gfx.image.new("images/coworker-stand")
local coworkerSwing = gfx.image.new("images/coworker-swing")
local coworkerServe = gfx.image.new("images/coworker-serve")
local coworkerThrow = gfx.image.new("images/coworker-throw")
local ball = gfx.image.new("images/ball-outline")
local table = gfx.image.new("images/table")
local backgroundOffice = gfx.image.new("images/background-office")
local backgroundDepartments = gfx.image.new("images/background-departments-edge")

local gameState = "title"
local tableEdgeLeft = 110
local tableEdgeRight = 290
local tableEdgeTop = 170
local floorEdge = 220
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
local timeSpeed = 4
local seconds = 0
local score = {0, 0}
local maxScore = 3
local gravity = 20
local showMessage = false

local function resetTimer()
	playTimer = playdate.timer.new(1000000, 0, 1000000, playdate.easingFunctions.linear)
end

local function resetSprites()
	playerSprite:moveTo(50, 170)
	coworkerSprite:moveTo(350, 170)
	tableSprite:moveTo(200, 190)
	ballSprite:moveTo(420, 300)
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
end

local function resetGame()
	playerServing = false
	time = 0
	seconds = 0
	score = {0, 0}
end

local function resetScreen() 
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 400, 240)
end

local function calculateSpin(paddleLocation)
	print("calclate spin")
	print("paddleLocation" .. paddleLocation)
	print("ballSprite.y" .. ballSprite.y)
	if paddleLocation < ballSprite.y then
		local addSpin = ballSprite.y - paddleLocation
		ballSpin -= addSpin
		print("swing ABOVE ball, spin "..addSpin.." LEFT ")
	elseif paddleLocation > ballSprite.y then
		local addSpin = paddleLocation - ballSprite.y
		ballSpin += addSpin
		print("swing BELOW ball, spin "..addSpin.." RIGHT")
	else
		print("**** PERFECT ACCURACY ****")
	end
	
end

local function playHitSound()
	-- sound test
	local synth = snd.synth.new(snd.kWaveSawtooth)
	synth:setDecay(0.1)
	synth:setSustain(0)
	synth:playNote(220)
end

local function renderSpinMeter(gaugeLevel, guageMax)
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			if ballSpin > 0 then
				--print("RIGHT spin")
				for i=0,gaugeLevel do
					local xValue = 202 + (i * 12)
					-- print("xValue"..xValue)
					gfx.fillRect(xValue, 200, 10, 10)
				end
			elseif ballSpin < 0 then
				--print("LEFT spin")
				for i=0,math.abs(gaugeLevel) do
					local xValue = 177 - (i * 12)
					gfx.fillRect(xValue, 200, 10, 10)
				end
			end
		end
	)
end

local function refreshSpinMeter()
	gfx.setColor(gfx.kColorBlack)
	
	local guageMax = 8
	local gaugeLevel = math.floor(ballSpin / 10)
	
	renderSpinMeter(gaugeLevel, guageMax)
end

local function playerHits(paddleLocation)
	print("player vertically aligned to ball, a HIT!")
	
	playHitSound()
	calculateSpin(paddleLocation)
	refreshSpinMeter()
	
	ballUpForce += 20
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "player"
	if ballSpeed == 0 then
		ballSpeed += 20
	else 
		ballSpeed += 40 * ballSpeedMultiplier
	end
end

local function playerSwings()
	print("  ")
	print("player swings")
	
	playerSprite:setImage(playerSwing)
	playdate.timer.performAfterDelay(100, function()
		playerSprite:setImage(playerStand)
	end)
	
	-- ball is near player
	if ballSprite.x < 150 then
		print("ball near player")
		
		local paddleLocation = playerSprite.y - 10
		if paddleLocation < ballSprite.y + 30 and paddleLocation > ballSprite.y - 30 then
		-- if paddleLocation < ballSprite.y + 30 and paddleLocation > ballSprite.y - 30 and ballLastTouched ~= "player" then
			playerHits(paddleLocation)
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
		ballSprite:moveTo(playerSprite.x + 38, playerSprite.y - 20)
		playerSprite:setImage(playerServe)
		playerServing = true
	end
end

local function coworkerHits()
	print("coworker hits ball")
	playHitSound()
	coworkerSprite:setImage(coworkerSwing, playdate.graphics.kImageFlippedX)
	playdate.timer.performAfterDelay(100, function()
		coworkerSprite:setImage(coworkerStand, playdate.graphics.kImageFlippedX)
	end)
	
	local paddleLocation = coworkerSprite.y - 10
	calculateSpin(paddleLocation)
	refreshSpinMeter()
	
	ballSpeed -= 40 * ballSpeedMultiplier
	ballUpForce += 20
	ballBounceMultiplier = 1
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "ai"
end

local function coworkerSwings()
	print("  ")
	print("coworker swings")
	
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
		resetSprites()
	
	else
		print("AI hits ball")
		coworkerHits()
	end
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
				coworkerSwings()
				
			elseif ballSprite.x < 75 then
				print("ball hits player")
				
				score[2] += 1
				if score[2] == maxScore then
					gameState = "end"
				end
				showMessage = true
				resetPoint()
				resetSprites()
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
	
	-- if ball off the screen reset point
	if ballSprite.x > 400 or ballSprite.x < 0 or ballSprite.y > 240 or ballSprite.y < 0 then
		-- todo: figure out who gets the point
		resetPoint()
		resetSprites()
	end
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())

	playerSprite = gfx.sprite.new(playerStand)
	coworkerSprite = gfx.sprite.new()
	coworkerSprite:setImage(coworkerStand, playdate.graphics.kImageFlippedX)
	tableSprite = gfx.sprite.new(table)
	ballSprite = gfx.sprite.new(ball)
	
	playerSprite:add()
	coworkerSprite:add()
	tableSprite:add()
	ballSprite:add()
	
	resetGame()
	resetPoint()
	resetSprites()
	resetTimer()
	
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			
			if debug then
				gfx.drawLine(0, tableEdgeTop, 400, tableEdgeTop)
				gfx.drawLine(tableEdgeLeft, 0, tableEdgeLeft, 240)
				gfx.drawLine(tableEdgeRight, 0, tableEdgeRight, 240)
				gfx.drawLine(0, floorEdge, 400, floorEdge)
			else
				backgroundDepartments:draw(0, 0)
			end
			
			gfx.clearClipRect()
		end
	)
end

local function titleScreen()
	gfx.drawText("SHITTY PING PONG", 120, 40)
	gfx.drawText("press A to serve and swing", 20, 100)
	gfx.drawText("press UP and DOWN to move", 20, 120)
	gfx.drawText("hold B to charge.. release and CRANK to SMASH", 20, 140)
	gfx.drawText("press A to start", 120, 200)
end

local function missionScreen()
	gfx.drawText("WELCOME TO SHITTY PING PONG", 120, 40)
	gfx.drawText("You work at Shitty Corp", 20, 100)
	gfx.drawText("You are the lead coder of Shitter", 20, 120)
	gfx.drawText("BOSS: The site is down, get back to work", 20, 140)
	gfx.drawText("--: Okay, but we are in the middle of a rally", 20, 160)
	gfx.drawText("press A to start", 120, 200)
end

local function endScreen()
	gfx.drawText("Game Over", 150, 60)
	gfx.drawText("Score: XXX      press A to restart", 20, 100)
end

function playdate.update()
	if gameState == "play" then
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
			refreshSpinMeter()
		end
		if time % 30 == 0 then
			seconds += 1
		end
		time += 1
		
		-- if playerServing then
		-- 	ballSprite:moveTo(98, playerSprite.y - 20)
		-- end
		
		local paddleLocation = playerSprite.y - 10
	
		-- Update screen
		playdate.timer.updateTimers()
		gfx.sprite.update()
		
		-- if playdate.buttonJustPressed(playdate.kButtonB) then
		-- 	print("SMASH")
		-- 	gfx.drawText("CRANK SMASH!!", 20, 20)
		-- end
		
		-- UI
		gfx.drawText(score[1], 55, 220)
		gfx.drawText(score[2], 340, 220)
		gfx.drawText("SPIN " .. ballSpin, 160, 220)
		
		if playerCanSmash then
			gfx.drawText("SMASH", 100, 220)
		elseif aiCanSmash then
			gfx.drawText("SMASH", 300, 220)
		end
		
		-- if debug == false then
		-- 	gfx.drawText("SHITTY PING-PONG", 380, 20)
		-- end
			
		-- On-screen messages
		if showMessage then
			gfx.drawText("POINT!", 200, 130)
			playdate.timer.performAfterDelay(1000, function()
				showMessage = false
			end)
		end
		
		-- Debug INFO
		if debug then
			gfx.drawText("time: " .. seconds .. " BSpeed: " .. ballSpeed .. "  BUpForce: " .. ballUpForce .. "  BBounceHeight: " .. ballBounceHeight, 5, 5)	
			gfx.drawText("ball.x" .. ballSprite.x .. " ball.y" .. ballSprite.y .. " paddle.y" .. paddleLocation, 5, 30)
		end
		
	elseif gameState == "title" then
		titleScreen()
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "mission"
		end
	elseif gameState == "mission" then
		resetScreen()
		missionScreen()
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "play"
			initialize()
		end
	elseif gameState == "end" then
		gfx.sprite.removeAll()
		gfx.sprite.update()
		resetScreen()
		endScreen()
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "title"
			gfx.sprite.removeAll()
			gfx.sprite.update()
		end
	end
end

-- local c_tbl =
-- {
--   [1] = add,
--   [2] = save,
-- }
-- 
-- local func = c_tbl[choice]
-- if(func) then
--   func()
-- else
--   print " The program has been terminated."
--   print " Thank you!";
-- end

