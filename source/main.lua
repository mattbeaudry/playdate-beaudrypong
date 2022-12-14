import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "player"
import "coworker"
import "boss"
import "story"
import "desks"
import "round"

local debug = false
local gameState = "title"

local gfx <const> = playdate.graphics
local font = gfx.font.new('font/Nano Sans 2X/Nano Sans 2X')
local snd <const> = playdate.sound
local blink = gfx.animation.blinker.new()

local player = Player:new()
local coworker = Coworker:new()
local boss = Boss:new()
local story = Story:new()
local desks = Desks:new()
local round = Round:new()

local ball = gfx.image.new("images/ball-outline")
local table = gfx.image.new("images/table")
local tableSprite = gfx.sprite.new(table)
local ballSprite = gfx.sprite.new(ball)
local line = nil
local backgroundOffice = gfx.image.new("images/background-walls")

local tableEdgeLeft = 100
local tableEdgeRight = 300
local tableEdgeTop = 170
local floorEdge = 220
local ballSpeed = 0
local ballMoving = false
local ballServing = false
local ballUpForce = 0
local hitUpForce = 22
local hitType = "normal"
local ballBounceHeight = 0
local ballBounceMultiplier = 1
local ballSpeedMultiplier = 1
local ballSpin = 0
local ballLastTouched = "none"
local playerSpeed = 5
local whoIsServing = "none"
local paddleLocation = 0
local time = 0
local timeSpeed = nil
local seconds = 0
local score = {
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0},
}
local scoreUpdated = false
local maxScore = 3
local gravity = 20
local showMessage = false
local gaugeMax = 3
local gaugeLevel = 0

local function resetTimer()
	playTimer = playdate.timer.new(1000000, 0, 1000000, playdate.easingFunctions.linear)
end

local function resetSprites()
	player:moveTo(50, 170)
	coworker:moveTo(350, 170)
	tableSprite:moveTo(200, 190)
	ballSprite:moveTo(420, 300)
	player:stance()
	coworker:stance()
end

local function updateSpinMeter()
	gaugeLevel = math.floor(ballSpin / 10)
	if math.abs(gaugeLevel) >= gaugeMax then
		gaugeLevel = gaugeMax
	end
	
	if ballSpin < 0 then
		gaugeLevel = -gaugeLevel
	end
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
	ballServing = false
	ballUpForce = 0
	ballBounceHeight = 0
	ballBounceMultiplier = 1
	ballSpeedMultiplier = 1
	ballSpin = 0
	ballLastTouched = "none"
	gaugeLevel = 0
	timeSpeed = 4
	coworker.velocityX = 0
	player:resetPoint()
	updateSpinMeter()
end

local function resetGame()
	player:resetGame()
	time = 0
	seconds = 0
	-- score = {0, 0}
	whoIsServing = 'none'
end

local function resetScreen()
	-- print("reset screen")
	-- todo: this should only fire once
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 400, 240)
end

local function calculateSpin(paddleLocation, person)
	if paddleLocation < ballSprite.y then
		local addSpin = ballSprite.y - paddleLocation
		ballSpin -= addSpin
		
		-- hit spin indicator
		if person == 'player' then
			gfx.drawLine(player.x+30,player.y-30,player.x + 70, player.y-30)
			--gfx.drawText("SPIN -", player.x+30, player.y+35)
		elseif person == 'coworker' then
			--gfx.drawLine(coworker.x-30,coworker.y-30,coworker.x-70, coworker.y-30)
			gfx.drawText("SPIN -", coworker.x-30, coworker.y+35)
		end
	elseif paddleLocation > ballSprite.y then
		local addSpin = paddleLocation - ballSprite.y
		ballSpin += addSpin
		
		-- hit spin indicator
		if person == 'player' then
			--gfx.drawLine(player.x-30,player.y-30,player.x-70, player.y-30)
			gfx.drawText("SPIN +", player.x+30, player.y-45)
		elseif person == 'coworker' then
			gfx.drawText("SPIN +", coworker.x-30, coworker.y-45)
			--gfx.drawLine(coworker.x-30,coworker.y+20,coworker.x-70, coworker.y+20)
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
	ballMoving = true
	ballServing = false
	playHitSound()
	
	-- simulate swing accuracy, random strength and top or bottom spin
	math.randomseed(playdate.getSecondsSinceEpoch())
	local r = math.random(1, 2)
	local offset = -10
	if r == 1 then
		-- bottom spin!
		-- ballSpin = -ballSpin
		offset = -offset
	end
	local paddleLocation = coworker.y + offset
	calculateSpin(paddleLocation, 'coworker')
	
	if ballSpeed == 0 then
		ballSpeed -= 20 * ballSpeedMultiplier
	else 
		ballSpeed -= 40 * ballSpeedMultiplier
	end
	
	ballUpForce += hitUpForce
	ballBounceMultiplier = 1
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "ai"
	hitType = "normal"
