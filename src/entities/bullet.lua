local bullet = {}
bullet.x = 0
bullet.y = 0
bullet.speed = 512
bullet.width = 4
bullet.height = 4
bullet.color = {r = 255, g = 255, b = 255}
bullet.lifetime = 0
bullet.vx = 0
bullet.vy = 0
bullet.damage = 100
bullet.damages_mask = 1
bullet.damage_mask = 0
bullet.collision_mask = 0

function bullet:new()
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end
	return new
end

function bullet:load(id)
	self.id = id
	if server then
		server:broadcast(packet_types.SPAWN_ENTITY, {type = 'bullet', id = id, x = self.x, y = self.y, color = self.color, width = self.width, height = self.height, vx = self.vx, vy = self.vy})
	end
end


function bullet:draw()
	love.graphics.setColor(self.color.r/255, self.color.g/255, self.color.b/255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end


function bullet:update(dt, process_only)
	self.lifetime = self.lifetime + dt

	
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

			if self.lifetime > 10 then
				server:broadcast(packet_types.ENTITY_DEATH, {id=self.id})
				server:remove_entity(self.id)
			end
		end
	end
	
end

return bullet