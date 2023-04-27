local zombie = {}
zombie.name = 'zombie'
zombie.x = 0
zombie.y = 0
zombie.vx = 0
zombie.vy = 0
zombie.speed = 64
zombie.width = 16
zombie.height = 32
zombie.color = {r = 50, g = 255, b = 50}
zombie.health = 100
zombie.lifetime = 0
zombie.pathfind_countdown = 0.1
zombie.melee_damage = 10
zombie.attack_cooldown = 0.5
zombie.damage_mask = 1
zombie.damages_mask = 2
zombie.collision_mask = 1

zombie.stuck_counter = 0

function zombie:new()
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end
	return new
end

function zombie:load(id)
	self.max_health = self.health
	self.id = id
	self.lifetime = self.lifetime - math.random()*2 -- hack to avoid getting stuck on each other on spawn
	if server then
		server:broadcast(packet_types.SPAWN_ENTITY, {type = 'zombie', id = id, x = self.x, y = self.y, health = self.health, color = self.color, width = self.width, height = self.height})
	end
end


function zombie:draw()
	love.graphics.setColor(self.color.r/255, self.color.g/255, self.color.b/255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(1,0,0)
	love.graphics.rectangle("fill", self.x, self.y + self.height + 4, self.width + 4, 4)
	love.graphics.setColor(0,1,0)
	love.graphics.rectangle("fill", self.x, self.y + self.height + 4, (self.width + 4) * self.health / self.max_health, 4)
end


function zombie:update(dt)
	self.lifetime = self.lifetime + dt

	if server then
		self.pathfind_countdown = self.pathfind_countdown - dt
		self.attack_cooldown = math.max(0, self.attack_cooldown - dt)
		if self.pathfind_countdown <= 0 then
			self:pathfind()
			self.pathfind_countdown = 0.1
		end

		for k,ply in pairs(server.players) do
			if ply.health > 0 and util:colliding(self, ply) then
				if bit.band(self.damages_mask, ply.damage_mask) == self.damages_mask and self.attack_cooldown == 0 then
					ply:damage(self.melee_damage)
					self.attack_cooldown = 0.5
				end
			end
		end
	end

	local old_x, old_y = self.x, self.y
	self.x = self.x + self.vx * self.speed * dt
	self.y = self.y + self.vy * self.speed * dt
	local new_x, new_y = self.x, self.y

	local entities = {}
	if server then
		entities = server.entities
	else
		entities = game.entities
	end

	if self.lifetime < 0 then return end

	-- Terribly done collisions with other zombies
	for k, ent in pairs(entities) do
		if ent ~= self and bit.band(self.collision_mask, ent.collision_mask) and util:colliding(self, ent) then
			self.x = old_x
			if util:colliding(self, ent) then
				self.x = new_x
				self.y = old_y
				if util:colliding(self, ent) then
					self.x = old_x
					self.stuck_counter = self.stuck_counter + 1

					if self.stuck_counter > 20 then
						self.x = new_x
						self.y = new_y
					end
				end
			end
		end
	end
end

-- server side function only
function zombie:pathfind()
	if server then
		nearest_player = server.players[0]
		distance = 99999999999999999999999
		for k,v in pairs(server.players) do
			if v.health > 0 then
				cur_dist = util:quickDistance(self.x, v.x, self.y, v.y)
				if cur_dist < distance then
					distance = cur_dist
					nearest_player = v
				end
			end
		end

		if not nearest_player then return end

		local center_x, center_y = self.x + self.width / 2, self.y + self.height / 2
		local target_center_x, target_center_y = nearest_player.x + nearest_player.width / 2, nearest_player.y + nearest_player.width / 2
		local angle = math.atan2(target_center_x - center_x, target_center_y - center_y)
		self.vx = math.sin(angle)
		self.vy = math.cos(angle)
		self:send_state()
	end
end

function zombie:send_state(data)
	if not data then data = {} end
	data.x = self.x
	data.y = self.y
	data.vx = self.vx
	data.vy = self.vy
	data.id = self.id

	server:broadcast(packet_types.ENTITY_DATA, data)
end

function zombie:damage(damage)
	self.health = math.max(0, self.health - damage)
	if server then
		self:send_state({health = self.health})

		if self.health == 0 then
			server:broadcast(packet_types.ENTITY_DEATH, {id=self.id})
			server:remove_entity(self.id)
		end
	end
end

return zombie