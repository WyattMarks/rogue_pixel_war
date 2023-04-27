if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
---@diagnostic disable-next-line: duplicate-set-field
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

cbor = require("src/thirdparty/cbor")
cbor.set_float('double')
cbor.set_nil('null')
font = require("src/gui/font")
debugger = require("src/gui/debug") --lol debug global name is taken 
button = require("src/gui/button")
menu = require("src/menu")
game = require("src/game")
input = require("src/input/input")
settings = require("src/settings")
require("src/util/utility")


---@diagnostic disable-next-line: duplicate-set-field
function love.load()

	major,minor,rev = love.getVersion()
	assert(major==11 and minor==4 and rev==0, "LOVE2D Out Of Date!")

	math.randomseed(os.time())
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()

	debugger:print("Loading fonts...")
	font:load()
	debugger:print("Loading main menu...")
	menu:load()
end

---@diagnostic disable-next-line: duplicate-set-field
function love.update(dt)
	debugger:update(dt)

	if game.running then
		game:update(dt)
	else
		menu:update(dt)
	end
end

function love.draw()
	debugger:draw()

	if game.running then
		game:draw()
	else
		menu:draw()
	end
end

function love.keypressed(key, scancode, isrepeat)
	input:keypressed(key, isrepeat)

	if game.running then
		game:keypressed(key, isrepeat)
	else
		menu:keypressed(key, isrepeat)
	end
end

function love.keyreleased(key)
	input:keyreleased(key)
end

function love.mousepressed(x, y, button, istouch)
	input:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
	input:mousereleased(x, y, button, istouch)
end

function love.textinput(t)

	if game.running then
		game:textinput(t)
	else
		menu:textinput(t)
	end
end