local chatbox = {}
chatbox.open = false
chatbox.width = 400
chatbox.messages = {}

function chatbox:unload()
	input:removeBind("sendChat")
end

function chatbox:message(name, msg)
	local lines = math.floor(font.small:getWidth(name .. ": " .. msg) / self.width + 1)
	self.messages[#self.messages + 1] = {name, msg, 0, lines}
end

function chatbox:load()
	self.sendButton = button:new({text="Send", x=self.width - 40, y=SCREEN_HEIGHT - font.small:getHeight() - 4, width = 40, height = font.small:getHeight(), onClick = function()
		self.open = false

		if self.textbox.text == "" then return end

		network:send(network.packet_types.CHAT, {msg=self.textbox.text})
		self.textbox.text = ""
	end})

	self.sendButton.font = font.small
	self.sendButton.color = 		{r = 40 / 255, g = 40 / 255, b = 40 / 255, a = 140 / 255}
	self.sendButton.hoverColor = 	{r = 30 / 255, g = 30 / 255, b = 30 / 255, a = 140 / 255}
	self.sendButton.clickColor = 	{r = 5 / 255, g = 5 / 255, b = 5 / 255, a = 140 / 255}


	self.textbox = textbox:new("", font.small, 2, SCREEN_HEIGHT - font.small:getHeight() - 4, self.width - 40)
	self.textbox.activeColor = {r = 10 / 255, g = 10 / 255, b = 10 / 255, a = 140 / 255}

	input:addBind("sendChat", "return", function(down)
		if not down then
			if self.open then
				self.sendButton:onClick()
			end
		end
	end)

	input:addBind("exitChat", "escape", function(down)
		if not down and self.open then
			self.open = false
		end
	end)

	input:addBind("chat", settings.binds.chat, function(down)
		if not down and not self.open then
			self.open = true
		end
	end)
end

function chatbox:draw()
	if not self.open then 
		local y = SCREEN_HEIGHT - font.small:getHeight() - 4 - 2

		for i=#self.messages, 1, - 1 do
			if self.messages[i][3] < 5 then
				y = y - font.small:getHeight() * self.messages[i][4]


				local rectAlpha = math.min( self.textbox.activeColor.a, (5 / self.messages[i][3] - 1)) * 255
				local alpha = math.min( 255, (5 / self.messages[i][3] - 1) * 255)
				
				love.graphics.setColor(self.textbox.activeColor.r, self.textbox.activeColor.g, self.textbox.activeColor.b, rectAlpha/255)
				love.graphics.rectangle('fill', 2, y, self.width, font.small:getHeight() * self.messages[i][4])
				love.graphics.setColor(1,1,1)
				
				love.graphics.printf({ {50/255, 50/255, 205/255, alpha/255}, self.messages[i][1] .. ": ", {1, 1, 1, alpha/255}, self.messages[i][2] }, 2, y, self.width)
			end
		end

		return 
	end

	local lines = 0
	local toShow = {}
	for i=#self.messages, 1, -1 do
		if lines + self.messages[i][4] > 5 then
			break
		else
			lines = lines + self.messages[i][4]
			toShow[#toShow + 1] = self.messages[i]
		end
	end

	local y = SCREEN_HEIGHT - font.small:getHeight() - 4 - 2

	for i=1, #toShow do
		y = y - font.small:getHeight() * toShow[i][4]

		love.graphics.setColor(self.textbox.activeColor.r, self.textbox.activeColor.g, self.textbox.activeColor.b, self.textbox.activeColor.a or 1)
		love.graphics.rectangle('fill', 2, y, self.width, font.small:getHeight() * toShow[i][4])
		love.graphics.setColor(1,1,1)
		
		love.graphics.printf({ {50/255, 50/255, 205/255}, toShow[i][1] .. ": ", {1, 1, 1}, toShow[i][2] }, 2, y, self.width)
	end

	self.textbox:draw()
	self.sendButton:draw()
end

function chatbox:update(dt)
	for i=1,#self.messages do
		self.messages[i][3] = math.min(5, self.messages[i][3] + dt)
	end

	if not self.open then return end

	self.textbox:update(dt)
	self.sendButton:update(dt)

	self.textbox.active = true
end

function chatbox:keypressed(key)
	if not self.open then return end

	self.textbox:keypressed(key)
end

function chatbox:textinput(t)
	if not self.open then return end

	self.textbox:textinput(t)
end

return chatbox