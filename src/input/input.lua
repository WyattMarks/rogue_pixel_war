local input = {
    binds = {},
    mouseBinds = {}
}

--[[Bind function setup:
    function bind(bool down, (optional bool isrepeat)
    
    end
]]

function input:addBind(identifier, key, func)
    self.binds[#self.binds + 1] = {identifier, key, func};
end

function input:removeBind(identifier)
	for i = #self.binds, 1, -1 do
	    if self.binds[i][1] == identifier then
	        table.remove(self.binds, i)
	        return
	    end
	end
end

function input:addMouseBind(identifier, button, func)
    self.mouseBinds[#self.mouseBinds + 1] = {identifier, button, func};
end

function input:removeMouseBind(identifier)
	for i = #self.mouseBinds, 1, -1 do
	    if self.mouseBinds[i][1] == identifier then
	        table.remove(self.mouseBinds, i)
	        return
	    end
	end
end

function input:keyreleased(key)
    for k,v in ipairs(self.binds) do
        if v[2] == key and v[4] then
            v[3](false);
        end
    end
end

function input:keypressed(key, isrepeat)
    for k,v in ipairs(self.binds) do
        if v[2] == key then
            v[4] = true
            v[3](true, isrepeat);
        end
    end
end

function input:mousepressed(x, y, button, touch)
    for k,v in ipairs(self.mouseBinds) do
        if v[2] == button then
            v[3](true, x, y, button, touch);
        end
    end
end

function input:mousereleased(x, y, button, touch)
    for k,v in ipairs(self.mouseBinds) do
        if v[2] == button then
            v[3](false, x, y, button, touch);
        end
    end
end

return input;

