local fireball = {}
fireball.x = 0
fireball.y = 0
fireball.speed = 420
fireball.width = 30
fireball.height = 15
fireball.lifetime = 1.5
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

	self.r = math.asin(self.vy)
	if server then return end

	self.animator = animator:new("weapons/staff-shot-08-30x15", 0, 0, false)

	self.animator:load_state('done', 0, 0, 0, 0, 1, {frametime=10, replay=false})
	self.animator:load_state('idle_right', 0, 0, 30, 15, 15, {frametime=self.lifetime/15, replay=false})
	self.animator:mirror_state('idle_right', 'idle_left')
	self.animator:set_default('done')

	if self.vx > 0 then
		self.animator:set_state('idle_right')
	else
		self.animator:set_state('idle_left')
	end

	self.animator.r = self.r
end


function fireball:draw()
	self.animator:draw(self.x, self.y)

	if debugger.hitboxes then
		love.graphics.push()
			love.graphics.translate(self.x, self.y)
			local x, y, rotate = 0, 0, self.r
			if self.vx < 0 then
				rotate = -rotate
				x = -self.width
			end
			love.graphics.rotate(rotate)
			love.graphics.rectangle("line", x, y, self.width, self.height)
		love.graphics.pop()

		function find_bottomleft(rotation, width, height, top_left)
			local cosr = math.cos(-rotation) -- = a / h = offset_x / h
			local sinr = math.sin(-rotation) -- = o / h = offset_y / h
			local offset_x, offset_y = sinr * height, cosr * height
			return {top_left[1] + offset_x, top_left[2] + offset_y}
		end
		function find_topright(rotation, width, height, top_left)
			local cosr = math.cos(rotation) -- = a / h = offset_x / h
			local sinr = math.sin(rotation) -- = o / h = offset_y / h
			local offset_x = cosr * width
			local offset_y = sinr * width
			if self.vx < 0 then
				offset_x, offset_y = -offset_x, -offset_y
			end
			return {top_left[1] + offset_x, top_left[2] + offset_y}
		end

		love.graphics.setColor(1,1,1)
		local tr = find_topright(rotate, self.width, self.height, {self.x, self.y})
		love.graphics.circle('line', tr[1], tr[2], 2)
		local bl = find_bottomleft(rotate, self.width, self.height, {self.x, self.y})
		love.graphics.circle('line', bl[1], bl[2], 2)
		local br = {bl[1] - (self.x) + tr[1], bl[2] - (self.y) + tr[2]}
		love.graphics.circle('line', br[1], br[2], 2)
		love.graphics.circle('line', self.x, self.y, 2)
	end
end


function fireball:update(dt, process_only)
	self.lifetime = self.lifetime - dt


	self.x = self.x + self.vx * self.speed * dt
	self.y = self.y + self.vy * self.speed * dt

	if server then
		if not process_only then
			for k,ent in pairs(server.entities) do
				if bit.band(self.damages_mask, ent.damage_mask) == self.damages_mask then
					if util:colliding_rot(self, ent) then
						ent:damage(self.damage, self)
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