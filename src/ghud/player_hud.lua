local player_hud = {}
player_hud.num_bars = 20

function player_hud:generate_bars(reuse_ids)
	local tile_info = self.tile_map.hud_bar_empty1
	self.bar_empty1 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	local tile_info = self.tile_map.hud_bar_empty2
	self.bar_empty2 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_health_bar1
	self.health_bar1 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_health_bar2
	self.health_bar2 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_mana_bar1
	self.mana_bar1 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_mana_bar2
	self.mana_bar2 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_xp_bar1
	self.xp_bar1 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_xp_bar2
	self.xp_bar2 = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_xp_bar_cap
	self.xp_bar_cap = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_mana_bar_cap
	self.mana_bar_cap = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )
	tile_info = self.tile_map.hud_health_bar_cap
	self.health_bar_cap = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )

	tile_info = self.tile_map.empty_space
	self.empty_space = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], self.texture_width, self.texture_height )

	local ply = game:get_local_player()
	if ply == nil then return end

	self.health = ply.health
	self.mana = ply.mana
	self.xp = ply.xp

	self:generate_bar(self.x + 84, self.y + 2, ply.health/ply.max_health, self.health_bar1, self.health_bar2, self.health_bar_cap, reuse_ids)
	self:generate_bar(self.x + 84, self.y + 22, ply.mana/ply.max_mana, self.mana_bar1, self.mana_bar2, self.mana_bar_cap, reuse_ids)
	self:generate_bar(self.x + 84, self.y + 42, ply.xp/ply.max_xp, self.xp_bar1, self.xp_bar2, self.xp_bar_cap, reuse_ids)

	if reuse_ids then
		ghud:clear_spritebatch_group('bar')
	end
end


function player_hud:generate_bar(x, y, amount, bar1, bar2, cap, reuse_ids)
	for i = 0, 19 do
		if i == 0 then
			ghud:add_to_spritebatch(self.bar_empty1, x + i * 8, y + 2, 'bar', reuse_ids)
		else
			ghud:add_to_spritebatch(self.bar_empty2, x + i * 8, y + 2, 'bar', reuse_ids)
		end
	end

	local end_x = x
	for i = 0, self.num_bars * amount - 1 do
		end_x = x + i * 8

		if i == 0 then
			ghud:add_to_spritebatch(bar1, end_x, y + 4, 'bar', reuse_ids)
		else
			ghud:add_to_spritebatch(bar2, end_x, y + 4, 'bar', reuse_ids)
		end
	end


	local pixels_left = math.floor((amount * self.num_bars - math.floor(amount * self.num_bars)) * 8)
	if pixels_left > 0 then
		local bar = bar2
		if amount < 1 / self.num_bars then
			end_x = end_x - 8
			bar = bar1
		end
		local map_x, map_y, map_w, map_h = bar:getViewport()
		bar:setViewport(map_x, map_y, pixels_left, map_h)
		ghud:add_to_spritebatch(bar, end_x+8, y + 4, 'bar', reuse_ids)
		bar:setViewport(map_x, map_y, map_w, map_h)
	end

	ghud:add_to_spritebatch(cap, x + 160, y, 'bar', reuse_ids)
end

function player_hud:new(ghud, parameters)
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end

	new.texture_width, new.texture_height = ghud.texture_width, ghud.texture_height
	new.spriteBatch = ghud.spriteBatch
	new.tile_map = ghud.tile_map
	new.x = 64
	new.y = SCREEN_HEIGHT - 100

	local tile_info = ghud.tile_map.hud_icon
	new.icon = love.graphics.newQuad( tile_info[1], tile_info[2], tile_info[3], tile_info[4], new.texture_width, new.texture_height )
	new.icon_id = ghud.spriteBatch:add(new.icon, new.x, new.y )

	new:generate_bars(false)

	return new
end



function player_hud:update(dt)
	local ply = game:get_local_player()
	if ply == nil then return end 

	if ply.health ~= self.health or ply.mana ~= self.mana or ply.xp ~= self.xp then
		self.health = ply.health
		self.mana = ply.mana
		self.xp = ply.xp

		self:generate_bars(true)
	end
end


return player_hud