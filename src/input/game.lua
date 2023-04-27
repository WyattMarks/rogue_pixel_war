local game_inputs = {}


function game_inputs:load()
	input:addBind("player_right", settings.binds.right, function(down)
		game:get_local_player().right = down
		game:get_local_player():send_input_state()
	end)
	input:addBind("player_left", settings.binds.left, function(down)
		game:get_local_player().left = down
		game:get_local_player():send_input_state()
	end)
	input:addBind("player_up", settings.binds.up, function(down)
		game:get_local_player().up = down
		game:get_local_player():send_input_state()
	end)
	input:addBind("player_down", settings.binds.down, function(down)
		game:get_local_player().down = down
		game:get_local_player():send_input_state()
	end)
	input:addMouseBind("player_shoot", settings.binds.shoot, function(down)
		game:get_local_player():shoot(down)
	end)
end

function game_inputs:unload()
	input:removeBind("player_right")
	input:removeBind("player_left")
	input:removeBind("player_up")
	input:removeBind("player_down")
end











return game_inputs