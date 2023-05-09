local font = {}


function font:load()
	self.small = love.graphics.newImageFont("assets/font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
    self.small:setFilter("nearest", "nearest")

	self.large = love.graphics.newImageFont("assets/font_large.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
    self.large:setFilter("nearest", "nearest")

	self.medium = love.graphics.newImageFont("assets/font_medium.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
    self.medium:setFilter("nearest", "nearest")
end


return font