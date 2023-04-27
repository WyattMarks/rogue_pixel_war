local game = {}
game.players = {}
game.entities = {}
game.running = false
game.local_player = nil

game.entity_map = {
}

function game:load(name)
	debugger:print("Starting game...")
	player = require("src/player")
	camera = require("src/util/camera")
	game_binds = require("src/input/game")
	enet = require("enet")
	network = require("src/network")
	textbox = require("src/gui/textbox")
	chatbox = require("src/gui/chatbox")
	zombie = require("src/entities/zombie")
	bullet = require("src/entities/bullet")
	hud = require("src/gui/hud")
	ghud = require("src/ghud/ghud")

	ghud:load()

	self.entity_map['zombie'] = zombie
	self.entity_map['bullet'] = bullet

	chatbox:load()

	self:add_player(name, true)

	ghud:add_item('player_hud')

	network:load()
	game_binds:load()

	self.running = true
end

function game:add_player(name, is_local)
	local new_player = player:new()
	new_player.local_player = is_local
	new_player.name = name

	self.players[#self.players+1] = new_player

	if is_local then
		self.local_player = new_player
		camera:follow(new_player)
	end

	new_player:load()
	return new_player
end

function game:add_entity(data)
	local new_entity = self.entity_map[data.type]:new()
	for k,v in pairs(data) do
		if k ~= "type" then
			new_entity[k] = v
		end
	end

	self.entities[#self.entities+1] = new_entity

	new_entity:load(data.id)
	return new_entity
end

function game:get_entity(id)
	for k,v in pairs(self.entities) do
		if v.id == id then return v end
	end
end

function game:update_entity(data)
	local entity = self:get_entity(data.id)
	if not entity then return end
	for k,v in pairs(data) do
		if k ~= "input" then
			entity[k] = v
		end
	end

	if not data.input then return end

	entity.right = bit.band(data.input, 1) == 1
	entity.left = bit.band(data.input, 2) == 2
	entity.up = bit.band(data.input, 4) == 4
	entity.down = bit.band(data.input, 8) == 8
end

function game:remove_entity(data)
	j = 1
	for i = 1, #self.entities do
        if self.entities[i].id ~= data.id then
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

function game:update(dt)
	camera:update(dt)
	chatbox:update(dt)
	hud:update(dt)
	ghud:update(dt)
	for k,player in pairs(self.players) do
		player:update(dt)
	end
	for k,entity in pairs(self.entities) do
		entity:update(dt)
	end
	network:update(dt)

end

function game:draw()
	camera:set()
		--draw level

		for k,entity in pairs(self.entities) do
			entity:draw()
		end
		for k,player in pairs(self.players) do
			player:draw()
		end
		
	camera:unset()

	chatbox:draw()
	hud:draw()
	ghud:draw()
	--draw hud
end

function game:get_local_player()
	if self.local_player then
		return self.local_player
	end

	for k, player in pairs(self.players) do
		if player.local_player then
			self.local_player = player
			return player
		end
	end

	return nil
end

function game:keypressed(key, isrepeat)
	chatbox:keypressed(key)
end

function game:textinput(t)
	chatbox:textinput(t)
end






return game