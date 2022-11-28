import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "player"
-- import "coworker"
import "story"

player = Player:new()
-- coworker = Coworker:new()
story = Story:new()

local debug = false

local gfx <const> = playdate.graphics
local font = gfx.font.new('font/Nano Sans 2X/Nano Sans 2X')
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
local backgroundOffice = gfx.image.new("images/bg-office-1")

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
local gaugeMax = 4
local gaugeLevel = 0

local function resetTimer()
	playTimer = playdate.timer.new(1000000, 0, 1000000, playdate.easingFunctions.linear)
end

local function resetSprites()
	player:moveTo(50, 170)
	coworkerSprite:moveTo(350, 170)
	tableSprite:moveTo(200, 190)
	ballSprite:moveTo(420, 300)
end

local function renderSpinMeter()
	gfx.setColor(gfx.kColorBlack)
	gaugeLevel = math.floor(ballSpin / 10)
	if math.abs(gaugeLevel) >= gaugeMax then
		gaugeLevel = gaugeMax
	end
	
	gfx.sprite.setBackgroundDrawingCallback(function()
		if ballSpin > 0 then
			for i=0, gaugeLevel - 1 do
				local xValue = 212 + (i * 12)
				gfx.fillRect(xValue, 220, 10, 10)
			end
		elseif ballSpin < 0 then
			for i=0, math.abs(gaugeLevel) - 1 do
				local xValue = 177 - (i * 12)
				gfx.fillRect(xValue, 220, 10, 10)
			end
		end
	end)
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
	timeSpeed = 3
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

local function calculateSpin(paddleLocation, person)
	if person == 'player' then
		gfx.drawLine(player.x+30,player.y-30,player.x + 70, player.y-30)
		gfx.drawLine(player.x+30,player.y+20,player.x + 70, player.y+20)
	elseif person =='coworker' then
		gfx.drawLine(coworkerSprite.x-30,coworkerSprite.y-30,coworkerSprite.x-70, coworkerSprite.y-30)
		gfx.drawLine(coworkerSprite.x-30,coworkerSprite.y+20,coworkerSprite.x-70, coworkerSprite.y+20)
	end
	
	if paddleLocation < ballSprite.y then
		local addSpin = ballSprite.y - paddleLocation
		ballSpin -= addSpin
		-- hit spin indicator
		if person == 'player' then
			gfx.drawText("SPIN -", player.x+30, player.y+35)
		elseif person == 'coworker' then
			gfx.drawText("SPIN -", coworkerSprite.x-30, coworkerSprite.y+35)
		end
	elseif paddleLocation > ballSprite.y then
		local addSpin = paddleLocation - ballSprite.y
		ballSpin += addSpin
		-- hit spin indicator
		if person == 'player' then
			gfx.drawText("SPIN +", player.x+30, player.y-45)
		elseif person == 'coworker' then
			gfx.drawText("SPIN +", coworkerSprite.x-30, coworkerSprite.y-45)
		end
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
	playHitSound()
	coworkerSprite:setImage(coworkerSwing, playdate.graphics.kImageFlippedX)
	playdate.timer.performAfterDelay(100, function()
		coworkerSprite:setImage(coworkerStand, playdate.graphics.kImageFlippedX)
	end)
	
	local paddleLocation = coworkerSprite.y - 10
	calculateSpin(paddleLocation, 'coworker')
	
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
	calculateSpin(paddleLocation, 'player')
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
	
	-- swing spin indicator
	-- gfx.drawLine(player.x+30,player.y-30,player.x + 70, player.y-30)
	-- gfx.drawLine(player.x+30,player.y+20,player.x + 70, player.y+20)
	
	if ballSprite.x < 100 then
		local paddleLocation = player.y - 10
		if paddleLocation < ballSprite.y + 30 and paddleLocation > ballSprite.y - 30 and ballLastTouched ~= "player" then
			hit(paddleLocation)
		end
	end
end

