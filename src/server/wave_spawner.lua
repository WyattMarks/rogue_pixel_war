local wave_spawner = {}
wave_spawner.last_update = 999
wave_spawner.last_wave = 999
wave_spawner.current_wave = 0

function wave_spawner:spawn_zombie(x, y)
	zomb = zombie:new()
	zomb.x = x
	zomb.y = y
	zomb.speed = zomb.speed + self.current_wave

	for k,ent in pairs(server.entities) do
		while util:colliding(zomb, ent) do
			zomb.x = zomb.x + 5
			zomb.y = zomb.y + 5
		end
	end

	server.entities[#server.entities+1] = zomb
	zomb:load(util:generate_id())
end

function wave_spawner:spawn_wave()
	self.current_wave = self.current_wave + 1

	server:broadcast(packet_types.ANNOUNCEMENT, {msg = "Wave "..tostring(self.current_wave)})

	for i = 1, self.current_wave * 10 do
		local target = server.players[math.random(#server.players)]
		local x = target.x
		local y = target.y
		local r = 2000
		local angle = math.random() * math.pi * 2
		x = x + math.cos(angle) * r
		y = y + math.sin(angle) * r

		self:spawn_zombie(x,y)
	end
end

function wave_spawner:update(dt)
	self.last_update = self.last_update + dt

	if self.last_update > 1 then
		local enemies = {}
		for k, ent in pairs(server.entities) do
			if ent.damages_mask == player.damage_mask then
				enemies[#enemies+1] = ent
			end
		end

		if #enemies == 0 then
			self:spawn_wave()
		end

		self.last_update = 0
	end

end





return wave_spawner