local player = require("src.player")
local walls = require("src.walls")
local config = require("gameconf")
local enemy = require("src.enemy")

-- keypresses
function love.keypressed(key)
	player.keypressed(key)
end

-- load
function love.load()
    Font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 24)
end

-- main loop
function love.update(dt)
	player.man(dt)
	player.update_projectile(dt)
    player.enemy_man(dt)
end

function love.draw()
    love.graphics.setFont(Font)
	-- player
	player.draw()

	-- enemy
	enemy.draw()

	-- projectile
	if player.projectile then
		love.graphics.rectangle("fill", player.projectile.x, player.projectile.y, 10, 10)
	end

	-- walls
	walls.draw()
end
