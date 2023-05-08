local camera = {}
camera.x = -SCREEN_WIDTH/2
camera.y = -SCREEN_HEIGHT/2
camera.rotation = 0
camera.x_scale = 1
camera.y_scale = 1
camera.speed = 150
camera.x_buffer = 100
camera.y_buffer = 100
camera.following = false

function camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.x_scale, 1 / self.y_scale)
	love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
	love.graphics.pop()
end

function camera:scale(x_scale, y_scale)
	self.x_scale = self.x_scale * x_scale
	self.y_scale = self.y_scale * y_scale
end

function camera:set_scale(x_scale, y_scale)
	self.x_scale = x_scale
	self.y_scale = y_scale
end

function camera:rotate(radians)
	self.rotation = self.rotation + radians
end

function camera:set_rotation(radians)
	self.rotation = radians
end

function camera:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function camera:set_position(x, y)
	self.x = x
	self.y = y
end

function camera:set_x(x)
	self.x = x
end

function camera:set_y(y)
	self.y = y
end

function camera:follow(target)
	self.target = target
	self.following = true
end

function camera:free()
	self.target = nil
	self.following = false
end

function camera:update(dt)

	if self.following == false then
		return
	end


	local delta = self.target.x + self.target.width + self.x_buffer - self.x - SCREEN_WIDTH * self.x_scale
	if delta > 0 then
		self:move(delta, 0)
	end

	delta = self.target.x - self.x - self.x_buffer
	if delta < 0 then
		self:move(delta, 0)
	end

	delta = self.target.y + self.target.height + self.y_buffer - self.y - SCREEN_HEIGHT * self.y_scale
	if delta > 0 then
		self:move(0, delta)
	end

	delta = self.target.y - self.y - self.y_buffer
	if delta < 0 then
		self:move(0, delta)
	end
end

function camera:screen_to_world(screen_x, screen_y)
	return screen_x * self.x_scale + self.x, screen_y * self.y_scale + self.y
end







return camera