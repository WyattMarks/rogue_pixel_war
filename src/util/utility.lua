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

function util:rectPointCollision_rot(rect, x, y)
	rect.r = rect.r or 0
	local sinr = math.sin(-rect.r)
	local cosr = math.cos(-rect.r)
	local local_x = x - rect.x
	local local_y = y - rect.y
	local cos_offset = cosr * local_x
	local sin_offset = sinr * local_x
	if rect.vx and rect.vx < 0 then
		cos_offset, sin_offset = -cos_offset, -sin_offset
	end
	local new_x = cos_offset - sinr * local_y
	local new_y = sin_offset + cosr * local_y
	local local_rect = {x = 0, y = 0, width=rect.width, height=rect.height}
	return util:rectPointCollision(local_rect, new_x, new_y)
end

function util:_find_bottomleft(rotation, width, height, top_left)
	local cosr = math.cos(-rotation) -- = a / h = offset_x / h
	local sinr = math.sin(-rotation) -- = o / h = offset_y / h
	local offset_x, offset_y = sinr * height, cosr * height
	return {top_left[1] + offset_x, top_left[2] + offset_y}
end
function util:_find_topright(rotation, width, height, top_left, mirror)
	local cosr = math.cos(rotation) -- = a / h = offset_x / h
	local sinr = math.sin(rotation) -- = o / h = offset_y / h
	local offset_x = cosr * width
	local offset_y = sinr * width
	if mirror then
		offset_x, offset_y = -offset_x, -offset_y
	end
	return {top_left[1] + offset_x, top_left[2] + offset_y}
end

function util:colliding_rot(rot_rect, rect)
	local rotate = rot_rect.r
	local mirror = false
	if rot_rect.vx < 0 then
		rotate = -rotate
		mirror = true
	end
	local tr = self:_find_topright(rotate, rot_rect.width, rot_rect.height, {rot_rect.x, rot_rect.y}, mirror)
	local bl = self:_find_bottomleft(rotate, rot_rect.width, rot_rect.height, {rot_rect.x, rot_rect.y})
	local br = {bl[1] - (rot_rect.x) + tr[1], bl[2] - (rot_rect.y) + tr[2]}
	local tl = {rot_rect.x, rot_rect.y}

	if self:rectPointCollision(rect, tr[1], tr[2]) then
		return true
	end
	if self:rectPointCollision(rect, bl[1], bl[2]) then
		return true
	end
	if self:rectPointCollision(rect, br[1], br[2]) then
		return true
	end
	if self:rectPointCollision(rect, tl[1], tl[2]) then
		return true
	end
	return false
end


function util:generate_id()
	self._id_counter = self._id_counter + 1
	return self._id_counter
end