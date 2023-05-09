local fireball = {}
fireball.x = 0
fireball.y = 0
fireball.speed = 420
fireball.width = 30
fireball.height = 15
fireball.lifetime = 1
fireball.vx = 0
fireball.vy = 0
fireball.damage = 100
fireball.damages_mask = 1
fireball.damage_mask = 0
fireball.collision_mask = 0

function fireball:new()
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end
	return new
end

function fireball:load(id)
	self.id = id
	if server then
		server:broadcast(packet_types.SPAWN_ENTITY, {type = 'fireball', id = id, x = self.x, y = self.y, color = self.color, width = self.width, height = self.height, vx = self.vx, vy = self.vy})
	end

	if server then return end

	self.animator = animator:new("weapons/staff-shot-01-30x15", 12, 0)
	-- self.animator:load_texture("weapons/sword-slash-01-60x30")

	self.animator:load_state('done', 0, 0, 0, 0, 1, {frametime=10, replay=false})
	self.animator:load_state('idle_right', 0, 0, 30, 15, 15, {frametime=self.lifetime/15, replay=false})
	self.animator:mirror_state('idle_right', 'idle_left')
	self.animator:set_default('done')

	if self.vx > 0 then
		self.animator:set_state('idle_right')
	else
		self.animator:set_state('idle_left')
	end

	self.animator.r = math.asin(self.vy)
	print(self.animator.r)
end


function fireball:draw()
	self.animator:draw(self.x, self.y)

	if debugger.hitboxes then
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
	end
end


function fireball:update(dt, process_only)
	self.lifetime = self.lifetime - dt


	self.x = self.x + self.vx * self.speed * dt
	self.y = self.y + self.vy * self.speed * dt

	if server then
		if not process_only then
			for k,ent in pairs(server.entities) do
				if util:colliding(self, ent) then
					if bit.band(self.damages_mask, ent.damage_mask) == self.damages_mask then
						ent:damage(self.damage)
						server:broadcast(packet_types.ENTITY_DEATH, {id=self.id})
						server:remove_entity(self.id)
					end
				end
			end

			if self.lifetime <= 0 then
				server:broadcast(packet_types.ENTITY_DEATH, {id=self.id})
				server:remove_entity(self.id)
			end
		end
	else
		self.animator:update(dt)
	end
end

return fireball