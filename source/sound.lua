local snd <const> = playdate.sound

Sound = {}
Sound.__index = Sound

function Sound:new()
	local themeMusic = snd.fileplayer.new()
	themeMusic:load("sounds/shitty-pong-track-1")
	
	function self:startMusic()
		themeMusic:play()
	end
	
	return self
end


