function table.contains(table, value)
	for k,v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

util = {
	_id_counter = 0,
}
function util:rectPointCollision(rect, x, y)
	return x >= rect.x and x <= rect.x + rect.width and y >= rect.y and y <= rect.y + rect.height
end

function util:quickDistance(x1, x2, y1, y2)
	return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end

function util:encode_input_state(entity)
	current_input = 0
	if entity.right then
		current_input = bit.bor(current_input, 1)
	end
	if entity.left then
		current_input = bit.bor(current_input, 2)
	end
	if entity.up then
		current_input = bit.bor(current_input, 4)
	end
	if entity.down then
		current_input = bit.bor(current_input, 8)
	end
	return current_input
end

function util:colliding(rect1, rect2) 
	return not (rect2.x > rect1.x + rect1.width or rect2.x + rect2.width < rect1.x or rect2.y > rect1.y + rect1.height or rect2.y + rect2.height < rect1.y)	
end

function util:generate_id()
	self._id_counter = self._id_counter + 1
	return self._id_counter
end