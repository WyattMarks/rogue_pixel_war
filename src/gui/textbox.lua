local textbox = {}
textbox.width = 100
textbox.x = 0
textbox.y = 0
textbox.active = false
textbox.text = ""
textbox.drawText = ""
textbox.blinkRate = .5
textbox.lastBlink = 0
textbox.blinking = false
textbox.activeColor = {r = 50 / 255, g = 50 / 255, b = 50 / 255}
textbox.color = {r = 70 / 255, g = 70 / 255, b = 70 / 255}
utf8 = require("utf8")

local textboxMeta = {__index = textbox}

function textbox:new(text, font, x, y, width)
	local new = setmetatable({}, textboxMeta)
	new.x = x
	new.y = y
	new.width = width
	new.text = text
    new.font = font

	return new
end

function textbox:textinput(t)
	if self.active then
        if not self.firstInput then self.firstInput = true self.text = '' end
		self.text = self.text..t
	end
end

function textbox:keypressed(key, isrepeat)
	if key == "backspace" and self.active then
        if not self.firstInput then self.firstInput = true self.text = '' end
		local byteoffset = utf8.offset(self.text, -1)
	 
	    if byteoffset then
	        self.text = string.sub(self.text, 1, byteoffset - 1)
	    end
	end
end

function textbox:update(dt)
	local mouseX, mouseY = love.mouse.getPosition()
	local mouseOver = false

    if not self.height then self.height = self.font:getHeight() end

	if util:rectPointCollision(self, mouseX, mouseY) then
		mouseOver = true
	end
	
    local down = love.mouse.isDown(1)

	if mouseOver and self.wasDown and not down then 
		self.active = true
	end
	
	if self.wasDown and not mouseOver then
		self.active = false
	end

	self.wasDown = down
	
	if self.font:getWidth(self.text) > self.width then
		local i = 1
		while (self.font:getWidth(self.drawText) < self.width) do
			local text = self.text
			self.drawText = text:sub(#text - i)
			i = i + 1
		end
		
		self.drawText = self.drawText:sub(2)
	else
		self.drawText = self.text
	end


	if self.active then
		self.lastBlink = self.lastBlink + dt
		if self.lastBlink > self.blinkRate then 
			self.lastBlink = self.lastBlink - self.blinkRate

			self.blinking = not self.blinking
		end
	else
		self.blinking = false
	end
end

function textbox:draw()
	love.graphics.setFont(self.font)
	if self.active then
		love.graphics.setColor(self.activeColor.r, self.activeColor.g, self.activeColor.b, self.activeColor.a or 1)
	else
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a or 1)
	end
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.font:getHeight())
	
	love.graphics.setColor(255,255,255)
	love.graphics.print(self.drawText, self.x, self.y)

	if self.blinking then
		love.graphics.rectangle('fill', self.x + self.font:getWidth(self.drawText), self.y, 2, self.font:getHeight() )
	end
end





return textbox