local network = {}

network.address = "localhost"
network.port = 1337
network.ready = false
network.queue = {}
network.time_delta = 0

network.packet_types = {
	READY = "a",
	JOIN = "b",
	PLAYER_DATA = "c",
	CHAT = "d",
	SPAWN_ENTITY = "e",
	ENTITY_DATA = "f",
	SHOOT = "g",
	ENTITY_DEATH = "h",
	ANNOUNCEMENT = "i",
}

network.packet = {
	packet_type = -1,
	data = nil,
}

function network.packet:parse(raw)
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end

	new.packet_type = string.sub(raw, 1, 1)
	new.data = cbor.decode(string.sub(raw, 2))

	return new
end



function network:load()
	self.host = enet.host_create()
	self.server = self.host:connect(self.address..":"..tostring(self.port))
end

function network:send(packet_type, message) 
	if self.ready then
		self.server:send(packet_type..cbor.encode(message))

		if #self.queue > 0 then
			for k, v in pairs(self.queue) do
				self.server:send(v)
			end
			self.queue = {}
		end
	else
		self.queue[#self.queue + 1] = packet_type..cbor.encode(message)
	end
end



function network:get_player(peer_id)
	for k,v in pairs(game.players) do
		if v.id == peer_id then
			return v
		end
	end
end

function network:player_data(data)
	player = self:get_player(data.player)

	if data.input then
		player.right = bit.band(data.input, 1) == 1
		player.left = bit.band(data.input, 2) == 2
		player.up = bit.band(data.input, 4) == 4
		player.down = bit.band(data.input, 8) == 8
	end

	if data.x then
		player.x = data.x
		player.y = data.y
	end

	if data.health then
		player:damage(player.health - data.health)
	end
end

function network:update(dt)
	local event = self.host:service()

	while event do
		if event.type == "receive" then
			local packet = self.packet:parse(event.data)
			if packet.packet_type == self.packet_types.READY then
				self.ready = true
				self.time_delta = packet.data.time - love.timer.getTime()
				self.id = packet.data.id
				local_player = game.get_local_player(game)
				local_player.id = packet.data.id
				debugger:print('Connection confirmed! Peer #' .. tostring(self.id))
				self:send(self.packet_types.JOIN, local_player.name)
			elseif packet.packet_type == self.packet_types.JOIN then
				ply = game:add_player(packet.data.name, false)
				ply.id = packet.data.id
			elseif packet.packet_type == self.packet_types.PLAYER_DATA then
				self:player_data(packet.data)
			elseif packet.packet_type == self.packet_types.CHAT then
				chatbox:message(self:get_player(packet.data.id).name, packet.data.msg)
			elseif packet.packet_type == self.packet_types.SPAWN_ENTITY then
				game:add_entity(packet.data)
			elseif packet.packet_type == self.packet_types.ENTITY_DATA then
				game:update_entity(packet.data)
			elseif packet.packet_type == self.packet_types.ENTITY_DEATH then
				game:remove_entity(packet.data)
			elseif packet.packet_type == self.packet_types.ANNOUNCEMENT then
				hud:announce(packet.data.msg)
			else
				print(packet.data)
			end
		elseif event.type == 'disconnect' then 
			error("Network error: "..tostring(event.data))
		end
		event = self.host:service()
	end
end

return network