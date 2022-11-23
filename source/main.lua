import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import 'player'
import 'coworker'
import 'story'

player = Player:new()
-- coworker = Coworker:new()
story = Story:new()

local debug = false

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local coworkerSprite = nil
local tableSprite = nil
local ballSprite = nil
local ballSprite = nil
local line = nil
local coworkerStand = gfx.image.new("images/coworker-stand")
local coworkerSwing = gfx.image.new("images/coworker-swing")
local coworkerServe = gfx.image.new("images/coworker-serve")
local coworkerThrow = gfx.image.new("images/coworker-throw")
local coworkerSmash = gfx.image.new("images/coworker-smash")
local ball = gfx.image.new("images/ball-outline")
local table = gfx.image.new("images/table")
local backgroundOffice = gfx.image.new("images/background-office")
local backgroundDepartments = gfx.image.new("images/background-departments-edge")

local gameState = "title"
local tableEdgeLeft = 100
local tableEdgeRight = 300
local tableEdgeTop = 170
local floorEdge = 220
local ballSpeed = 0
local ballMoving = false
local ballUpForce = 0
local hitUpForce = 22
local ballBounceHeight = 0
local ballBounceMultiplier = 1
local ballSpeedMultiplier = 1
local ballSpin = 0
local ballLastTouched = "none"
local playerSpeed = 5
local playerServing = false
local paddleLocation = 0
local time = 0
local timeSpeed = nil
local seconds = 0
local score = {0, 0}
local maxScore = 3
local gravity = 20
local showMessage = false
local guageMax = 7
local gaugeLevel = 0

local function resetTimer()
	playTimer = playdate.timer.new(1000000, 0, 1000000, playdate.easingFunctions.linear)
end

local function resetSprites()
	player:move(50, 170)
	coworkerSprite:moveTo(350, 170)
	tableSprite:moveTo(200, 190)
	ballSprite:moveTo(420, 300)
end

local function renderSpinMeter()
	gfx.setColor(gfx.kColorBlack)
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gaugeLevel = math.floor(ballSpin / 10)
			guageLevel = gaugeLevel > guageMax and guageMax or gaugeLevel
			if ballSpin > 0 then
				for i=0, gaugeLevel - 1 do
					local xValue = 202 + (i * 12)
					gfx.fillRect(xValue, 200, 10, 10)
				end
			elseif ballSpin < 0 then
				for i=0, math.abs(guageLevel) - 1 do
					local xValue = 177 - (i * 12)
					gfx.fillRect(xValue, 200, 10, 10)
				end
			end
		end
	)
end

local function resetPoint()
	ballSpeed = 0
	ballMoving = false
	ballUpForce = 0
	ballBounceHeight = 0
	ballBounceMultiplier = 1
	ballSpeedMultiplier = 1
	ballSpin = 0
	ballLastTouched = "none"
	gaugeLevel = 0
	timeSpeed = 4
	playerSmashPower = 0
	player:resetPoint()
	renderSpinMeter()
end

local function resetGame()
	player:resetGame()
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
	if paddleLocation < ballSprite.y then
		local addSpin = ballSprite.y - paddleLocation
		ballSpin -= addSpin
	elseif paddleLocation > ballSprite.y then
		local addSpin = paddleLocation - ballSprite.y
		ballSpin += addSpin
	else
		--print("**** PERFECT ACCURACY SHOT -- Do something special? ****")
	end
	renderSpinMeter()
end

local function playHitSound()
	local synth = snd.synth.new(snd.kWaveSawtooth)
	synth:setDecay(0.1)
	synth:setSustain(0)
	synth:playNote(220)
end

local function coworkerHits()
	--print("coworker hits ball")
	playHitSound()
	coworkerSprite:setImage(coworkerSwing, playdate.graphics.kImageFlippedX)
	playdate.timer.performAfterDelay(100, function()
		coworkerSprite:setImage(coworkerStand, playdate.graphics.kImageFlippedX)
	end)
	
	local paddleLocation = coworkerSprite.y - 10
	calculateSpin(paddleLocation)
	
	ballSpeed -= 40 * ballSpeedMultiplier
	ballUpForce += hitUpForce
	ballBounceMultiplier = 1
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "ai"
end

local function coworkerSwings()
	math.randomseed(playdate.getSecondsSinceEpoch())
	local r = math.random(1, 20)
	if r == 1 then
		score[1] += 1
		if score[1] == maxScore then
			gameState = "end"
		end
		showMessage = true
		resetPoint()
		resetSprites()
	else
		coworkerHits()
	end
end

local function serve()
	if playerServing == true then
		local throwBall = ballSprite.y - 30
		ballSprite:moveTo(98, throwBall)
		ballUpForce += 15
		ballSpeed = 0
		ballMoving = true
		playerServing = false
		player:throw()
	else
		ballSprite:moveTo(player.x + 38, player.y - 20)
		player:serve()
		playerServing = true
	end
end

