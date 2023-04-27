local panel = {}
panel.x = 0
panel.y = 0
panel.width = 1
panel.height = 1



function panel:new(x, y, width, height)
	local new = {}
	for k,v in pairs(self) do
		new[k] = v
	end

	self.x = x
	self.y = y
	self.width = width
	self.height = height

	return new
end



return panel