local ghud = {}
ghud.items = {}
ghud.sprite_groups = {}
ghud.tile_size = 32


ghud.SCREEN_WIDTH = math.floor(SCREEN_WIDTH / ghud.tile_size)
ghud.SCREEN_HEIGHT = math.floor(SCREEN_HEIGHT / ghud.tile_size)

ghud.tile_map = {
	frame_top_left = {16, 40},
	frame_top_middle = {49, 40},
	frame_top_right = {82, 40},
	frame_middle_left = {478, 24},
	frame_middle_middle = {511, 24},
	frame_middle_right = {544, 24},
	frame_bottom_left = {478, 80},
	frame_bottom_middle = {511, 80},
	frame_bottom_right = {544, 80},

	hud_icon = {448, 180, 84, 64},
	hud_bar_empty1 = {533, 184, 8, 16},
	hud_bar_empty2 = {542, 184, 8, 16},
	hud_health_bar_cap = {551, 182, 38, 20},
	hud_mana_bar_cap = {551, 202, 38, 20},
	hud_xp_bar_cap = {551, 222, 38, 20},
	hud_health_bar1 = {592, 186, 8, 12},
	hud_mana_bar1 = {592, 206, 8, 12},
	hud_xp_bar1 = {592, 226, 8, 12},
	hud_health_bar2 = {601, 186, 8, 12},
	hud_mana_bar2 = {601, 206, 8, 12},
	hud_xp_bar2 = {601, 226, 8, 12},

	empty_space = {560, 170, 1, 1},

}

function ghud:load()
	debugger:print("Loading UI..")

	self.texture = love.graphics.newImage("assets/ui.png")
	self.texture:setFilter("nearest", "nearest")
	self.texture_width, self.texture_height = self.texture:getDimensions()

	self.spriteBatch = love.graphics.newSpriteBatch(self.texture, 1024)

	self.empty_space = love.graphics.newQuad( self.tile_map.empty_space[1], self.tile_map.empty_space[2],
		self.tile_map.empty_space[3], self.tile_map.empty_space[4], self.texture_width, self.texture_height )
end

function ghud:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.spriteBatch, 0, 0)
end

function ghud:add_item(type, parameters)
	local item = require("src/ghud/" .. type):new(self, parameters)
	self.items[#self.items+1] = item

	return item
end

function ghud:add_to_spritebatch(quad, x, y, group, reuse)
	if not self.sprite_groups[group] then
		self.sprite_groups[group] = {index = 1, ids = {}}
	end

	if reuse then
		if self.sprite_groups[group].index >= #self.sprite_groups[group].ids then
			self.sprite_groups[group].ids[#self.sprite_groups[group].ids + 1] = self.spriteBatch:add(quad, x, y)
			self.sprite_groups[group].index = self.sprite_groups[group].index + 1
		else
			self.spriteBatch:set(self.sprite_groups[group].ids[self.sprite_groups[group].index], quad, x, y)
			self.sprite_groups[group].index = self.sprite_groups[group].index + 1
		end
	else
		self.sprite_groups[group].ids[#self.sprite_groups[group].ids + 1] = self.spriteBatch:add(quad, x, y)
	end
end

function ghud:clear_spritebatch_group(group)
	for i=self.sprite_groups[group].index, #self.sprite_groups[group].ids do
		self.spriteBatch:set(self.sprite_groups[group].ids[i], self.empty_space, 0, 0)
	end
end

function ghud:update(dt)
	for k,v in pairs(self.items) do
		v:update(dt)
	end
end

return ghud