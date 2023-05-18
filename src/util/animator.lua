local animator = {}
animator.states = {}
animator.current_state = nil
animator.default_state = nil
animator.current_frame = 1
animator.last_frame_change = 0
animator.layers = {}

function animator:new(source, x_offset, y_offset, use_auto_offset)
	function copy(src)
		local new = {}
		for k,v in pairs(src) do
			if type(v) == "table" then
				new[k] = copy(v)
			else
				new[k] = v
			end
		end
		return new
	end
	local new = copy(self)

	new.source = source
	new:load_texture()

	new.x_offset = x_offset
	new.y_offset = y_offset

	if use_auto_offset ~= nil then
		new.auto_offset = use_auto_offset
	else
		new.auto_offset = true
	end

	return new
end

function animator:load_texture(source)
	if not source then source = self.source end
	self.layers[#self.layers+1] = {states={}}
	self.layers[#self.layers].texture = love.graphics.newImage("assets/" .. source .. ".png")
	self.layers[#self.layers].texture:setFilter("nearest", "nearest")
	self.layers[#self.layers].texture_width, self.layers[#self.layers].texture_height = self.layers[#self.layers].texture:getDimensions()

	self.layers[#self.layers].spriteBatch = love.graphics.newSpriteBatch(self.layers[#self.layers].texture, 256) -- enough, i guess?
end

function animator:load_state(state_name, start_frame, row, frame_width, frame_height, number_of_frames, kwargs)
	kwargs = kwargs or {}
	kwargs.mirror = kwargs.mirror or false
	kwargs.frametime = kwargs.frametime or 0.1
	if kwargs.replay == nil then kwargs.replay = true end

	if self.auto_offset then
		self.auto_x_offset = -frame_width/2
	else
		self.auto_x_offset = 0
	end

	self.states[state_name] = {frametime=kwargs.frametime, mirror=kwargs.mirror, replay = kwargs.replay}
	for k,v in pairs(self.layers) do
		v.states[state_name] = {}
		orig_start = start_frame
		orig_row = row
		for i=1, number_of_frames do
			v.states[state_name][i] = love.graphics.newQuad((i - 1 + start_frame) * frame_width, row * frame_height,
				frame_width, frame_height, v.texture_width, v.texture_height)

			if (i + start_frame) * frame_width >= v.texture_width then
				start_frame = start_frame - v.texture_width / frame_width
				row = row + 1
			end
		end
		start_frame = orig_start
		row = orig_row
	end
end

function animator:set_frame_information(state_name, layer_index, frame_number, x_pos, y_pos, frame_width, frame_height)
	self.layers[layer_index].states[state_name][frame_number] = love.graphics.newQuad(x_pos, y_pos,
		frame_width, frame_height, self.layers[layer_index].texture_width, self.layers[layer_index].texture_height)
end

function animator:mirror_state(original_state, new_state)
	self.states[new_state] = {
		mirror = not self.states[original_state].mirror,
		frametime = self.states[original_state].frametime,
		replay = self.states[original_state].replay
	}

	for k,v in pairs(self.layers) do
		v.states[new_state] = {}
		for i=1, #v.states[original_state] do
			v.states[new_state][i] = v.states[original_state][i]
		end
	end
end

function animator:set_frame()
	local sx = 1
	if self.states[self.current_state].mirror then sx = -1 end
	for k, layer in pairs(self.layers) do
		if layer.quad_id == nil then
			layer.quad_id = layer.spriteBatch:add(layer.states[self.current_state][self.current_frame], 0, 0, 0, sx, 1)
		else
			layer.spriteBatch:set(layer.quad_id, layer.states[self.current_state][self.current_frame], 0, 0, 0, sx, 1)
		end
	end
end

function animator:set_state(state_name, kwargs)
	kwargs = kwargs or {}
	if kwargs.override == nil then kwargs.override = false end

	if self.current_state == state_name and not kwargs.override then return end

	self.current_state = state_name
	self.current_frame = 1
	self.last_frame_change = 0
	self:set_frame()
end

function animator:set_default(state_name)
	self.default_state = state_name
end

function animator:draw(x, y)
	love.graphics.setColor(255,255,255)
	local offset = self.x_offset + self.auto_x_offset
	local rotation = self.r or 0
	if self.states[self.current_state].mirror then
		offset = self.x_offset - self.auto_x_offset
		rotation = -rotation
	end
	for k,layer in pairs(self.layers) do
		love.graphics.draw(layer.spriteBatch, x + offset, y + self.y_offset, rotation)
	end
end

function animator:update(dt)
	self.last_frame_change = self.last_frame_change + dt

	if self.last_frame_change > self.states[self.current_state].frametime then
		self.last_frame_change = 0

		self.current_frame = (self.current_frame + 1) % (#self.layers[1].states[self.current_state] + 1)
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