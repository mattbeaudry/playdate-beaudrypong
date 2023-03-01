import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/animator"

local gfx <const> = playdate.graphics

local geo = playdate.geometry
local Animator = playdate.graphics.animator
local animators = {}

Streak = {}
Streak.__index = Streak

function Streak:new(startX, startY, endX, endY, radius)
	local self = gfx.sprite.new()
	self.startX = startX
	self.startY = startY
	self.endX = endX
	self.endY = endY
	self.radius = radius
	self.delay = delay
	local ls = false
	local lsAnim = false
	local as = false
	local asAnim = false
	self.isStreaking = false
	
	function self:drawStreak()
		ls = geo.lineSegment.new(self.startX, self.startY, self.endX, self.endY)
		lsAnim = Animator.new(100, ls, playdate.easingFunctions.linear, 100)
		self.isStreaking = true
	end
	
	function self:drawArcStreak()
		-- print("new arc streak")
		-- print(self.endX)
		-- print(self.endY)
		-- as = geo.arc.new(self.startX, self.startY, self.radius, self.endX, self.endY)
		asAnim = Animator.new(200,  self.endX, self.endY, playdate.easingFunctions.linear, self.delay or 0)
		self.isStreaking = true
	end
	
	function self:update()
		if self.isStreaking then
			if lsAnim then
				local p = lsAnim:currentValue()
				local startPointX = p.x - 10
				local startPointY = p.y - 10
				
				if self.startX > startPointX then
					startPointX = self.startX
				end
				
				if self.startY > startPointY then
					startPointY = self.startY
				end
				
				gfx.drawLine(geo.lineSegment.new(startPointX, startPointY, p.x, p.y))
				
				if lsAnim:ended() then
					self:endStreak()
				end
			end
			
			-- draw the arc animation
			-- if arcAnim then
			-- 	gfx.drawArc(arc)
			-- 	local p = arcAnim:currentValue()
			-- 	gfx.fillCircleAtPoint(p, 5)
			-- 	
			-- 	gfx.drawTextAligned(math.floor(100*arcAnim:progress()).."%", 121, 30, kTextAlignment.center)
			-- end
			
			if asAnim then
				local p = asAnim:currentValue()
				-- local arcStart = p.x - 10
				-- local arcEnd = p.y - 10
				
				-- if self.startX > arcStart then
				-- 	arcStart = self.startX
				-- end
				
				-- if self.startY > arcEnd then
				-- 	arcEnd = self.startY
				-- end
				
				-- print(p.x)
				-- print(p.y)
				
				gfx.drawArc(self.startX, self.startY, self.radius,  p, self.endX)
				-- gfx.drawArc(self.startX, self.startY, self.radius, self.endX, self.endY)
				
				if asAnim:ended() then
					self:endStreak()
				end
			end
		end
	end
	
	function self:endStreak()
		self.isStreaking = false
	end
	
	return self
end