local function updateScore(who, howMuch)
	score[who] += howMuch
	if score[who] == maxScore then
		gameState = "end"
	end
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
				updateScore(2,1)
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
		
		-- ball hits ceiling
		if ballSprite.y < 0 then
			ballUpForce = (ballUpForce - 30) * ballBounceMultiplier
		end
		
		-- ball off the screen
		if ballSprite.x > 400 or ballSprite.x < 0 or ballSprite.y > 240 then
			if ballLastTouched == "player" then
				print("player touched last, coworker +1 point")
				updateScore(2, 1)
			elseif ballLastTouched == "coworker" then
				print("coworker touched last, player +1 point")
				updateScore(1, 1)
			elseif ballLastTouched == ("table" or "none") then
				if ballSprite.x < 200 then
					print("last touched none/table, LEFT side of screen, coworker +1 point")
					updateScore(2, 1)
				else
					print("last touched none/table, RIGHT side of screen, coworker +1 point")
					updateScore(1, 1)
				end
			end
			resetPoint()
			resetSprites()
		end
		
		-- move ball
		local verticalSpeed = gravity - ballUpForce
		ballSprite:moveBy(ballSpeed, verticalSpeed)	
		
		-- use gravity to reduce the ballUpForce
		if ballUpForce > 5 then
			ballUpForce = ballUpForce - 5
		end
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
				backgroundOffice:draw(0, 0)
			end
			
			gfx.clearClipRect()
		end
	)
end

local function renderUI()

	gfx.drawText("SHITTER HQ", 150, 6)

	-- scoreboard
	gfx.drawText(score[1], 55, 220)
	gfx.drawText(score[2], 340, 220)
	
	-- point indicator
	if showMessage then
		gfx.drawText("POINT!", 200, 130)
		playdate.timer.performAfterDelay(2000, function()
			showMessage = false
		end)
	end
	
	-- smash power meter
	if player.playerSmashPower > 0 then
		gfx.drawText(player.playerSmashPower, 100, 100)
	end
	
	-- spin gauge
	gfx.drawRect(139, 218, 50, 14)
	gfx.drawRect(210, 218, 50, 14)
	gfx.drawText(math.floor(ballSpin), 192, 205)
	
	if gaugeLevel >= gaugeMax then
		gfx.drawText("C SMASH!", 300, 100)
	elseif gaugeLevel <= -gaugeMax then
		gfx.drawText("P SMASH!", 100, 100)
	end
	
	-- debug info
	if debug then
		gfx.drawText("time: " .. seconds .. " BSpeed: " .. ballSpeed .. "  BUpForce: " .. ballUpForce .. "  BBounceHeight: " .. ballBounceHeight, 5, 5)	
		gfx.drawText("ball.x" .. ballSprite.x .. " ball.y" .. ballSprite.y .. " paddle.y" .. paddleLocation, 5, 30)
	end
end

function playdate.update()
	gfx.setFont(font)
	
	if gameState == "play" then
		
		-- Update screen
		playdate.timer.updateTimers()
		gfx.sprite.update()
		renderUI()
		
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
				player:smashWindUp()
			end
		end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			if ballMoving then
				player:smashWinding()
			end
		end
		if playdate.buttonJustReleased(playdate.kButtonB) then
			if ballMoving then
				swing()
				player:resetPoint()
			end
		end
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			if player.y > 75 then 
				player:moveBy(0, -playerSpeed)
				if playerServing then
					ballSprite:moveBy(0, -playerSpeed)
				end
				if debug then
					gfx.drawLine(0, player.y, 400, player.y)
				end
			end
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			if player.y < 190 then 
				player:moveBy(0, playerSpeed)
				if playerServing then
					ballSprite:moveBy(0, playerSpeed)
				end
				if debug then
					gfx.drawLine(0, player.y, 400, player.y)
				end
			end
		end
		
		-- Coworker ai
		if ballMoving then
			coworkerSprite:moveTo(coworkerSprite.x, ballSprite.y)
		end
		
		-- Time
		if time % timeSpeed == 0 then
			moveBall()
		end
		if time % 30 == 0 then
			seconds += 1
		end
		time += 1
	
		
		
	elseif gameState == "title" then
		story:titleScreen()
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "howto"
		end
	elseif gameState == "howto" then
		resetScreen()
		story:howToPlay()
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
		story:endScreen(score, maxScore)
		if playdate.buttonJustPressed(playdate.kButtonA) then
			gameState = "title"
			gfx.sprite.removeAll()
			gfx.sprite.update()
		end
	end
end
