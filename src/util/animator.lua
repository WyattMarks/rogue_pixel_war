local animator = {}
animator.states = {}
animator.current_state = nil
animator.default_state = nil
animator.current_frame = 1
animator.last_frame_change = 0
animator.layers = {}

function animator:new(source, x_offset, y_offset)
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end

	new.source = source
	new:load_texture()

	new.x_offset = x_offset
	new.y_offset = y_offset

	return new
end

function animator:load_texture(source)
	if not source then source = self.source end
	self.layers[#self.layers+1] = {}
	self.layers[#self.layers].texture = love.graphics.newImage("assets/" .. source .. ".png")
	self.layers[#self.layers].texture:setFilter("nearest", "nearest")
	self.texture_width, self.texture_height = self.layers[#self.layers].texture:getDimensions()

	self.layers[#self.layers].spriteBatch = love.graphics.newSpriteBatch(self.layers[#self.layers].texture, 256) -- enough, i guess?
end

function animator:load_state(state_name, start_frame, row, frame_width, frame_height, number_of_frames, kwargs)
	kwargs = kwargs or {}
	kwargs.mirror = kwargs.mirror or false
	kwargs.frametime = kwargs.frametime or 0.1
	if kwargs.replay == nil then kwargs.replay = true end

	self.auto_x_offset = -frame_width/2
	print(self.auto_x_offset)

	self.states[state_name] = {frametime=kwargs.frametime, mirror=kwargs.mirror, replay = kwargs.replay}
	for i=1, number_of_frames do
		self.states[state_name][i] = love.graphics.newQuad((i - 1 + start_frame) * frame_width, row * frame_height,
			frame_width, frame_height, self.texture_width, self.texture_height)
	end
end

function animator:set_frame()
	local sx = 1
	if self.states[self.current_state].mirror then sx = -1 end
	for k, layer in pairs(self.layers) do
		if layer.quad_id == nil then
			layer.quad_id = layer.spriteBatch:add(self.states[self.current_state][self.current_frame], 0, 0, 0, sx, 1)
		else
			layer.spriteBatch:set(layer.quad_id, self.states[self.current_state][self.current_frame], 0, 0, 0, sx, 1)
		end
	end
end

function animator:set_state(state_name, kwargs)
	kwargs = kwargs or {}
	if kwargs.override == nil then kwargs.override = false end

	if self.current_state == state_name and not kwargs.override then return end

	self.current_state = state_name
	self.current_frame = 1
	self:set_frame()
end

function animator:set_default(state_name)
	self.default_state = state_name
end

function animator:draw(x, y)
	love.graphics.setColor(255,255,255)
	local offset = self.x_offset + self.auto_x_offset
	if self.states[self.current_state].mirror then
		offset = self.x_offset - self.auto_x_offset
	end
	for k,layer in pairs(self.layers) do
		love.graphics.draw(layer.spriteBatch, x + offset, y + self.y_offset)
	end
end

function animator:update(dt)
	self.last_frame_change = self.last_frame_change + dt

	if self.last_frame_change > self.states[self.current_state].frametime then
		self.last_frame_change = 0

		self.current_frame = (self.current_frame + 1) % (#self.states[self.current_state] + 1)
		if self.current_frame == 0 then
			self.current_frame = 1

			if not self.states[self.current_state].replay then
				self.current_state = self.default_state
			end
		end
		self:set_frame()
	end
end








return animator