import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

Boss = {}
Boss.__index = Boss

local bossImages = {}
bossImages["stand"] = gfx.image.new("images/boss-stand")
bossImages["arms"] = gfx.image.new("images/boss-arms")

function Boss:new()
	local self = gfx.sprite.new()
	self:moveTo(300, 95)

	function self:updateState(newState)
		self:setImage(bossImages[newState], gfx.kImageFlippedX)
	end

	self:updateState("arms")

	return self
end
