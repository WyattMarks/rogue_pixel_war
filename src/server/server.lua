local server = {}
server.players = {}
server.entities = {}
server.started = false

packet_types = {
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
packet = {
	data = nil,
	type = -1
}

function packet:parse(raw)
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end

	new.packet_type = string.sub(raw, 1, 1)
	new.data = cbor.decode(string.sub(raw, 2))

	return new
end

function server:load(host)
	self.host = host
end

function server:add_player(data, peer)
	local new_player = player:new()
	new_player.local_player = false
	new_player.name = data
	new_player.peer = peer

	new_player:load()
	self:broadcast(packet_types.JOIN, {name=data,id=peer:connect_id()}, {new_player})

	for k,v in pairs(self.players) do
		self:send(peer, packet_types.JOIN, {name=v.name, id=v.peer:connect_id()})
	end

	self.players[#self.players+1] = new_player

	print("New player: " .. data)
end

function server:broadcast(packet_type, data, exclude)
	if exclude == nil then exclude = {} end  
	for k,v in pairs(self.players) do
		if not table.contains(exclude, v) then
			self:send(v.peer, packet_type, data)
		end
	end
end

function server:send(peer, packet_type, data)
	if data == nil then data = "" end
	peer:send(packet_type .. cbor.encode(data))
end

function server:player_data(peer, data)
	player = self:get_player(peer)


	player.right = bit.band(data.input, 1) == 1
	player.left = bit.band(data.input, 2) == 2
	player.up = bit.band(data.input, 4) == 4
	player.down = bit.band(data.input, 8) == 8
	player.x = data.x
	player.y = data.y

	data.player = peer:connect_id()

	server:broadcast(packet_types.PLAYER_DATA, data, {player})
end

function server:remove_entity(id)
	j = 1
	for i = 1, #self.entities do
        if self.entities[i].id ~= id then
            if (i ~= j) then
                self.entities[j] = self.entities[i]
                self.entities[i] = nil;
            end
            j = j + 1;
        else
            self.entities[i] = nil;
        end
    end
end

function server:get_player(peer)
	for k,v in pairs(self.players) do
		if v.peer == peer then
			return v
		end
	end
end

function server:shoot(peer, data)
	b = fireball:new()
	b.x = data.x
	b.y = data.y
	b.vx = data.vx
	b.vy = data.vy
	b.peer = peer

	self.entities[#self.entities+1] = b
	b:load(util:generate_id())
	b:update(love.timer.getTime() - data.time)

	local ply = self:get_player(peer)

	server:broadcast(packet_types.SHOOT, {right=data.vx>0, player=peer:connect_id()}, {ply})

	ply.right = false
	ply.left = false
	ply.up = false
	ply.down = false
end

function server:update(dt)
	local event = self.host:service()

	while event do
		if event.type == "receive" then
			local data = packet:parse(event.data)
			if data.packet_type == packet_types.JOIN then
				self:add_player(data.data, event.peer)
				--self.started = true
			elseif data.packet_type == packet_types.PLAYER_DATA then
				self:player_data(event.peer, data.data)
			elseif data.packet_type == packet_types.CHAT then
				self:broadcast(packet_types.CHAT, {msg=data.data.msg,id=event.peer:connect_id()})
				if data.data.msg == "START" then
					self.started = true
				end
			elseif data.packet_type == packet_types.SHOOT then
				self:shoot(event.peer, data.data)
			else
				print("Unprocessed packet: [" .. tostring(data.packet_type) .. "] " .. tostring(data.data))
			end
		elseif event.type == "connect" then
			print("New connection: " .. tostring(event.peer))
			self:send(event.peer, packet_types.READY, {time=love.timer.getTime(), id=event.peer:connect_id()})
		elseif event.type == "disconnect" then
			--TODO: remove from game and broadcast the problem
		end

		event = self.host:service()
	end

	for k, v in pairs(self.players) do
		v:update(dt)
	end

	for k,v in pairs(self.entities) do
		v:update(dt)
	end

	if self.started then
		wave_spawner:update(dt)
	end
end











return server