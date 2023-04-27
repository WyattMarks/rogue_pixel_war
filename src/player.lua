local player = {}

player.name = 'Player'
player.x = 0
player.y = 0
player.speed = 128
player.width = 16
player.height = 32
player.local_player = false
player.color = {r = 255, g = 50, b = 50}
player.right = false
player.left = false
player.up = false
player.down = false
player.health = 150
player.damage_mask = 2
player.xp = 77.5
player.max_xp = 100
player.mana = 50
player.max_mana = 100

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
end

function player:draw()
	if self.health == 0 then return end
	love.graphics.setColor(self.color.r/255, self.color.g/255, self.color.b/255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

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
	local distance = self.speed * dt
	-- If we are moving diagonally then we should move half as much per direction
	if (self.right or self.left) and (self.up or self.down) and not (self.right and self.left) and not (self.up and self.down) then
		distance = distance / 2
	end

	if self.right then
		self.x = self.x + distance
	end

	if self.left then
		self.x = self.x - distance
	end

	if self.up then
		self.y = self.y - distance
	end

	if self.down then
		self.y = self.y + distance
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

function player:shoot(down)
	if not down then return end
	if self.health == 0 then return end

	local x,y = camera:screen_to_world(love.mouse.getPosition())
	local eX, eY = self.x + self.width / 2 - 4 / 2, self.y + self.height / 2 - 4 / 2
	local angle = math.atan2(x - eX, y - eY)

	network:send(network.packet_types.SHOOT, {x = eX, y = eY, vx = math.sin(angle), vy = math.cos(angle), time = network.time_delta+love.timer.getTime()})
end

return player