local hud = {}
hud.announcement_time = 0

function hud:draw()
	if self.announcement_time > 0 then
		love.graphics.setColor(1,1,1,self.announcement_time/3)
		love.graphics.setFont(font.large)
		love.graphics.print(self.announcement, SCREEN_WIDTH / 2 - font.large:getWidth(self.announcement) / 2, SCREEN_HEIGHT / 3)
	end
end

function hud:update(dt)
	self.announcement_time = self.announcement_time - dt
end

function hud:announce(text)
	self.announcement = text
	self.announcement_time = 3
end

return hud