import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "player"
import "coworker"
import "boss"
import "story"
import "desk"

local debug = false

local gfx <const> = playdate.graphics
local font = gfx.font.new('font/Nano Sans 2X/Nano Sans 2X')
local snd <const> = playdate.sound

local player = Player:new()
local coworker = Coworker:new()
local boss = Boss:new()
local story = Story:new()
local desks = {}

local tableSprite = nil
local ballSprite = nil
local line = nil
local ball = gfx.image.new("images/ball-outline")
local table = gfx.image.new("images/table")
local backgroundOffice = gfx.image.new("images/background-walls")

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
	coworker:moveTo(350, 170)
	tableSprite:moveTo(200, 190)
	ballSprite:moveTo(420, 300)
end

local function updateSpinMeter()
	gaugeLevel = math.floor(ballSpin / 10)
	if math.abs(gaugeLevel) >= gaugeMax then
		gaugeLevel = gaugeMax
	end
	
	if ballSpin < 0 then
		gaugeLevel = -gaugeLevel
	end
	
	print(gaugeLevel)
end

local function renderSpinMeter()
	gfx.setColor(gfx.kColorBlack)
	
	if gaugeLevel > 0 then
		for i=0, gaugeLevel - 1 do
			local xValue = 212 + (i * 12)
			gfx.fillRect(xValue, 220, 10, 10)
		end
	else
		for i=0, math.abs(gaugeLevel) - 1 do
			local xValue = 177 - (i * 12)
			gfx.fillRect(xValue, 220, 10, 10)
		end
	end
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
	updateSpinMeter()
end

local function resetGame()
	player:resetGame()
	time = 0
	seconds = 0
	score = {0, 0}
end

local function resetScreen() 
	print("reset screen")
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 400, 240)
end

local function calculateSpin(paddleLocation, person)
	if person == 'player' then
		gfx.drawLine(player.x+30,player.y-30,player.x + 70, player.y-30)
		gfx.drawLine(player.x+30,player.y+20,player.x + 70, player.y+20)
	elseif person =='coworker' then
		gfx.drawLine(coworker.x-30,coworker.y-30,coworker.x-70, coworker.y-30)
		gfx.drawLine(coworker.x-30,coworker.y+20,coworker.x-70, coworker.y+20)
	end
	
	if paddleLocation < ballSprite.y then
		local addSpin = ballSprite.y - paddleLocation
		ballSpin -= addSpin
		-- hit spin indicator
		if person == 'player' then
			gfx.drawText("SPIN -", player.x+30, player.y+35)
		elseif person == 'coworker' then
			gfx.drawText("SPIN -", coworker.x-30, coworker.y+35)
		end
	elseif paddleLocation > ballSprite.y then
		local addSpin = paddleLocation - ballSprite.y
		ballSpin += addSpin
		-- hit spin indicator
		if person == 'player' then
			gfx.drawText("SPIN +", player.x+30, player.y-45)
		elseif person == 'coworker' then
			gfx.drawText("SPIN +", coworker.x-30, coworker.y-45)
		end
	else
		--print("**** PERFECT ACCURACY SHOT -- Do something special? ****")
	end
	
	updateSpinMeter()
end

local function playHitSound()
	local synth = snd.synth.new(snd.kWaveSawtooth)
	synth:setDecay(0.1)
	synth:setSustain(0)
	synth:playNote(220)
end

local function coworkerHits()
	playHitSound()
	local paddleLocation = coworker.y - 10 -- randomize paddle location?
	calculateSpin(paddleLocation, 'coworker')
	
	-- simulate swing accuracy, random strength and top or bottom spin
	math.randomseed(playdate.getSecondsSinceEpoch())
	local r = math.random(1, 2)
	if r == 1 then
		-- bottom spin!
		ballSpin = -ballSpin
	end
	
	ballSpeed -= 40 * ballSpeedMultiplier
	ballUpForce += hitUpForce
	ballBounceMultiplier = 1
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "ai"
end

local function coworkerSwings()
	coworker:swing()
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

local function hitSmash()
	playHitSound()
	ballUpForce = hitUpForce + 20
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "player"
	ballSpeed += 70 * ballSpeedMultiplier
end

local function swing(type)
	player:swing()
	if ballSprite.x < 100 then
		local paddleLocation = player.y - 10
		if paddleLocation < ballSprite.y + 30 and paddleLocation > ballSprite.y - 30 and ballLastTouched ~= "player" then
			if type == "smash" then
				hitSmash()
			else
				hit(paddleLocation)
			end
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

local function drawDesks()
	local currentOfficeDesks = {
		{"coworker", "working"},
		{"coworker", "afk"},
		{"developer", "working"},
		{"developer", "afk"},
		{"boss", "working"},
		{"server", "working"},
		{"server", "working"},
	}

	for i = 1, #currentOfficeDesks do
	  desks[i] = Desk:new()
	  desks[i]:add()
	  desks[i]:updateEmployee(currentOfficeDesks[i][1])
	  desks[i]:updateState(currentOfficeDesks[i][2])
	  desks[i]:moveTo(40+(i*40), 35)
	end
end

local function drawDialogue(text)
	gfx.drawRect(50, 50, 200, 80)
	gfx.drawText(text, 60, 60)
	
	-- disable input and game, press A to continue
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())

	tableSprite = gfx.sprite.new(table)
	ballSprite = gfx.sprite.new(ball)
	
	player:add()
	coworker:add()
	boss:add()
	tableSprite:add()
	ballSprite:add()
	
	drawDesks()
	
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

	if debug == false then
		gfx.drawText("SHITTER HQ", 150, 6)
	end

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
	renderSpinMeter()
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
		playdate.drawFPS(100, 100)
		gfx.drawText(gfx.sprite.spriteCount(), 100, 120)
	end
end

function playdate.update()
	gfx.setFont(font)
	
	if gameState == "play" then
		
		if showDialog then
			-- Update screen
			playdate.timer.updateTimers()
			gfx.sprite.update()
			renderUI()
			
			drawDialogue("get back to your desk")
			
			if playdate.buttonJustPressed(playdate.kButtonA) then
				showDialog = false
			end
		else
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
				if debug then
					printTable(gfx.sprite.getAllSprites())
				end
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
					swing("smash")
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
				coworker:moveTo(coworker.x, ballSprite.y)
			end
			
			-- Time
			if time % timeSpeed == 0 then
				moveBall()
			end
			if time % 30 == 0 then
				seconds += 1
			end
			time += 1
		end
	
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
			showDialog = true
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