end

local function coworkerSwings()
	-- gfx.drawLine(coworker.x-30, coworker.y-30, coworker.x-70, coworker.y-30)
	-- gfx.drawLine(coworker.x-30, coworker.y+20, coworker.x-70, coworker.y+20)

	coworker:swing()
	math.randomseed(playdate.getSecondsSinceEpoch())
	local r = math.random(1, 20)
	if r == 1 then
		score[round.round][1] += 1
		if score[round.round][1] == maxScore then 
			if round.round == 4 then
				gameState = "end"
			else
				-- next round
				round:nextRound()
				coworker.employee = round.opponent
				coworker:stance()
				boss:add()
				resetPoint()
				resetGame()
				showDialog = true
			end
		end
		showMessage = true
		resetPoint()
		resetSprites()
	else
		coworkerHits()
	end
end

local function serve()
	if whoIsServing == 'none' then
		print("player ready to serve")
		ballSprite:moveTo(player.x + 38, player.y - 20)
		player:serve()
		whoIsServing = "player"
	else
		print("throw to serve")
		ballServing = true
		local throwBall = ballSprite.y - 30
		
		if whoIsServing == 'player' then
			ballSprite:moveTo(98, throwBall)
			player:throw()
		elseif whoIsServing == 'coworker' then
			ballSprite:moveTo(300, throwBall)
			coworker:throw()
		end
		
		ballUpForce += 15
		ballSpeed = 0
		ballMoving = true
		whoIsServing = "none"
	end
end

local function hit(paddleLocation)
	ballMoving = true
	ballServing = false
	playHitSound()
	calculateSpin(paddleLocation, 'player')
	ballUpForce += hitUpForce
	ballSpeedMultiplier *= 1.001
	ballLastTouched = "player"
	hitType = "normal"
	
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
	hitType = "smash"
end

local function swing(type)
	--gfx.drawLine(player.x+30,player.y-30,player.x + 70, player.y-30)
	--gfx.drawLine(player.x+30,player.y+20,player.x + 70, player.y+20)
	print("SWING")
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
	print("update score")
	
	score[round.round][who] += howMuch
	
	if who == 2 then
		whoIsServing = 'coworker'
	elseif who == 1 then
		whoIsServing = 'none'
	end
	
	if score[round.round][who] == maxScore then
		if round.round == 4 then
			gameState = "end"
		else
			-- next round
			round:nextRound()
			coworker.employee = round.opponent
			coworker:stance()
			boss:add()
			resetPoint()
			resetGame()
			showDialog = true
			-- initialize()
		end
	end
end

local function injurePlayer(player)
	-- player shows injured sprite and flys off screen
	coworker.velocityX = 40
	coworker:injured()
end

local function moveBall()
	if ballMoving or ballServing then
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
				if hitType == "smash" then
					injurePlayer("coworker")
					showMessage = true
					playdate.timer.performAfterDelay(1000, function()
						if scoreUpdated == false then
							updateScore(1,1)
							resetPoint()
							resetSprites()
						end
						scoreUpdated = true
						playdate.timer.performAfterDelay(1000, function()
							scoreUpdated = false
						end)
					end)
				else
					if coworker.hasSwung == false then
						print("coworker has swung")
						coworkerSwings()
						coworker.hasSwung = true
						playdate.timer.performAfterDelay(1000, function()
							coworker.hasSwung = false
						end)
					end
				end
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
				-- player touched last, coworker +1 point
				updateScore(2, 1)
			elseif ballLastTouched == "coworker" then
				-- coworker touched last, player +1 point
				updateScore(1, 1)
			elseif ballLastTouched == ("table" or "none") then
				if ballSprite.x < 200 then
					updateScore(2, 1)
				else
					-- last touched none/table, RIGHT side of screen, coworker +1 point
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