local function hit(paddleLocation)
	playHitSound()
	calculateSpin(paddleLocation)
	
	ballUpForce += hitUpForce
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "player"
	if ballSpeed == 0 then
		ballSpeed += 20
	else 
		ballSpeed += 40 * ballSpeedMultiplier
	end
end

local function swing()
	player:swing()
	
	if ballSprite.x < 100 then
		local paddleLocation = player.y - 10
		if paddleLocation < ballSprite.y + 30 and paddleLocation > ballSprite.y - 30 and ballLastTouched ~= "player" then
			hit(paddleLocation)
		end
	end
end

local function windup()
	-- crankTicks = playdate.getCrankTicks(30)
	crankChange = playdate.getCrankChange()
	playerSmashPower += crankChange
	print(playerSmashPower)
end

local function moveBall()
	if ballMoving then
		if ballSprite.x > tableEdgeLeft and ballSprite.x < tableEdgeRight then
			if ballSprite.y > tableEdgeTop and ballLastTouched ~= "table" then
				-- ball hits table
				playHitSound()
				ballUpForce = (ballUpForce + 30) * ballBounceMultiplier
				ballBounceMultiplier *= 0.8
				ballLastTouched = "table"
				playdate.timer.performAfterDelay(300, function()
					ballLastTouched = "none"
				end)
				
			end
		else
			if ballSprite.x > 300 then
				--ball hits coworker
				coworkerSwings()
			elseif ballSprite.x < 75 then
				--ball hits player
				score[2] += 1
				if score[2] == maxScore then
					gameState = "end"
				end
				showMessage = true
				resetPoint()
				resetSprites()
			end
		end
		
		-- ball hits floor
		if ballSprite.y > floorEdge then
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

	coworkerSprite = gfx.sprite.new()
	coworkerSprite:setImage(coworkerStand, playdate.graphics.kImageFlippedX)
	tableSprite = gfx.sprite.new(table)
	ballSprite = gfx.sprite.new(ball)
	
	player:add()
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

local function renderUI()
	gfx.drawText(score[1], 55, 220)
	gfx.drawText(score[2], 340, 220)
	gfx.drawText("SPIN " .. math.floor(ballSpin), 160, 220)
	
	if debug == false then
		gfx.drawText("SHITTER HQ", 150, 50)
	end
		
	-- On-screen messages
	if showMessage then
		gfx.drawText("POINT!", 200, 130)
		playdate.timer.performAfterDelay(2000, function()
			showMessage = false
		end)
	end
	
	-- Debug INFO
	if debug then
		gfx.drawText("time: " .. seconds .. " BSpeed: " .. ballSpeed .. "  BUpForce: " .. ballUpForce .. "  BBounceHeight: " .. ballBounceHeight, 5, 5)	
		gfx.drawText("ball.x" .. ballSprite.x .. " ball.y" .. ballSprite.y .. " paddle.y" .. paddleLocation, 5, 30)
	end
end

function playdate.update()
	if gameState == "play" then
		
		-- Controls
		if playdate.buttonJustPressed(playdate.kButtonA) then
			if ballMoving then
				swing()
			else
				serve()
			end
		end
		if playdate.buttonJustPressed(playdate.kButtonB) then
			if ballMoving then
				-- playerSprite:setImage(playerSmash)
			end
		end
		if playdate.buttonJustReleased(playdate.kButtonB) then
			if ballMoving then
				swing()
			end
		end
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			player:move(0, -playerSpeed)
			
			if debug then
				gfx.drawLine(0, player.y, 400, player.y)
			end
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			player:move(0, playerSpeed)
			gfx.drawLine(0, player.y, 400, player.y)
		end
		
		-- Coworker ai
		if ballMoving then
			coworkerSprite:moveTo(coworkerSprite.x, ballSprite.y)
		end
		
		-- Time
		if time % timeSpeed == 0 then
			moveBall()
			if playdate.buttonIsPressed(playdate.kButtonB) then
				--if ballMoving then
					windup()
				--end
			end
		end
		if time % 30 == 0 then
			seconds += 1
		end
		time += 1
		
		-- if playerServing then
		-- 	ballSprite:moveTo(98, playerSprite.y - 20)
		-- end
		
		local paddleLocation = player.y - 10
	
		-- Update screen
		playdate.timer.updateTimers()
		gfx.sprite.update()
		
		-- if playdate.buttonJustPressed(playdate.kButtonB) then
		-- 	print("SMASH")
		-- 	gfx.drawText("CRANK SMASH!!", 20, 20)
		-- end
		
		renderUI()
		
	elseif gameState == "title" then
		story:titleScreen()
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "mission"
		end
	elseif gameState == "mission" then
		resetScreen()
		story:missionScreen()
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "play"
			initialize()
		end
	elseif gameState == "end" then
		gfx.sprite.removeAll()
		gfx.sprite.update()
		resetScreen()
		story:endScreen()
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "title"
			gfx.sprite.removeAll()
			gfx.sprite.update()
		end
	end
end
