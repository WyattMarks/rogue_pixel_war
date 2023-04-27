local main = {}
main.gameName = "Rogue Pixel War"

function main:load()
	--self.bgImage = love.graphics.newImage('assets/background.png')
	self.start_button = button:new({text = "Start Game", font = font.large, width = 300, height = 50, x = SCREEN_WIDTH / 2 - 150, y = SCREEN_HEIGHT / 2})
	self.start_button.highlightColor = {r = 90, g = 90, b = 90}
	self.start_button.clickColor = {r = 50, g = 50, b = 50}


	function self.start_button.onClick(btn)
		game:load("Player" .. tostring(math.random(99)))
	end
end

function main:draw()
	love.graphics.setColor(200,200,200)
	--love.graphics.draw(self.bgImage, 0,0)
	love.graphics.setColor(255,255,255)


	love.graphics.setFont(font.large)
	love.graphics.print(self.gameName, SCREEN_WIDTH / 2 - font.large:getWidth(self.gameName) / 2, SCREEN_HEIGHT / 3)


	self.start_button:draw()
end


function main:update(dt)
	self.start_button:update(dt)
end

function main:keypressed(key,isrepeat)

end

function main:textinput(text)

end


return main