local function drawDialogue(text)
	gfx.drawRect(50, 60, 200, 60)
	gfx.drawText(text, 60, 70)
	
	-- disable input and game, press A to continue
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	blink:startLoop()
	
	player:add()
	coworker:add()
	tableSprite:add()
	ballSprite:add()
	
	desks:drawDesks()
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
	gfx.drawText(score[round.round][1], 55, 220)
	gfx.drawText(score[round.round][2], 340, 220)
	
	gfx.drawText("ROUND: "..round.round, 180, 205)
	
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
	gfx.drawRect(149, 218, 40, 14)
	gfx.drawRect(210, 218, 40, 14)

	-- SMASH available indicator
	if blink.on then
		if gaugeLevel >= gaugeMax then
			gfx.drawText("SMASH!", 100, 100)
		elseif gaugeLevel <= -gaugeMax then
			gfx.drawText("SMASH!", 300, 100)
		end
	end

	-- debug info
	if debug then
		gfx.drawText(math.floor(ballSpin), 192, 205)
		gfx.drawText("time: " .. seconds .. " BSpeed: " .. ballSpeed .. "  BUpForce: " .. ballUpForce .. "  BBounceHeight: " .. ballBounceHeight, 5, 5)	
		gfx.drawText("ball.x" .. ballSprite.x .. " ball.y" .. ballSprite.y .. " paddle.y" .. paddleLocation, 5, 30)
		playdate.drawFPS(100, 100)
		gfx.drawText(gfx.sprite.spriteCount(), 100, 120)
	end
end

local function moveEmployee(employee)
	coworker.x += coworker.velocityX
end

function playdate.update()
	gfx.setFont(font)

	if gameState == "play" then
		
		-- Update screen
		playdate.timer.updateTimers()
		gfx.sprite.update()
		blink:update()
		renderUI()
		
		if showDialog then
			drawDialogue(round.dialog[1])
			
			if playdate.buttonJustPressed(playdate.kButtonA) then
				showDialog = false
				boss:remove()
				
				if round.round == 1 then
					desks:firstRound()
				elseif round.round == 2 then
					desks:secondRound()
				elseif round.round == 3 then
					desks:thirdRound()
				elseif round.round == 4 then
					desks:fourthRound()
				end
				
				desks:drawDesks()
			end
		else
			
			-- A just pressed
			if playdate.buttonJustPressed(playdate.kButtonA) then
				
				if ballMoving and whoIsServing ~= 'coworker' then
					swing()
				elseif whoIsServing == 'player' or 'none' then
					serve()
				end
			end
			
			-- B just pressed
			if playdate.buttonJustPressed(playdate.kButtonB) then
				if ballMoving and whoIsServing ~= 'coworker' then
					player:smashWindUp()
				end
			end
			
			-- B IS pressed
			if playdate.buttonIsPressed(playdate.kButtonB) then
				if ballMoving and whoIsServing ~= 'coworker' then
					player:smashWinding()
				end
			end
			
			-- B just pressed
			if playdate.buttonJustReleased(playdate.kButtonB) then
				if ballMoving and whoIsServing ~= 'coworker' then
					swing("smash")
					player:resetPoint()
				end
			end
			
			-- UP is pressed
			if playdate.buttonIsPressed(playdate.kButtonUp) then
				if player.y > 50 then 
					player:moveBy(0, -playerSpeed)
					if whoIsServing == "player" then
						ballSprite:moveBy(0, -playerSpeed)
					end
					if debug then
						gfx.drawLine(0, player.y, 400, player.y)
					end
				end
			end
			
			-- DOWN is pressed
			if playdate.buttonIsPressed(playdate.kButtonDown) then
				if player.y < 190 then 
					player:moveBy(0, playerSpeed)
					if whoIsServing == "player" then
						ballSprite:moveBy(0, playerSpeed)
					end
					if debug then
						gfx.drawLine(0, player.y, 400, player.y)
					end
				end
			end
			
			-- game round settings
			-- if round == 1 then

			-- Coworker ai	
			if ballMoving and not ballServing then
				--moveEmployee("coworker")
				if ballSprite.y > 50 or ballSprite.y < 150 then
					coworker:moveTo(coworker.x, ballSprite.y)
				end
			end
			
			-- Time
			if time % timeSpeed == 0 then
				moveBall()
				
				if whoIsServing == 'coworker' then
					-- move coworker up and down and then throw for a serve
					if coworker.hasServed == false then
						coworker.hasServed = true
						coworker:serve()
						ballSprite:moveTo(312, coworker.y - 20)
						
						playdate.timer.performAfterDelay(1000, function()
							coworker.hasServed = false
						end)
						playdate.timer.performAfterDelay(1000, function()
							serve()
						end)
						playdate.timer.performAfterDelay(1500, function()
							coworkerSwings()
						end)
					end
				end
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
			boss:add()
			
			-- start round 1
			round:firstRound()
			coworker.employee = round.opponent
			coworker:stance()
			-- todo: set game speed
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
