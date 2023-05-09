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

package.path = package.path .. ";.."
player = require("src/player")
zombie = require("src/entities/zombie")
bullet = require("src/entities/bullet")
fireball = require("src/entities/fireball")
cbor = require("src/thirdparty/cbor");
cbor.set_float('double')
cbor.set_nil('null')
server = require("server")
wave_spawner = require("wave_spawner")
enet = require("enet")
require("src/util/utility")
players = {}

---@diagnostic disable-next-line: duplicate-set-field
function love.load()
	host = enet.host_create("*:"..tostring(1337))
	server:load(host)
	print('Loaded Rogue Pixel War Server on port 1337')
end

---@diagnostic disable-next-line: duplicate-set-field
function love.update(dt)
	server:update(dt)
end
