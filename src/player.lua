local player = {}

player.name = 'Player'
player.x = 0
player.y = 0
player.speed = 128
player.width = 16
player.height = 36
player.local_player = false
player.color = {r = 255, g = 50, b = 50}
player.right = false
player.left = false
player.up = false
player.down = false
player.health = 150
player.damage_mask = 2
player.xp = 0
player.max_xp = 100
player.mana = 100
player.max_mana = 100
player.mana_recovery = 10
player.level = 1

function player:new()
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end
	return new
end

function player:load()
	self.max_health = self.health
	if self.local_player then
		self.color = {r = 50, g = 50, b = 255}
	end

	if server then return end

	self.animator = animator:new("player/player-spritemap-v9", 8, -12)
	self.animator:load_texture("armor/robe01-spritemap-v9")
	self.animator:load_texture("weapons/staff-attack-02-60x30")
	-- self.animator:load_texture("weapons/sword-slash-01-60x30")

	self.animator:load_state('running_right', 0, 3, 46, 50, 8)
	self.animator:mirror_state('running_right', 'running_left')

	self.animator:load_state('idle_right', 0, 0, 46, 50, 1, {frametime=10})
	self.animator:set_frame_information("idle_right", 3, 1, 180, 0, 60, 30)
	self.animator:mirror_state('idle_right', 'idle_left')

	self.animator:load_state('crouch_right', 1, 0, 46, 50, 1, {frametime=10})
	self.animator:mirror_state("crouch_right", "crouch_left")

	self.animator:load_state('attack_right', 2, 0, 46, 50, 4, {frametime=0.1, replay=false})
	self.animator:set_frame_information("attack_right", 3, 1, 0, 0, 60, 30)
	self.animator:set_frame_information("attack_right", 3, 2, 60, 0, 60, 30)
	self.animator:set_frame_information("attack_right", 3, 3, 120, 0, 60, 30)
	self.animator:set_frame_information("attack_right", 3, 4, 126, -2, 60, 30)
	self.animator:mirror_state("attack_right", "attack_left")


	self.animator:set_state('idle_right')
	self.animator:set_default('idle_right')
end

function player:draw()
	if self.health == 0 then return end
	self.animator:draw(self.x, self.y)

	if debugger.hitboxes then
		if self.local_player then
			love.graphics.setColor(0, 1, 0)
		else
			love.graphics.setColor(1, 0, 0)
		end
		love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
	end

	love.graphics.setFont(font.small)
	love.graphics.print(self.name, self.x - font.small:getWidth(self.name) / 2 + self.width / 2, self.y + self.height)

	if not self.local_player then
		love.graphics.setColor(1,0,0)
		love.graphics.rectangle("fill", self.x - 2, self.y - 8, self.width + 4, 4)
		love.graphics.setColor(0,1,0)
		love.graphics.rectangle("fill", self.x - 2, self.y - 8, (self.width + 4) * self.health / self.max_health, 4)
	end
end

function player:update(dt)
	if self.health == 0 then return end
	if not server then self.animator:update(dt) end
	self.mana = math.min(self.mana + self.mana_recovery * dt, self.max_mana)

	if not server and self:attacking() then
		return -- Rest of function is movement code, we're not moving
	end

	local distance = self.speed * dt
	-- If we are moving diagonally then we should move half as much per direction
	if (self.right or self.left) and (self.up or self.down) and not (self.right and self.left) and not (self.up and self.down) then
		distance = distance / 2
	end

	local oldx, oldy = self.x, self.y

	if self.right and not self.left then
		if not server then self.animator:set_state('running_right') end
		self.x = self.x + distance
	end

	if self.left and not self.right then
		if not server then self.animator:set_state('running_left') end
		self.x = self.x - distance
	end

	if self.up and not self.down then
		self.y = self.y - distance

		if not server then 
			if self.animator.current_state == 'idle_right' then
				self.animator:set_state('running_right')
			elseif self.animator.current_state == 'idle_left' then
				self.animator:set_state('running_left')
			end
		end
	end

	if self.down and not self.up then
		self.y = self.y + distance

		if not server then 
			if self.animator.current_state == 'idle_right' then
				self.animator:set_state('running_right')
			elseif self.animator.current_state == 'idle_left' then
				self.animator:set_state('running_left')
			end
		end
	end

	if not server and self.x == oldx and self.y == oldy then
		if self.animator.current_state == 'running_right' then
			self.animator:set_state('idle_right')
		elseif self.animator.current_state == 'running_left' then
			self.animator:set_state('idle_left')
		end
	end
end

function player:send_input_state(data)
	if not self.local_player then return end
	if self.health == 0 then return end
	if data == nil then data = {} end
	current_input = util:encode_input_state(self)

	data.input = current_input
	data.x = self.x
	data.y = self.y
	data.time = network.time_delta + love.timer.getTime()

	network:send(network.packet_types.PLAYER_DATA, data)
end

function player:damage(damage)
	if self.health == 0 then return end
	self.health = math.max(0, self.health - damage)
	if server then
		server:broadcast(packet_types.PLAYER_DATA, {health = self.health, player=self.peer:connect_id()})
	elseif self.health == 0 then
		if camera.target == self then
			debugger:print("Oh no the person we're watching died, switching people...")
			for k,v in pairs(game.players) do
				if v.health > 0 then
					camera:follow(v)
					break
				end
			end
		end
	end
end

function player:reward(xp)
	self.xp = self.xp + xp

	if self.xp >= self.max_xp then
		self.xp = self.xp - self.max_xp
		self.level = self.level + 1
	end

	if server then
		server:broadcast(packet_types.PLAYER_DATA, {xp = self.xp, player=self.peer:connect_id(), level=self.level})
	end
end

function player:attacking()
	local old = self._attacking
	self._attacking = self.animator.current_state == 'attack_right' or self.animator.current_state == 'attack_left'

	if old and not self._attacking then
		self:send_input_state()
	end
	return self._attacking
end

function player:shoot(down)
	if not down then return end
	if self.health == 0 then return end
	if self:attacking() then return end

	if self.mana > 20 then
		self.mana = self.mana - 20
	else
		return
	end

	local x,y = camera:screen_to_world(love.mouse.getPosition())
	local eX, eY = self.x + self.width / 2 - 4 / 2, self.y
	local angle = math.atan2(x - eX, y - eY)

	if math.sin(angle) > 0 then
		self.animator:set_state('attack_right', {override=true})
		self.animator:set_default('idle_right')
	else
		self.animator:set_state('attack_left', {override=true})
		self.animator:set_default('idle_left')
	end

	network:send(network.packet_types.SHOOT, {x = eX, y = eY, vx = math.sin(angle), vy = math.cos(angle), time = network.time_delta+love.timer.getTime()})
end

return player