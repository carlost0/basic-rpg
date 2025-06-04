local enemy = {}

-- Breaking circular dependency by removing direct require
-- Will access player through function parameters instead
local collision = require("src.collision")
local wall = require("src.walls")

-- enemy variables
enemy.amount = 0
enemy.creatures = {} -- Store all enemy instances here

-- spawn enemies
function enemy.spawn(amount)
	for i = 0, amount do
		if enemy.amount == amount then
			return
		end

		local width = math.random(20, 40)
		local creature = {
			dir = math.random(0, 3),

			x = math.random(0, 1000),
			y = math.random(0, 1000),

			width = width,
			height = width,

			speed = math.random(300, 500),

			hp = math.random(50, 120),
		}
		table.insert(enemy.creatures, creature)

		enemy.amount = enemy.amount + 1
	end
end

-- move enemy
function enemy.movement_man(dt)
	for i, creature in ipairs(enemy.creatures) do
		-- Fixed the direction conditions (you had dir == 1 twice)
		if creature.dir == 0 then
			creature.x = creature.x + creature.speed * dt
		elseif creature.dir == 1 then
			creature.x = creature.x - creature.speed * dt
		elseif creature.dir == 2 then
			creature.y = creature.y + creature.speed * dt
		elseif creature.dir == 3 then
			creature.y = creature.y - creature.speed * dt
		end

		if creature.x <= 0 then
			creature.x = 1000
		elseif creature.x >= 1000 then
			creature.x = 0
		elseif creature.y <= 0 then
			creature.y = 1000
		elseif creature.y >= 1000 then
			creature.y = 0
		end

		creature.dir = math.random(0, 3)
	end
end
-- manage hp
function enemy.hp_man(player_projectile, player)
	if not player_projectile then
		return false
	end

	for i, creature in ipairs(enemy.creatures) do
		local projectile_box = {
			x = player_projectile.x,
			y = player_projectile.y,
			width = 10,
			height = 10,
		}

		if not collision.check(projectile_box, creature) then
			goto continue
		end

		creature.hp = creature.hp - 1

		if creature.hp <= 0 or collision.check(player, creature) then
			table.remove(enemy.creatures, i)
			enemy.amount = enemy.amount - 1
		end

		::continue::
	end
end

-- look if enemy is in wall
function check_wall()
	for i, creature in ipairs(enemy.creeatures) do
		for i, wall in ipairs(wall) do
			if collision.check(creature, wall) then
				creature.x = math.random(20, 980)
				creature.y = math.random(20, 980)
			end
		end
	end
end

-- Draw all enemies
function enemy.draw()
	love.graphics.setColor(1, 0, 0, 1)
	for _, creature in ipairs(enemy.creatures) do
		love.graphics.rectangle("fill", creature.x, creature.y, creature.width, creature.height)
	end
end

-- Get all enemies for collision detection
function enemy.get_creatures()
	return enemy.creatures
end

return enemy
