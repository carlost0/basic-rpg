local player = {}

-- requirements
local config = require("gameconf")
local collision = require("src.collision")
local walls = require("src.walls")
local enemy = require("src.enemy")

-- font
local hp_font = love.graphics.newFont(100)
-- player variables
-- movement
player.speed = config.player_speed
player.x = 500
player.y = 500

-- size
player.width = 50
player.height = 50

-- hp
player.hitbox = nil
player.hp = 100
player.damage_interval = 0.75

-- score
player.score = 0
-- projectile variables
player.projectile_speed = config.projectile_speed
player.projectile = nil

-- last attack direction
player.last_attack_key = nil

-- general variables

local timer = 0

-- reset function
function player.reset()
	-- movement
	player.speed = config.player_speed
	player.x = 500
	player.y = 500

	-- size
	player.width = 50
	player.height = 50

	-- hp
	player.hitbox = nil
	player.hp = 100
	player.damage_interval = 0.75

	-- score
	player.score = 0
	-- projectile variables
	player.projectile_speed = config.projectile_speed
	player.projectile = nil

	-- last attack direction
	player.last_attack_key = nil
	enemy.reset(true)
end
-- handle keypresses
function player.keypressed(key)
	if key == "i" or key == "j" or key == "k" or key == "l" then
		player.last_attack_key = key
	end
end

-- enemy manager (due to dependency shit it is here)
function player.enemy_man(dt)
	enemy.hp_man(player.projectile, player)
	enemy.movement_man(dt, player)
	enemy.check_wall(walls)
    enemy.wave_man()
end

-- spawn projectile
function player.spawn_projectile(dir)
	player.projectile = {
		x = player.x + 25,
		y = player.y + 25,
		dir = dir,
		lifetime = 0.5, -- seconds
		width = 10,
		height = 10,
	}
end

-- update projectile
function player.update_projectile(dt)
	if not player.projectile then
		return
	end

	if player.projectile.dir == "i" then
		player.projectile.y = player.projectile.y - player.projectile_speed * dt
	elseif player.projectile.dir == "k" then
		player.projectile.y = player.projectile.y + player.projectile_speed * dt
	elseif player.projectile.dir == "j" then
		player.projectile.x = player.projectile.x - player.projectile_speed * dt
	elseif player.projectile.dir == "l" then
		player.projectile.x = player.projectile.x + player.projectile_speed * dt
	end

	player.projectile.lifetime = player.projectile.lifetime - dt

	-- Check if projectile hits an enemy
	if player.projectile and enemy.hp_man(player.projectile, player) then
		player.projectile = nil -- Destroy projectile on hit
	elseif player.projectile and player.projectile.lifetime <= 0 then
		player.projectile = nil
	end
end

-- player movement
function player.movement_man(dt)
	if love.keyboard.isDown("w") then
		player.y = player.y - player.speed * dt
	end
	if love.keyboard.isDown("a") then
		player.x = player.x - player.speed * dt
	end
	if love.keyboard.isDown("s") then
		player.y = player.y + player.speed * dt
	end
	if love.keyboard.isDown("d") then
		player.x = player.x + player.speed * dt
	end

	if player.x > 1000 then
		player.x = 0
	elseif player.x < 0 then
		player.x = 1000
	elseif player.y > 1000 then
		player.y = 0
	elseif player.y < 0 then
		player.y = 1000
	end
end

-- player collision
function player.collision_man(old_x, old_y, dt)
    for _, circle in ipairs(walls.circles) do
        if not collision.check_circle(player, circle) then
            player.x = 500
            player.y = 500
        end 
    end

	-- player => enemy
	local enemies = enemy.get_creatures()

	timer = timer + dt

	for _, creature in ipairs(enemies) do
		local player_box = {
			x = player.x,
			y = player.y,
			width = player.width,
			height = player.height,
		}

		if collision.check(player_box, creature) and timer >= player.damage_interval then
			player.hp = player.hp - 1
			timer = timer - player.damage_interval
		end
	end
end

-- player manager
function player.man(dt)
	-- Save position before moving
	local old_x, old_y = player.x, player.y

	-- Move the player
	player.movement_man(dt)

	-- Handle collision (revert to old_x/y if needed)
	player.collision_man(old_x, old_y, dt)

	-- Update projectile
	player.update_projectile(dt)

	-- attack
	if not player.projectile and player.last_attack_key then
		player.spawn_projectile(player.last_attack_key)
		player.last_attack_key = nil -- reset to prevent repeat spawns
	end

	if player.hp <= 0 then
		player.reset()
	end
	player.enemy_man(dt)
end

-- Draw player and projectile
function player.draw()
	-- Draw player
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

	-- Draw projectile if exists
	if player.projectile then
		love.graphics.setColor(1, 1, 0, 1)
		love.graphics.rectangle("fill", player.projectile.x, player.projectile.y, 10, 10)
	end

	-- Draw player hp and score
	love.graphics.setColor(0.17, 0.17, 0.17, 1)
	love.graphics.rectangle("fill", 1000, 900, 300, 30)
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("fill", 1000, 900, player.hp * 3, 30)
    love.graphics.print("HP: " .. player.hp .. "/100", 1050, 950, 0, 2, 2)
end

return player
