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
local cursor = {}
cursor.x, cursor.y = love.mouse.getPosition()

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
	enemy.reset(true)
end

-- enemy manager (due to dependency shit it is here)
function player.enemy_man(dt)
	enemy.hp_man(player.projectile, player)
	enemy.movement_man(dt, player)
	enemy.check_wall(walls)
    enemy.wave_man()
end

-- spawn projectile
function player.spawn_projectile()
	player.projectile = {
		x = player.x + 25,
		y = player.y + 25,
		lifetime = 1, -- seconds
		width = 10,
		height = 10,
	}
end

function get_cursor()
    local curs = {}
    curs.x, curs.y = love.mouse.getPosition()
    return curs
end

-- update projectile
function player.update_projectile(dt)
    local cursor = get_cursor()

    if love.mouse.isDown(1) and projectile == nil then 
        player.spawn_projectile()
    end

	if not player.projectile then
		return
	end
    
    player.projectile.lifetime = player.projectile.lifetime - dt

	local dx = cursor.x - player.projectile.x
    local dy = cursor.y - player.projectile.y

    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 0 then
        player.projectile.x = player.projectile.x + (dx / dist) * player.projectile_speed * dt
        player.projectile.y = player.projectile.y + (dy / dist) * player.projectile_speed * dt
    end

    -- Check if projectile hits an enemy
	if player.projectile and enemy.hp_man(player.projectile, player) then
		player.projectile = nil -- Destroy projectile on hit
	elseif player.projectile and player.projectile.lifetime <= 0 or (player.projectile.x == cursor.x and player.projectile.y == cursor.y) then
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

        if not collision.check_circle(player.projectile, circle) then 
            player.projectile = nil
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
    love.graphics.print("HP: " .. player.hp .. "/100", 1025, 950)
end

return player
